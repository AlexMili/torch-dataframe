-- Main Dataframe file
require 'torch'
require 'csvigo'
require 'dok'

-- create class object
local Dataframe = torch.class('Dataframe')

-- construct a new Dataframe
--
-- ARGS: -csv_or_data (optional) [string|table] : Path to CSV file or a data table for loading initial data
--
-- Returns: a new Dataframe object
function Dataframe:__init(csv_or_data)
	-- See https://github.com/torch/dok/issues/13
	--
	-- local args = dok.unpack(
	-- 	{...},
	-- 	'Dataframe.__init',
	-- 	'Initializes dataframe object',
	-- 	{arg='csv_or_data', type='string|table', help='Path to CSV file or a data table for loading initial data', req=false})
	
	self:_clean()
	self.print = {no_rows = 10, max_col_width = 20}

	if (csv_or_data) then
		if (type(csv_or_data) == 'string') then
			self:load_csv{path=csv_or_data,verbose=false}
		elseif(type(csv_or_data) == 'table') then
			self:load_table{data=csv_or_data}
		else
			error("Invalid data field type: " .. type(args.csv_or_data))
		end
	end
end

-- Private function for cleaning and reseting all data and meta data
function Dataframe:_clean()
	self.dataset = {}
	self.columns = {}
	self.column_order = {}
	self.n_rows = 0
	self.categorical = {}
	self.schema = {}
end

-- Private function for copying core settings to new Dataframe
function Dataframe:_copy_meta(to)
	to.column_order = clone(self.column_order)
	to.schema = clone(self.schema)
	to.print = clone(self.print)
	to.categorical = clone(self.categorical)

	return to
end

-- Internal function to collect columns names
function Dataframe:_refresh_metadata()
	keyset={}
	rows = -1

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
end

-- Internal function to detect columns types
function Dataframe:_infer_schema(max_rows)
	rows_to_explore = math.min(max_rows or 1e3, self.n_rows)

	for _,key in pairs(self.columns) do
		is_a_numeric_column = true
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
end

