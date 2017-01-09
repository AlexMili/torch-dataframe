require 'csvigo'
tds = require 'tds'

local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

local threads = require "threads"

doc[[

## Data loader functions

]]

Dataframe.load_csv = argcheck{
	doc =  [[
<a name="Dataframe.load_csv">
### Dataframe.load_csv(@ARGP)

Loads a CSV file into Dataframe using csvigo as backend

@ARGT

_Return value_: self
	]],
	{name="self", type="Dataframe"},
	{name="path", type="string", doc="path to file"},
	{name="header", type="boolean", default=true,
	 doc="if has header on first line"},
	{name="schema", type="Df_Dict", opt=true,
	 doc="The column schema types with column names as keys"},
	{name="separator", type="string", default=",",
	 doc="separator (one character)"},
	{name="skip", type="number", default=0,
	 doc="skip this many lines at start of file"},
	{name="verbose", type="boolean", default=false,
	 doc="verbose load"},
	{name="rows2explore", type="number",
	 doc="The maximum number of rows to traverse when trying to identify schema",
	 opt = true},
	call=function(self, path, header, schema, separator, skip, verbose, rows2explore)

	-- Remove previous data (reset init variables)
	self:_clean()

	local data_iterator = csvigo.load{path = path,
		            header = header,
		            separator = separator,
		            skip = skip,
		            verbose = verbose,
		            column_order = true,
		            mode = "large"}

	local column_order = {}
	local first_data_row = 2 -- In large mode first row is always the header (if there is one)

	if (header) then
		column_order = data_iterator[1]
	else
		-- If there is no header, first row to explore is set to the initial first row
		-- and column names are automatically generated
		first_data_row = 1
		column_order = {}
		for i=1,#data_iterator[1] do
			column_order[i] = "Column no. " .. i
		end
	end
	if (verbose) then
		print("Loaded the header: ")
		for i,n in ipairs(column_order) do
			print(("%2d - %s"):format(i, n))
		end
	end

	if (not schema) then
		schema = Df_Dict(self:_infer_schema{
			iterator = data_iterator,
			first_data_row = first_data_row,
			column_order = Df_Array(column_order),
			rows2explore = rows2explore
		})
	end

	if (verbose) then
		print("Inferred schema: ")
		for i=1,#column_order do
			local cn = column_order[i]
			print(("%2d - %s = %s"):format(i, cn, schema[cn]))
		end
	end

	self:__init{
		-- Call the init with schema + no_rows
		schema = schema,
		no_rows = #data_iterator - first_data_row + 1,
		column_order = Df_Array(column_order),
		set_missing = false
	}
	if (verbose) then
		print("Initiated the schema")
	end

	local data_rowno = 0
	for csv_rowno=first_data_row,#data_iterator do
		data_rowno = data_rowno + 1
		local row = data_iterator[csv_rowno]
		for col_idx=1,#row do
			-- Clean the value according to the indicated data types
			local val = row[col_idx]
			if (val == "") then
				val = 0/0
			else
				val = self._convert_val2_schema{
					schema_type = schema["$"..self.column_order[col_idx]],
					val = val
				}
			end

			self.dataset[self.column_order[col_idx]]:set(data_rowno, val)
		end
		if (verbose and csv_rowno % 1e4 == 0) then
			print(("Done processing %d rows"):format(csv_rowno))
		end
	end
	if (verbose) then
		print("Done reading in data")
	end

	self.dataset, self.column_order =
		self:_clean_columns{data = self.dataset,
		                    column_order = self.column_order}

	if (verbose) then
		print("Finished cleaning columns")
	end

	return self
end}

