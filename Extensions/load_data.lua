require 'csvigo'
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

_Return value_: void
	]],
	{name="self", type="Dataframe"},
	{name="path", type="string", doc="path to file"},
	{name="header", type="boolean", doc="if has header on first line", default=true},
	{name="infer_schema", type="boolean", help="automatically detect column's type", default=true},
	{name="separator", type="string", help="separator (one character)", default=","},
	{name="skip", type="number", help="skip this many lines at start of file", default=0},
	{name="verbose", type="boolean", help="verbose load", default=false},
	call=function(self, path, header, infer_schema, separator, skip, verbose)
	-- Remove previous data
	self:_clean()

	self.column_order,self.dataset =
		csvigo.load{path = path,
		            header = header,
		            separator = separator,
		            skip = skip,
		            verbose = verbose,
		            column_order = true}

	self:_clean_columns()
	self.column_order = trim_table_strings(self.column_order)
	self:_refresh_metadata()

	if infer_schema then
		self:_infer_schema()
	else
		-- Default value for self.schema
		for key,value in pairs(self.column_order) do
			self.schema[value] = 'number'
		end
	end

	-- Change all missing values to nan
	self:_fill_missing()
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
```

_Return value_: void
	]],
	{name="self", type="Dataframe"},
	{name="data", type="Df_Dict", doc="Table (dictionary) to import. Max depth 2."},
	{name="infer_schema", type="boolean", default=true,
	 doc="automatically detect columns' type"},
	{name="column_order", type="Df_Array", default=false,
	 doc="The order of the column (has to be array and _not_ a dictionary)"},
	call=function(self, data, infer_schema, column_order)
	self:_clean()
	data = data.data
	if (column_order) then
		column_order = column_order.data
	end

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

	count = 0
	for k,v in pairs(data) do
		count = count + 1
		self.column_order[count] = trim(k)

		-- if there is only one value for this column we need to duplicate the value to all next rows
		if (type(v) ~= 'table') then
			-- Populate the table if single value has been provided
			tmp = {}
			for i = 1,length do
				tmp[i] = v
			end
			self.dataset[k] = tmp
		else
			self.dataset[k] = clone(v) --TODO: Should we check if all elements are single values?
		end
	end

	if column_order then column_order = trim_table_strings(column_order) end
	self:_clean_columns()

	if (column_order and not tables_equals(column_order,self.column_order)) then
		no_cols = table.exact_length(self.dataset)
		assert(#column_order == no_cols,
		       "The length of the column order " .. #column_order ..
		       " should be the same as the data " .. no_cols)

		for i = 1,no_cols do
			assert(column_order[i] ~= nil, "The column order should be continous." ..
			       " Could not find column no. " .. i)

			found = false
			for k,v in pairs(self.dataset) do
				if (k == column_order[i]) then
					found = true
					break
				end
			end
			assert(found, "Could not find the order column name " .. column_order[i] ..
			              " in the data columns")
		end

		self.column_order = column_order
	end

	self:_refresh_metadata()

	if infer_schema then
		self:_infer_schema()
	else
		-- Default value for self.schema
		for key,value in pairs(self.column_order) do
			self.schema[value] = 'number'
		end
	end

	-- Change all missing values to nan
	self:_fill_missing()
end}

Dataframe._clean_columns = argcheck{
	doc =  [[
<a name="Dataframe._clean_columns">
### Dataframe._clean_columns(@ARGP)

@ARGT

Internal function to clean columns names

_Return value_: void
	]],
	{name="self", type="Dataframe"},
	call = function(self)

	temp_dataset = {}
	for k,v in pairs(self.dataset) do
		trimmed_column_name = trim(k)
		assert(temp_dataset[trimmed_column_name] == nil,
		       "The column name " .. trimmed_column_name ..
					 " appears more than once in your data")
		temp_dataset[trimmed_column_name] = v
	end

	self.dataset = temp_dataset
end}

-- Count missing values
Dataframe._count_missing = argcheck{
	doc =  [[
<a name="Dataframe._count_missing">
### Dataframe._count_missing(@ARGP)

@ARGT

Internal function for counting all missing values. _Note_: internally Dataframe
uses nan (0/0) and this function only identifies missing values within an array.
This is used within the test cases.

_Return value_: number of missing values (integer)
	]],
	{name="self", type="Dataframe"},
	call = function(self)
	counter = 0
	for index,col in pairs(self.columns) do
		for i = 1,self.n_rows do
			if (self.dataset[col][i] == nil) then
				counter = counter + 1
			end
		end
	end

	return counter
end}

-- Fill missing values with NaN value
Dataframe._fill_missing = argcheck{
	doc =  [[
<a name="Dataframe._fill_missing">
### Dataframe._fill_missing(@ARGP)

@ARGT

Internal function for changing missing values to NaN values.

_Return value_: void
	]],
	{name="self", type="Dataframe"},
	call = function(self)
	for index,col in pairs(self.columns) do
		for i = 1,self.n_rows do
			-- In CSV mode - only needed by number columns because the nil value
			--  is due to tonumber() from _infer_schema()
			if (self.dataset[col][i] == nil and self.schema[col] == 'number') then
				self.dataset[col][i] = 0/0
			-- In table mode only - TODO: Check if this is correct, maybe better to use 0/0 here as well
			elseif (self.dataset[col][i] == nil and self.schema[col] == 'string') then
				self.dataset[coll][i] = 'n/a'
			end
		end
	end
end}