--
-- is_numerical(column_name) : checks if column is numerical
--
-- ARGS: - column_name (required) [string]: the column to check
--
-- RETURNS: boolean
function Dataframe:is_numerical(column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	return self.schema[column_name] == "number"
end

--
-- shape() : give the number of rows and columns
--
-- ARGS: nothing
--
-- RETURNS: {rows=x,cols=y}
--
function Dataframe:shape()
	return {rows=self.n_rows,cols=#self.columns}
end

--
-- drop('column_name') : delete column from dataset
--
-- ARGS: - column_name (required) [string]	: column to delete
--
-- RETURNS: nothing
--
function Dataframe:drop(column_name)
	assert(self:has_column(column_name), "The column " .. column_name .. " doesn't exist")
	self.dataset[column_name] = nil
	temp_dataset = {}
	-- Slightly crude method but can't get self.dataset == {} to works
	--   and #self.dataset is always == 0
	local empty = true
	for k,v in pairs(self.dataset) do
		if k ~= column_name then
			temp_dataset[k] = v
			empty = false
		end
	end

	if (not empty) then
		self.dataset = temp_dataset
		self.categorical[column_name] = nil
		self:_refresh_metadata()
	else
		self:__init()
	end
end

--
-- add_column('column_name', 0) : add new column to Dataframe
--
-- ARGS: - column_name 		(required) 				[string]	: column name to add
--		 - default_value 	(optional, default=0) 	[any]		: column default value
--
-- RETURNS: nothing
--
function Dataframe:add_column(column_name, default_value)
	assert(not self:has_column(column_name), "The column " .. column_name .. " already exists in the dataset")

	if (type(default_value) == 'table') then
		assert(table.maxn(default_value) == self.n_rows,
		       'The default values don\'t match the number of rows')
	elseif (default_value == nil) then
		default_value =  0/0
	end

	self.dataset[column_name] = {}
	for i = 1, self.n_rows do
		if (type(default_value) == 'table') then
			val = default_value[i]
			if (val == nil) then
				val = 0/0
			end
			self.dataset[column_name][i] = val
		else
			self.dataset[column_name][i] = default_value
		end
	end
	table.insert(self.column_order, column_name)
	self:_refresh_metadata()
end

function Dataframe:has_column(column_name)
	for _,v in pairs(self.columns) do
    if (v == column_name) then
			return true
		end
  end
	return false
end

--
-- get_column('column_name') : get column content
--
-- ARGS: - column_name (required) [string] : column requested
--       - as_raw      (optional) [boolean]: if data should be converted to actual values
--
-- RETURNS: column in table format
--
function Dataframe:get_column(...)
	local args = dok.unpack(
		{...},
		'Dataframe.get_column',
		'Gets the column data from the self.dataset',
		{arg='column_name', type='table', help='column requested', req=true},
		{arg='as_raw', type='boolean', help='convert categorical values to original', default=false},
		{arg='as_tensor', type='boolean', help='convert to tensor', default=false}
	)
	assert(self:has_column(args.column_name), "Could not find column: " .. tostring(args.column_name))
	assert(not args.as_tensor or
	       self:is_numerical(args.column_name),
				 "Converting to tensor requires a numerical/categorical variable." ..
				 " The column " .. tostring(args.column_name) ..
				 " is of type " .. tostring(self.schema[args.column_name]))
	if (self:has_column(args.column_name)) then
		column_data = self.dataset[args.column_name]
		if (not args.as_tensor and
		    not args.as_raw and
		    self:is_categorical(args.column_name)) then
			return self:to_categorical(column_data, args.column_name)
		else
			if (args.as_tensor) then
				return torch.Tensor(column_data)
			else
				return column_data
			end
		end
	else
		return nil
	end
end

--
-- insert({['first_column']={6,7,8,9},['second_column']={6,7,8,9}}) : insert values to dataset
--
-- ARGS: - rows (required) [table] : data to inset
--
-- RETURNS: nothing
--
function Dataframe:insert(rows)
	assert(type(rows) == 'table')
	no_rows_2_insert = 0
	new_columns = {}
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

		-- Check if we need to add this column to the existing Dataframe
		found = false
		for _,column_name in pairs(self.columns) do
			if (column_name == k) then
				found = true
				break
			end
		end
		if (not found) then
			table.insert(new_columns, k)
		end
	end

	if (#self.columns == 0) then
		self:load_table{data = rows}
		return nil
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
	-- We need to add columns previously not present
	for _, column_name in pairs(new_columns) do
		self.dataset[column_name] = {}
		for j = 1,self.n_rows do
			self.dataset[column_name][j] = 0/0
		end
		for j = 1,no_rows_2_insert do
			self.dataset[column_name][self.n_rows + j] = rows[column_name][j]
		end
	end
	self:_refresh_metadata()
	self:_infer_schema()
end

--
-- reset_column('column_name', 'new_value') : change value of a whole column
--
-- ARGS: - column_name 	(required)	[string or table]	: column(s) name to change
--		 - new_value 	(required) 	[any]				: new value to set
--
-- RETURNS: nothing
--
function Dataframe:reset_column(column_name, new_value)
	if type(column_name) == 'string' then
		column_name = {column_name}
	end
	for _,k in pairs(column_name) do
		assert(self:has_column(k), "Could not find column: " .. tostring(k))
		for i = 1,self.n_rows do
			self.dataset[k][i] = new_value
		end
	end
end

--
-- remove_index('index') : deletes a row
--
-- ARGS: - index (required) [integer] : delete a row number
--
-- RETURNS: nothing
--
function Dataframe:remove_index(index)
	assert(isint(index), "The index should be an integer, you've provided " .. tostring(index))
	for i = 1,#self.columns do
		table.remove(self.dataset[self.columns[i]],index)
	end
	self:_refresh_metadata()
end

--
-- rename_column('oldname', 'newName') : rename column
--
-- ARGS: - old_column_name 		(required)	[string]	: current column name
--		 - new_default_value 	(required) 	[string]	: new column name
--
-- RETURNS: nothing
--
function Dataframe:rename_column(old_column_name, new_column_name)
	assert(self:has_column(old_column_name), "Could not find column: " .. tostring(old_column_name))
	assert(not self:has_column(new_column_name), "There is already a column named: " .. tostring(new_column_name))
	assert(type(new_column_name) == "string" or
	       type(new_column_name) == "number",
				 "The column name can only be a number or a string value, yours is: " .. type(new_column_name))

	temp_dataset = {}

	for k,v in pairs(self.dataset) do
		if k ~= old_column_name then
			temp_dataset[k] = v
		else
			temp_dataset[new_column_name] = v
		end
	end

	self.dataset = temp_dataset
	if (self:is_categorical(old_column_name)) then
		self.categorical[new_column_name] = self.categorical[old_column_name]
		self.categorical[old_column_name] = nil
	end
	self:_refresh_metadata()
	self:_infer_schema()
end

--
-- get_numerical_colnames() : Gets the names of all the columns that are numerical
--
-- ARGS: none
--
-- RETURNS: table
--
function Dataframe:get_numerical_colnames()
	columns = {}

	for i = 1,#self.column_order do
		k = self.column_order[i]
		if (self:is_numerical(k)) then
			table.insert(columns, k)
		end
	end

	return columns
end

--
-- get_column_no : Gets the column number of the provided column
--
-- ARGS: - column_name (required) [string] : the name of the column
--       - as_tensor (optional) [boolaen] : if return index position in tensor
--
-- RETURNS: integer
function Dataframe:get_column_no(...)
	local args = dok.unpack(
		{...},
		'Dataframe.get_column_no',
		'Gets the index number of the column name',
		{arg='column_name', type='string', help='the name of the column', req=true},
		{arg='as_tensor', type='boolean', help='if return index position in tensor', default=false}
	)
	number_count = 0
	for i = 1,#self.column_order do
		column_name = self.column_order[i]
		if (self.schema[column_name] == "number") then
			number_count = number_count + 1
		end
		if (args.column_name == column_name) then
			if (args.as_tensor and
			    self:is_numerical(column_name)) then
				return number_count
			elseif (not args.as_tensor) then
				return i
			else
				-- Defaults to nil since the variable isn't in the tensor and therefore
				-- irrelevant
				break
			end
		end
	end
	return nil
end

--
-- unique() : get unique elements given a column name
--
-- ARGS: - see dok.unpack
--
-- RETURNS : table with unique values or if as_keys == true then the unique value
--           as key with an incremental integer value => {'unique1':1, 'unique2':2, 'unique6':3}
--
function Dataframe:unique(...)
	local args = dok.unpack(
		{...},
		'Dataframe.unique',
		'get unique elements given a column name',
		{arg='column_name', type='string', help='column to inspect', req=true},
		{arg='as_keys', type='boolean',
		 help='return table with unique as keys and a count for frequency',
		 default=false},
		{arg='as_raw', type='boolean',
 		 help='return table with raw data without categorical transformation',
 		 default=false}
	)
	assert(self:has_column(args.column_name),
	       "Invalid column name: " .. tostring(args.column_name))
	unique = {}
	unique_values = {}
	count = 0

	column_values = self:get_column{column_name = args.column_name,
																	as_raw = args.as_raw}
	for i = 1,self.n_rows do
		current_key_value = column_values[i]
		if (current_key_value ~= nil and
		    not isnan(current_key_value)) then
			if (unique[current_key_value] == nil) then
				count = count + 1
				unique[current_key_value] = count

				if args.as_keys == false then
					table.insert(unique_values, current_key_value)
				end
			end
		end
	end

	if args.as_keys == false then
		return unique_values
	else
		return unique
	end
end

-- Internal function for getting raw value for a categorical variable
function Dataframe:_get_raw_cat_key(column_name, key)
	if (isnan(key)) then
		return key
	end
	keys = self:get_cat_keys(column_name)
	if (keys[key] ~= nil) then
		return keys[key]
	end

	return self:add_cat_key(column_name, key)
end

--
-- get_row(index_row): gets a single row from the Dataframe
--
-- ARGS: - index_row (required) (integer) The row to fetch
--
-- RETURNS: A table with the row content
function Dataframe:get_row(index_row)
	assert(index_row > 0 and
	      index_row <= self:shape()["rows"],
				"Cannot fetch rows outside the matrix, i.e. " .. index_row .. " should be <= " .. self:shape()["rows"] .. " and positive")
	row = {}

	for index,key in pairs(self.columns) do
		if (self:is_categorical(key)) then
			row[key] = self:to_categorical(self.dataset[key][index_row],
			                               key)
		else
			row[key] = self.dataset[key][index_row]
		end
	end

	return row
end

return Dataframe