Dataframe.load_threadcsv = argcheck{
	{name="self", type="Dataframe"},
	{name="path", type="string", doc="path to file"},
	{name="header", type="boolean", default=true,
	 doc="if has header on first line"},
	{name="schema", type="Df_Dict", opt=true,
	 doc="The column schema types with column names as keys"},
	{name="separator", type="string", default=",",
	 doc="separator (one character)"},
	{name="skip", type="number", default=0,
	 doc="skip this many lines at start of file"},
	{name="verbose", type="boolean", default=false,
	 doc="verbose load"},
	{name="nthreads", type="number", default=1,
	 doc="Number of threads to use to read the csv file"},
	call=function(self, path, header, schema, separator, skip, verbose, nthreads)

	-- TODO : implementing other method arguments (skip,separator,header)

	-- Remove previous data (reset init variables)
	self:_clean()

	if (verbose) then
		print("[INFO] Loading CSV")
	end

	local data_iterator = csvigo.load{path = path,
		            header = header,
		            separator = separator,
		            skip = skip,
		            verbose = verbose,
		            column_order = true,
		            mode = "large"}

	if (verbose) then
		print("[INFO] End loading CSV")
	end

	local column_order = {}
	local first_data_row = 2 -- In large mode first row is always the header (if there is one)

	if (header) then
		column_order = trim_table_strings(data_iterator[1])
	else
		-- If there is no header, first row to explore is set to the initial first row
		-- and column names are automatically generated
		first_data_row = 1

		for i=1,#data_iterator[1] do
			column_order[i] = "Column no. " .. i
		end
	end

	if (verbose) then
		print("Loaded the header: ")
		for i,n in ipairs(column_order) do
			print(("%2d - %s"):format(i, n))
		end
	end

	if (schema) then
		schema = schema.data
	else
		schema = self:_infer_schema{
			iterator = data_iterator,
			first_data_row = first_data_row,
			column_order = Df_Array(column_order),
			rows2explore = rows2explore
		}
	end
	if (verbose) then
		print("Inferred schema: ")
		for i=1,#column_order do
			local cn = column_order[i]
			print(("%2d - %s = %s"):format(i, cn, schema[cn]))
		end
	end

	if (verbose) then
		print("Estimation number of rows : "..#data_iterator - first_data_row + 1)
	end

	local nfield= #data_iterator[1]-1
	local nrecs = #data_iterator-1

	local idx=torch.range(1,nrecs)
	local chunks=idx:chunk(nthreads)

	-- nthreads is adapted to chunks effectively created
	nthreads = #chunks

	local tic = torch.tic()
	local t = threads.Threads(
		nthreads,
		function(threadn)
			if (verbose) then
				print("[INFO] Starting preprocessing")
			end
			require "csvigo"

			nthreads=nthreads
			nfield=nfield
			nrecs=nrecs
			chunks=chunks
			path=path
			header=header
			schema=schema
			columns_order=column_order
			verbose=verbose
		end
	)

	data_iterator = nil
	collectgarbage()

	for j=1,nthreads do
		t:addjob(
			function()
				if (verbose) then
					print("[INFO] Start of thread n°"..__threadid)
				end

				local Dataframe = require "Dataframe"

				tac = torch.tic()
				local o=csvigo.load{path=path,mode='large',column_order=true,verbose=verbose}
				-- chunk
				local c=chunks[__threadid]
				local csv_df=Dataframe()

				csv_df:_init_with_schema{
						schema = Df_Dict(schema),
						column_order = Df_Array(columns_order)
				}

				for j=1,c:size(1) do
					local row = Df_Dict(o[c[j]+1])
					row:set_keys(columns_order)

					csv_df:insert(j,row,Df_Dict(schema))
				end

				collectgarbage()

				return csv_df,__threadid
			end,
			function(data,threadn)
				self:append(data)
			end
		)
	end

	t:synchronize()
	t:terminate()

	if (verbose) then
		print("Finished cleaning columns")
	end

	return self
end}

Dataframe.bulk_load_csv = argcheck{
	doc =  [[
<a name="Dataframe.bulk_load_csv">
### Dataframe.bulk_load_csv(@ARGP)

Loads a CSV file into Dataframe using multithreading.
Warning : this method does not do the same checks as load_csv would do. It doesn't handle other format than torch.*Tensor and tds.Vec.

@ARGT

_Return value_: self
	]],
	{name="self", type="Dataframe"},
	{name="path", type="string", doc="path to file"},
	{name="header", type="boolean", default=true,
	 doc="if has header on first line (not used at the moment)"},
	{name="schema", type="Df_Dict", opt=true,
	 doc="The column schema types with column names as keys"},
	{name="separator", type="string", default=",",
	 doc="separator (one character)"},
	{name="skip", type="number", default=0,
	 doc="skip this many lines at start of file (not used at the moment)"},
	{name="verbose", type="boolean", default=false,
	 doc="verbose load"},
	{name="nthreads", type="number", default=1,
	 doc="Number of threads to use to read the csv file"},
	call=function(self, path, header, schema, separator, skip, verbose, nthreads)

	-- TODO : implementing other method arguments (skip,separator,header)

	-- Remove previous data (reset init variables)
	self:_clean()

	if (verbose) then
		print("[INFO] Loading CSV")
	end

	local data_iterator = csvigo.load{path = path,
		            header = header,
		            separator = separator,
		            skip = skip,
		            verbose = verbose,
		            column_order = true,
		            mode = "large"}

	if (verbose) then
		print("[INFO] End loading CSV")
	end

	local column_order = {}
	local first_data_row = 2 -- In large mode first row is always the header (if there is one)

	if (header) then
		column_order = trim_table_strings(data_iterator[1])
	else
		-- If there is no header, first row to explore is set to the initial first row
		-- and column names are automatically generated
		first_data_row = 1

		for i=1,#data_iterator[1] do
			column_order[i] = "Column no. " .. i
		end
	end

	if (schema) then
		schema = schema.data
	else
		-- Tries to guess schema y exploring n rows
		schema = self:_infer_schema{
			iterator = data_iterator,
			first_data_row = first_data_row,
			column_order = Df_Array(column_order),
			rows2explore = rows2explore
		}
	end

	if (verbose) then
		print("Estimation number of rows : "..#data_iterator - first_data_row + 1)
	end

	-- Init a sized-Dataframe with the infered schema
	self:_init_with_schema{schema=Df_Dict(schema),column_order=Df_Array(column_order),number_rows=nrecs}

	local nfield= #data_iterator[1]-1-- number of columns in csv file
	local nrecs = #data_iterator-1-- number of lines in csv file

	local idx=torch.range(1,nrecs)
	local chunks=idx:chunk(nthreads)-- split data in chunks given a number of threads

	-- Create a tensor for each column given its schema and its size (nrecs) :
	-- chunk_data {
	--  "column1" : torch.*Tensor|tds.vec,
	--  "column2" : torch.*Tensor|tds.vec,
	--  "column3" : torch.*Tensor|tds.vec,
	--  "column4" : torch.*Tensor|tds.vec,
	-- }
	-- it will be used in at the end of each theads to store data chunks
	-- extracted in the thread
	local chunk_data = {}

	for i=1,#column_order do
		chunk_data[column_order[i]] = Dataseries.new_storage(nrecs,schema[column_order[i]])
	end

	-- nthreads is adapted to chunks effectively created
	nthreads = #chunks

	local t = threads.Threads(
		nthreads,
		function(threadn)
			if (verbose) then
				print("[INFO] Starting preprocessing")
			end

			require "csvigo"

			chunks=chunks
			path=path
			schema=schema
			separator=separator
			columns_order=column_order
			verbose=verbose
		end
	)

	data_iterator = nil
	collectgarbage()

	for j=1,nthreads do
		t:addjob(
			function()
				if (verbose) then
					print("[INFO] Start of thread n°"..__threadid)
				end

				require "Dataframe"

				local o=csvigo.load{path=path,mode='large',separator=separator,column_order=true,verbose=verbose}
				
				-- get the chunk corresponding to thread number
				local c=chunks[__threadid]

				-- create myData table, which is the same as chunk_data but for a single thread/chunk
				local myData = {}
				for i=1,#column_order do
					myData[column_order[i]] = Dataseries.new_storage(c:size(1),schema[column_order[i]])
				end

				local rec,loc
				-- for every row in the chunk
				for j=1,c:size(1) do
					rec=o[c[j]+1]-- extract data from the iterator 'o'
					-- rec as the following format : {"valueColumn1","valueColumn2",...}

					loc=c[j]-c[1]+1-- loc is the index of the row in the chunk

					-- store iterator values in myData var
					for i=1,#column_order do
						myData[column_order[i]][loc] = rec[i]
					end
				end

				collectgarbage()

				return myData,__threadid
			end,
			function(data,threadn)
				-- get the chunk data according to the position of the chunk in the whole dataset
				local s=chunks[threadn][1]
				local e=chunks[threadn][-1]
				
				for i=1,#column_order do
					-- If the column is a tensor, we use sub/copy tensor methods
					if (torch.type(data[column_order[i]]):match(("torch.*Tensor"))) then
						chunk_data[column_order[i]]:sub(s,e):copy(data[column_order[i]])
					-- If it is a tds.Vec, we copy row by row
					elseif (torch.type(data[column_order[i]]) == "tds.Vec") then
						for j=s,e do
							chunk_data[column_order[i]][j] = data[column_order[i]][j-s+1]
						end
					end
				end
			end
		)
	end

	t:synchronize()
	t:terminate()

	-- load chunk_data tensors in each dataset's columns
	for i=1,#column_order do
		self.dataset[column_order[i]]:load(chunk_data[column_order[i]])
	end

	if (verbose) then
		print("Finished loading data")
	end

	return self
end}

Dataframe._convert_val2_schema = argcheck{
	{name="schema_type", type="string"},
	{name="val", type="*", opt=true},
	call = function(schema_type, val)
	if (val == nil or torch.type(val) ~= "string") then
		return val
	end

	if(schema_type == "integer" or
		 schema_type == "long" or
		 schema_type == "double") then
		val = tonumber(val)

		if (val == nil) then
			val = 0/0
		end
	elseif(schema_type == "boolean") then
		local lwr_txt = val:lower()
		if (lwr_txt:match("^true$")) then
			val = true
		elseif(lwr_txt:match("^false$")) then
			val = false
		else
			print(("Invalid boolean value '%s' for row no. %d at column %s"):
						 format(val, csv_rowno, self.column_order[col_idx]))
		end
	elseif(schema_type == "string") then
		if (val == "") then
			val = 0/0
		end
	end

	return val
end}

Dataframe.load_table = argcheck{
	doc =  [[
<a name="Dataframe.load_table">
### Dataframe.load_table(@ARGP)

@ARGT

Imports a table data directly into Dataframe. The table should all be of equal length
or just single values. If a table contains one column with 10 rows and then has
another column with a single element that element is duplicated 10 times, i.e.
filling the entire column with that single value.


_Return value_: self
	]],
	{name="self", type="Dataframe"},
	{name="data", type="Df_Dict", doc="Table (dictionary) to import. Max depth 2."},
	{name="schema", type="Df_Dict", opt=true,
	 doc="Provide if you want to force column types"},
	{name="column_order", type="Df_Array", opt=true,
	 doc="The order of the column (has to be array and _not_ a dictionary)"},
	call=function(self, data, schema, column_order)
	self:_clean()
	data = data.data
	if (column_order) then
		column_order = column_order.data
	end

	if (schema) then
		schema = schema.data
	end

	data, column_order, schema =
		self:_clean_columns{data = data,
		                    column_order = column_order,
		                    schema = schema}
	-- Check that all columns with a no_rows > 1 has the same number of rows (no_rows)
	local no_rows = -1
	for k,v in pairs(data) do
		if (torch.type(v) == 'table') then
			if (no_rows > 1) then
				assert(no_rows == table.maxn(v),
				       "The number of rows of the provided tables do not match")
			else
				no_rows = math.max(no_rows, table.maxn(v))
			end
		elseif (torch.type(v):match("Dataseries")) then
			if (no_rows > 1) then
				assert(no_rows == #v,
				       "The number of rows of the provided tables do not match")
			else
				no_rows = math.max(no_rows, #v)
			end
		else
			no_rows = math.max(1, no_rows)
		end
	end
	assert(no_rows > 0, "Could not find any valid elements")

	if (not schema) then
		-- Get the data types from the data
		schema = self:_infer_schema{data = Df_Dict(data)}
	end

	if (column_order) then
		column_order = Df_Array(column_order)
	end

	-- Call the init with schema + no_rows
	self:__init{
		schema = Df_Dict(schema),
		no_rows = no_rows,
		column_order = column_order,
		set_missing = false
	}

	-- Copy the data into the columns
	for cn,col_vals in pairs(data) do
		local col_data = self:get_column(cn)
		for i=1,no_rows do
			local value
			if (type(col_vals) == "number" or
				 type(col_vals) == "boolean" or
				 type(col_vals) == "string") then
				value = col_vals
			else
				value = col_vals[i]
			end

			value = self._convert_val2_schema{
				schema_type = schema[cn],
				val = value
			}

			if (value == nil) then
				value = 0/0
			end

			col_data:set(i, value)
		end
	end

	return self
end}

Dataframe._clean_columns = argcheck{
	doc =  [[
<a name="Dataframe._clean_columns">
### Dataframe._clean_columns(@ARGP)

@ARGT

Internal function to clean columns names

_Return value_: self
	]],
	noordered=true,
	{name="self", type="Dataframe"},
	{name="data", type="table"},
	{name="column_order", type="table", opt=true},
	{name="schema", type="table", opt=true},
	call = function(self, data, column_order, schema)

	local ret_data = {}
	local cnames = {}
	for k,v in pairs(data) do
		local trimmed_column_name = trim(k)
		assert(ret_data[trimmed_column_name] == nil,
		       "The column name " .. trimmed_column_name ..
					 " appears more than once in your data")
		ret_data[trimmed_column_name] = v
		cnames[#cnames + 1] = trimmed_column_name
	end

	if (column_order) then
		column_order = trim_table_strings(column_order)

		assert(tables_equals(cnames, column_order, false, true),
		       "Column names don't match after string trimming")
	end

	if (schema) then
		local ret_schema = {}

		for k,v in pairs(schema) do
			local trimmed_column_name = trim(k)
			ret_schema[trimmed_column_name] = v
		end
		schema = ret_schema
	end

	return ret_data, column_order, schema
end}
