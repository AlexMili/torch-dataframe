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

@ARGT

Loads a CSV file into Dataframe using csvigo as backend

_Return value_: self
	]],
	{name="self", type="Dataframe"},
	{name="path", type="string", doc="path to file"},
	{name="header", type="boolean", doc="if has header on first line", default=true},
	{name="schema", type="Df_Array", help="The column types if known",
		default=Df_Array()},
	{name="separator", type="string", help="separator (one character)", default=","},
	{name="skip", type="number", help="skip this many lines at start of file", default=0},
	{name="verbose", type="boolean", help="verbose load", default=false},
	call=function(self, path, header, schema, separator, skip, verbose)
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
		self.column_order = data_iterator[1]
	else
		first_data_row = 1
		self.column_order = {}
		for i in 1,len(data_iterator[1]) do
			self.column_order[i] = "Column no. " .. i
		end
	end

	self.schema = schema.data
	if (table.exact_length(self.schema) > 0) then
		assert(table.exact_length(self.schema) ==
		       table.exact_length(self.column_order),
		       "The column types must be of the same length as the columns")
	else
		self:_infer_csvigo_schema{
			iterator = data_iterator,
			first_data_row = first_data_row
		}
	end

	self.n_rows = #data_iterator - first_data_row + 1
	self:_init_dataset()

	local data_rowno = 0
	for csv_rowno=first_data_row,#data_iterator do
		data_rowno = data_rowno + 1
		local row = data_iterator[csv_rowno]
		for col_idx=1,#row do
			-- Clean the value according to the indicated data types
			local val = row[col_idx]
			if (val == "") then
				val = 0/0
			elseif(self.schema[col_idx] == "integer" or
			       self.schema[col_idx] == "long" or
			       self.schema[col_idx] == "double") then
				val = tonumber(val)
			elseif(self.schema[col_idx] == "boolean") then
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

			self.dataset[self.column_order[col_idx]]:set(data_rowno, val)
		end
	end

	self.dataset, self.column_order, self.schema =
		self:_clean_columns{data = self.dataset,
		                    column_order = self.column_order,
		                    schema = self.schema}

	return self
end}

Dataframe._init_dataset = argcheck{
	{name="self", type="Dataframe"},
	call=function(self)
	assert(self.n_rows ~= nil and self.n_rows > 0,
	       "The self.n_rows hasn't been initialized")
	assert(table.exact_length(self.schema) > 0, "The schema hasn't been deduced yet")
	assert(#self.column_order == table.exact_length(self.schema),
	       ("The schema (%d entries) doesn't match the number of columns (%d)"):
	       format(#self.column_order, table.exact_length(self.schema)))

	self.dataset = {}
	for i=1,#self.column_order do
		local cn = self.column_order[i]
		self.dataset[cn] = Dataseries(self.n_rows, self.schema[cn])
	end

	return self
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

	-- Check that all columns with a length > 1 has the same number of rows (length)
	local length = -1
	for k,v in pairs(data) do
		if (type(v) == 'table') then
			if (length > 1) then
				assert(length == table.maxn(v),
				       "The length of the provided tables do not match")
			else
				length = math.max(length, table.maxn(v))
			end
			else
			length = math.max(1, length)
		end
	end
	assert(length > 0, "Could not find any valid elements")
	self.n_rows = length

	-- Get the column order set-up
	local co = {}
	for cn,_ in pairs(data) do
		co[#co + 1] = cn
	end
	if (column_order) then
		if (not tables_equals(co, column_order, false, true)) then
			assert(false, "The column order and names in the provided data don't match")
		end
		self.column_order = column_order
	else
		self.column_order = co
	end

	if (schema) then
		-- Some sanity checks
		for _,cn in ipairs(self.column_order) do
			assert(schema[cn], "Schema not defined for column: " .. cn)
		end

		for cn,_ in pairs(self.schema) do
			assert(data[cn], "There is no data for schema column: " .. cn)
		end

		self.schema = schema
	else
		-- Get the data types from the data
		self:_infer_schema{data = Df_Dict(data)}
	end

	-- Init the columns in the column order according to types
	self:_init_dataset()

	-- Copy the data into the columns
	for cn,col_vals in pairs(data) do
		for i=1,self.n_rows do
			local value
			if (type(col_vals) == "number" or
				 type(col_vals) == "boolean" or
				 type(col_vals) == "string") then
				value = col_vals
			else
				value = col_vals[i]
			end
			if (value == nil) then
				value = 0/0
			end
			self.dataset[cn]:set(i, value)
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
