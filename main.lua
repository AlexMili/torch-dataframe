-- Main Dataframe file
require 'torch'
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
			self:load_table{data=Df_Dict(csv_or_data)}
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
		self:load_table{data = Df_Dict(rows)}
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
