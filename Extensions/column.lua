require 'dok'
local params = {...}
local Dataframe = params[1]

--
-- is_numerical(column_name) : checks if column is numerical
--
-- ARGS: - column_name (required) [string]: the column to check
--
-- RETURNS: boolean
--
function Dataframe:is_numerical(column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	return self.schema[column_name] == "number"
end

--
-- has_column(column_name) : checks if column exist
--
-- ARGS: - column_name (required) [string]: the column to check
--
-- RETURNS: boolean
--
function Dataframe:has_column(column_name)
	for _,v in pairs(self.columns) do
		if (v == column_name) then
			return true
		end
	end
	return false
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
	
	column_data = self.dataset[args.column_name]

	if (not args.as_tensor and not args.as_raw and
	    self:is_categorical(args.column_name)) then
		return self:to_categorical(column_data, args.column_name)
	elseif (args.as_tensor) then
		return torch.Tensor(column_data)
	else
		return column_data
	end
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

	for k,v in pairs(self.column_order) do
		if v == old_column_name then
			self.column_order[k] = new_column_name
		end
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
-- get_column_order : Gets the column index of the provided column
--
-- ARGS: - column_name (required) [string] : the name of the column
--       - as_tensor (optional) [boolaen] : if return index position in tensor
--
-- RETURNS: integer
function Dataframe:get_column_order(...)
	local args = dok.unpack(
		{...},
		'Dataframe.get_column_order',
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