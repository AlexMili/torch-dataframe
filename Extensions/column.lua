local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Column functions

]]

Dataframe.is_numerical = argcheck{
	doc = [[
<a name="Dataframe.is_numerical">
### Dataframe.is_numerical(@ARGP)

@ARGT

Checks if column is numerical

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name to check"},
	call=function(self, column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	return self.schema[column_name] == "number"
end}

Dataframe.has_column = argcheck{
	doc = [[
<a name="Dataframe.has_column">
### Dataframe.has_column(@ARGP)

@ARGT

Checks if column is present in the dataset

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to check"},
	call=function(self, column_name)
	for _,v in pairs(self.columns) do
		if (v == column_name) then
			return true
		end
	end
	return false
end}

Dataframe.drop = argcheck{
	doc = [[
<a name="Dataframe.drop">
### Dataframe.drop(@ARGP)

@ARGT

Delete column from dataset

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to drop"},
	call=function(self, column_name)
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

	-- Drop the column from the column_order
	local col_ordr = {}
	for i=1,#self.column_order do
		if (self.column_order[i] ~= column_name) then
			table.insert(col_ordr, self.column_order[i])
		end
	end

	if (not empty) then
		self.dataset = temp_dataset
		self.categorical[column_name] = nil
		self:_refresh_metadata() -- TODO: Merge column_order with columns
	else
		self:__init()
	end
end}

Dataframe.drop = argcheck{
	doc = [[
You can also delete multiple columns by supplying a Df_Array

@ARGT
]],
	overload=Dataframe.drop,
	{name="self", type="Dataframe"},
	{name="columns", type="Df_Array", doc="The columns to drop"},
	call=function(self, columns)
	columns = columns.data
	for i=1,#columns do
		self:drop(columns[i])
	end
end}

Dataframe.add_column = argcheck{
	doc = [[
<a name="Dataframe.add_column">
### Dataframe.add_column(@ARGP)

@ARGT

Add new column to Dataframe

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to add"},
	{name="default_value", type="number|string|boolean", doc="The default_value", default=0/0},
	call=function(self, column_name, default_value)
	-- Use nan as missing values
	if (default_value == nil) then
		default_value =  0/0
	end

	local default_values = {}
	for i=1,self.n_rows do
		table.insert(default_values, default_value)
	end
	self:add_column(column_name, Df_Array(default_values))
end}

Dataframe.add_column = argcheck{
	doc = [[
If you have a column with values to add then use the Df_Array

@ARGT

Add new column to Dataframe

_Return value_: void
]],
	overload=Dataframe.add_column,
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to add"},
	{name="default_values", type="Df_Array", doc="The default values"},
	call=function(self, column_name, default_values)
	assert(not self:has_column(column_name), "The column " .. column_name .. " already exists in the dataset")
	default_values = default_values.data

	assert(table.maxn(default_values) == self.n_rows,
	       'The default values don\'t match the number of rows')

	self.dataset[column_name] = {}
	for i = 1, self.n_rows do
		val = default_values[i]
		if (val == nil) then
			val = 0/0
		end
		self.dataset[column_name][i] = val
	end

	-- Append column order
	table.insert(self.column_order, column_name)
	self:_refresh_metadata()
end}

Dataframe.get_column = argcheck{
	doc = [[
<a name="Dataframe.get_column">
### Dataframe.get_column(@ARGP)

@ARGT

Gets the column from the `self.dataset`

_Return value_: table or tensor
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The column requested'},
	{name='as_raw', type='boolean', doc='Convert categorical values to original', default=false},
	{name='as_tensor', type='boolean', doc='Convert to tensor', default=false},
	call=function(self, column_name, as_raw, as_tensor)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	assert(not as_tensor or
	       self:is_numerical(column_name),
				 "Converting to tensor requires a numerical/categorical variable." ..
				 " The column " .. tostring(column_name) ..
				 " is of type " .. tostring(self.schema[column_name]))

	column_data = self.dataset[column_name]

	if (not as_tensor and not as_raw and
	    self:is_categorical(column_name)) then
		return self:to_categorical(Df_Array(column_data), column_name)
	elseif (as_tensor) then
		return torch.Tensor(column_data)
	else
		return column_data
	end
end}





Dataframe.reset_column = argcheck{
	doc = [[
<a name="Dataframe.reset_column">
### Dataframe.reset_column(@ARGP)

Change value of a whole column or columns

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The columns to reset'},
	{name='new_value', type='number|string|boolean', doc='New value to set', default=0/0},
	call=function(self, columns, new_value)
	columns = columns.data
	for i=1,#columns do
		self:reset_column(columns[i], new_value)
	end
end}

Dataframe.reset_column = argcheck{
	doc = [[

@ARGT

]],
	overload=Dataframe.reset_column,
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The column requested'},
	{name='new_value', type='number|string|boolean|nan', doc='New value to set', default=0/0},
	call=function(self, column_name, new_value)

	assert(self:has_column(k), "Could not find column: " .. tostring(k))
	for i = 1,self.n_rows do
		self.dataset[k][i] = new_value
	end
end}

Dataframe.rename_column = argcheck{
	doc = [[
<a name="Dataframe.rename_column">
### Dataframe.rename_column(@ARGP)

Rename a column

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='old_column_name', type='string', doc='The old column name'},
	{name='new_column_name', type='string', doc='The new column name'},
	call=function(self, old_column_name, new_column_name)
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
end}

Dataframe.get_numerical_colnames = argcheck{
	doc = [[
<a name="Dataframe.get_numerical_colnames">
### Dataframe.get_numerical_colnames(@ARGP)

Gets the names of all the columns that are numerical

@ARGT

_Return value_: table
]],
	{name="self", type="Dataframe"},
	call=function(self)
	local columns = {}
	for i = 1,#self.column_order do
		k = self.column_order[i]
		if (self:is_numerical(k)) then
			table.insert(columns, k)
		end
	end

	return columns
end}

Dataframe.get_column_order = argcheck{
	doc = [[
<a name="Dataframe.get_column_order">
### Dataframe.get_column_order(@ARGP)

Gets the column order index

@ARGT

_Return value_: integer
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The name of the column"},
	{name="as_tensor", type="boolean", doc="If return index position in tensor", default=false},
	call=function(self, column_name, as_tensor)

	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))

	number_count = 0
	for i = 1,#self.column_order do
		column_name = self.column_order[i]

		if (self.schema[column_name] == "number") then
			number_count = number_count + 1
		end

		if (column_name == column_name) then
			if (as_tensor and
			    self:is_numerical(column_name)) then
				return number_count
			elseif (not as_tensor) then
				return i
			else
				-- Defaults to nil since the variable isn't in the tensor and therefore
				-- irrelevant
				break
			end
		end
	end

	return nil
end}





Dataframe.reset_column = argcheck{
	doc = [[
<a name="Dataframe.reset_column">
### Dataframe.reset_column(@ARGP)

Change value of a whole column or columns

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The columns to reset'},
	{name='new_value', type='number|string|boolean', doc='New value to set', default=0/0},
	call=function(self, columns, new_value)
	columns = columns.data
	for i=1,#columns do
		self:reset_column(columns[i], new_value)
	end
end}

Dataframe.reset_column = argcheck{
	doc = [[

@ARGT

]],
	overload=Dataframe.reset_column,
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The column requested'},
	{name='new_value', type='number|string|boolean|nan', doc='New value to set', default=0/0},
	call=function(self, column_name, new_value)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(k))

	for i = 1,self.n_rows do
		self.dataset[column_name][i] = new_value
	end

end}

Dataframe.rename_column = argcheck{
	doc = [[
<a name="Dataframe.rename_column">
### Dataframe.rename_column(@ARGP)

Rename a column

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='old_column_name', type='string', doc='The old column name'},
	{name='new_column_name', type='string', doc='The new column name'},
	call=function(self, old_column_name, new_column_name)
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
end}

Dataframe.get_numerical_colnames = argcheck{
	doc = [[
<a name="Dataframe.get_numerical_colnames">
### Dataframe.get_numerical_colnames(@ARGP)

Gets the names of all the columns that are numerical

@ARGT

_Return value_: table
]],
	{name="self", type="Dataframe"},
	call=function(self)
	local columns = {}
	for i = 1,#self.column_order do
		k = self.column_order[i]
		if (self:is_numerical(k)) then
			table.insert(columns, k)
		end
	end

	return columns
end}

Dataframe.get_column_order = argcheck{
	doc = [[
<a name="Dataframe.get_column_order">
### Dataframe.get_column_order(@ARGP)

Gets the column order index

@ARGT

_Return value_: integer
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The name of the column"},
	{name="as_tensor", type="boolean", doc="If return index position in tensor", default=false},
	call=function(self, column_name, as_tensor)

	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))

	local number_count = 0
	for i = 1,#self.column_order do
		local cn = self.column_order[i]

		if (self:is_numerical(cn)) then
			number_count = number_count + 1
		end

		if (cn == column_name) then
			if (as_tensor and
			    self:is_numerical(cn)) then
				return number_count
			elseif (not as_tensor) then
				return i
			else
				-- Defaults to nil since the variable isn't in the tensor and therefore
				-- irrelevant
				return nil
			end
		end
	end

	return nil
end}
