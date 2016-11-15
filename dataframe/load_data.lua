require 'csvigo'
tds = require 'tds'

local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

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
	-- Remove previous data
	self:_clean()

	local data_iterator = csvigo.load{path = path,
		            header = header,
		            separator = separator,
		            skip = skip,
		            verbose = verbose,
		            column_order = true,
		            mode = "large"}

	local first_data_row = 2
	if (header) then
		column_order = data_iterator[1]
	else
		first_data_row = 1
		column_order = {}
		for i in 1,len(data_iterator[1]) do
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
		schema = self:_infer_csvigo_schema{
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

	self:__init{
		-- Call the init with schema + no_rows
		schema = Df_Dict(schema),
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
					schema_type = schema[self.column_order[col_idx]],
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
	call=function(self, data, infer_schema, column_order)
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
		schema = self:_infer_data_schema{data = Df_Dict(data)}
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
