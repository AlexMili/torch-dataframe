	-- Main Dataframe file
require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Core functions

]]

-- create class object
local Dataframe = torch.class('Dataframe')

Dataframe.__init = argcheck{
	doc =  [[
<a name="Dataframe.__init">
### Dataframe.__init(@ARGP)

Creates and initializes a Dataframe class. Envoked through `local my_dataframe = Dataframe()`

@ARGT

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	call=function(self)
	self:_clean()
	self.print = {no_rows = 10, max_col_width = 20}
end}

Dataframe.__init = argcheck{
	doc =  [[
Read in an csv-file

@ARGT

_Return value_: Dataframe
]],
	overload=Dataframe.__init,
	{name="self", type="Dataframe"},
	{name="csv_file", type="string", doc="The file path to the CSV"},
	call=function(self, csv_file)
	self:__init()
	self:load_csv{path=csv_file,verbose=false}
end}

Dataframe.__init = argcheck{
	doc =  [[
Directly input a table

@ARGT

_Return value_: Dataframe
]],
	overload=Dataframe.__init,
	{name="self", type="Dataframe"},
	{name="data", type="Df_Dict", doc="The data to read in"},
	call=function(self, data)
	self:__init()
	self:load_table{data=data,verbose=false}
end}

-- Private function for cleaning and reseting all data and meta data
Dataframe._clean = argcheck{
	{name="self", type="Dataframe"},
	call=function(self)
	self.dataset = {}
	self.columns = {}
	self.column_order = {}
	self.n_rows = 0
	self.categorical = {}
	self.schema = {}
end}

-- Private function for copying core settings to new Dataframe
Dataframe._copy_meta = argcheck{
	{name="self", type="Dataframe"},
	{name="to", type="Dataframe", doc="The Dataframe to copy to"},
	call=function(self, to)
	to.column_order = clone(self.column_order)
	to.schema = clone(self.schema)
	to.print = clone(self.print)
	to.categorical = clone(self.categorical)

	return to
end}

-- Internal function to collect columns names
Dataframe._refresh_metadata = argcheck{
	{name="self", type="Dataframe"},
	call=function(self)

	local keyset={}
	local rows = -1
	for k,v in pairs(self.dataset) do
		table.insert(keyset, k)

		-- handle the case when there is only one value for the entire column
		local no_rows_in_v = 1
		if (type(v) == 'table') then
			no_rows_in_v = table.maxn(v)
		end

		if (rows == -1) then
			rows = no_rows_in_v
		else
		 	assert(rows == no_rows_in_v,
			       "It seems that the number of elements in row " ..
			       k .. " (# " .. no_rows_in_v .. ")" ..
			       " don't match the number of elements in other rows #" .. rows)
		 end
	end

	self.columns = keyset
	self.n_rows = rows
end}

-- Internal function to detect columns types
Dataframe._infer_schema = argcheck{
	{name="self", type="Dataframe"},
	{name="max_rows", type="number", doc="The maximum number of rows to traverse", default=1e3},
	call=function(self, max_rows)
	local rows_to_explore = math.min(max_rows, self.n_rows)

	for _,key in pairs(self.columns) do
		local is_a_numeric_column = true
		self.schema[key] = 'string'
		if (self:is_categorical(key)) then
			self.schema[key] = 'number'
		else
			for i = 1, rows_to_explore do
				-- If the current cell is not a number and not nil (in case of empty cell, type inference is not compromised)
				local val = self.dataset[key][i]
				if tonumber(val) == nil and
				  val ~= nil and
					val ~= '' and
					not isnan(val)
					then
					is_a_numeric_column = false
					break
				end
			end

			if is_a_numeric_column then
				self.schema[key] = 'number'
				for i = 1, self.n_rows do
					self.dataset[key][i] = tonumber(self.dataset[key][i])
				end
			end
		end
	end
end}

--
-- shape() : give the number of rows and columns
--
-- ARGS: nothing
--
-- RETURNS: {rows=x,cols=y}
--
Dataframe.shape = argcheck{
	doc =  [[
<a name="Dataframe.shape">
### Dataframe.shape(@ARGP)

Returns the number of rows and columns in a table

@ARGT

_Return value_: table
]],
	{name="self", type="Dataframe"},
	call=function(self)
	return {rows=self.n_rows,cols=#self.columns}
end}

Dataframe.size = argcheck{
	doc =  [[
<a name="Dataframe.size">
### Dataframe.size(@ARGP)

Returns the number of rows and columns in a tensor

@ARGT

_Return value_: tensor (rows, columns)
]],
	{name="self", type="Dataframe"},
	call=function(self)
	return torch.IntTensor({self.n_rows,#self.columns})
end}

Dataframe.size = argcheck{
	doc =  [[
By providing dimension you can get only that dimension, row == 1, col == 2

@ARGT

_Return value_: integer
]],
	overload=Dataframe.size,
	{name="self", type="Dataframe"},
	{name="dim", type="number", doc="The dimension of interest"},
	call=function(self, dim)
	assert(isint(dim), "The dimension isn't an integer: " .. tostring(dim))
	assert(dim == 1 or dim == 2, "The dimension can only be between 1 and 2 - you've provided: " .. dim)
	if (dim == 1) then
		return self.n_rows
	end

	return #self.columns
end}

Dataframe.insert = argcheck{
	doc =  [[
<a name="Dataframe.insert">
### Dataframe.insert(@ARGP)

Inserts a row or multiple rows into database. Automatically appends to the Dataframe.

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="rows", type="Df_Dict", doc="Insert values to the dataset"},
	call=function(self, rows)
	rows = rows.data
	if (self:size(1) == 0) then
		return self:load_table{data = Df_Dict(rows)}
	end

	local no_rows_2_insert = 0
	local new_columns = {}
	for k,v in pairs(rows) do
		-- Force all input into tables
		if (type(v) ~= 'table') then
			v = {v}
			rows[k] = v
		end

		-- Check input size
		if (no_rows_2_insert == 0) then
			no_rows_2_insert = table.maxn(v)
		else
			assert(no_rows_2_insert == table.maxn(v),
			       "The rows aren't the same between the columns." ..
			       " The " .. k .. " column has " .. " " .. table.maxn(v) .. " rows" ..
			       " while previous columns had " .. no_rows_2_insert .. " rows")
		end

		if (not table.has_element(self.columns, k)) then
			self:add_column(k)
		end
	end

	for _, column_name in pairs(self.columns) do
		-- If the column is not currently inserted by the user
		if rows[column_name] == nil then
			-- Default rows are inserted with nan values (0/0)
			for j = 1,no_rows_2_insert do
				table.insert(self.dataset[column_name], 0/0)
			end
		else
			for j = 1,no_rows_2_insert do
				value = rows[column_name][j]
				if (self:is_categorical(column_name) and
				    not isnan(value)) then
					vale = self:_get_raw_cat_key(column_name, value)
				end -- TODO: Should we convert string columns with '' to nan?
				self.dataset[column_name][self.n_rows + j] = value
			end
		end
	end

	self:_refresh_metadata()
	self:_infer_schema()
end}

Dataframe.remove_index = argcheck{
	doc =  [[
<a name="Dataframe.remove_index">
### Dataframe.remove_index(@ARGP)

Deletes a given row

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="index", type="number", doc="The row index to remove"},
	call=function(self, index)
	assert(isint(index), "The index should be an integer, you've provided " .. tostring(index))
	assert(index > 0 and index <= self.n_rows, ("The index (%d) is outside the bounds 1-%d"):format(index, self.n_rows))

	for i = 1,#self.columns do
		table.remove(self.dataset[self.columns[i]],index)
	end
	self.n_rows = self.n_rows - 1

	self:_refresh_metadata()
end}

Dataframe.unique = argcheck{
	doc =  [[
<a name="Dataframe.unique">
### Dataframe.unique(@ARGP)

Get unique elements given a column name

@ARGT

_Return value_:  table with unique values or if as_keys == true then the unique
	value as key with an incremental integer value => {'unique1':1, 'unique2':2, 'unique6':3}
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', help='column to inspect', req=true},
	{name='as_keys', type='boolean',
	 help='return table with unique as keys and a count for frequency',
	 default=false},
	{name='as_raw', type='boolean',
	 help='return table with raw data without categorical transformation',
	 default=false},
	call=function(self, column_name, as_keys, as_raw)
	assert(self:has_column(column_name),
	       "Invalid column name: " .. tostring(column_name))
	local unique = {}
	local unique_values = {}
	local count = 0

	local column_values = self:get_column{column_name = column_name,
																	as_raw = as_raw}
	for i = 1,self.n_rows do
		local current_key_value = column_values[i]
		if (current_key_value ~= nil and
		    not isnan(current_key_value)) then
			if (unique[current_key_value] == nil) then
				count = count + 1
				unique[current_key_value] = count

				if as_keys == false then
					table.insert(unique_values, current_key_value)
				end
			end
		end
	end

	if as_keys == false then
		return unique_values
	else
		return unique
	end
end}

-- Internal function for getting raw value for a categorical variable
Dataframe._get_raw_cat_key = argcheck{
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The name of the column"},
	{name="key", type="number|string|boolean|nan"},
	call=function(self, column_name, key)
	if (isnan(key)) then
		return key
	end

	local keys = self:get_cat_keys(column_name)
	if (keys[key] ~= nil) then
		return keys[key]
	end

	return self:add_cat_key(column_name, key)
end}

Dataframe.get_row = argcheck{
	doc =  [[
<a name="Dataframe.get_row">
### Dataframe.get_row(@ARGP)

Gets a single row from the Dataframe

@ARGT

_Return value_: A table with the row content
]],
	{name="self", type="Dataframe"},
	{name='index', type='number', doc='The row index to retrieve'},
	call=function(self, index)
	assert(isint(index), "The index should be an integer, you've provided " .. tostring(index))
	assert(index > 0 and index <= self.n_rows, ("The index (%d) is outside the bounds 1-%d"):format(index, self.n_rows))

	local row = {}
	for _,key in pairs(self.columns) do
		if (self:is_categorical(key)) then
			row[key] = self:to_categorical(self.dataset[key][index],
			                               key)
		else
			row[key] = self.dataset[key][index]
		end
	end

	return row
end}

return Dataframe
