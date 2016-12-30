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

Checks if column is numerical

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name to check"},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):is_numerical()
end}

Dataframe.is_string = argcheck{
	doc = [[
<a name="Dataframe.is_string">
### Dataframe.is_string(@ARGP)

Checks if column is of string type

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name to check"},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):is_string()
end}

Dataframe.is_boolean = argcheck{
	doc = [[
<a name="Dataframe.is_boolean">
### Dataframe.is_boolean(@ARGP)

Checks if column is of boolean type

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name to check"},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):is_boolean()
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
	if (self.dataset[column_name]) then
		return true
	end
	return false
end}

Dataframe.assert_has_column = argcheck{
	doc = [[
<a name="Dataframe.assert_has_column">
### Dataframe.assert_has_column(@ARGP)

Asserts that column is in the dataset

@ARGT


_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to check"},
	{name="comment", type="string", doc="Comments that are to be displayed with the error",
	 default=""},
	call=function(self, column_name, comment)

	local has_col = self:has_column(column_name)
	if (not has_col) then
		-- The get_val_string is a little expensive and therefore better
		--  only do when the assertion actually fails
		local err_msg = ("The column '%s' doesn't exist among: %s"):
		 format(column_name, table.get_val_string(self.column_order))
		if (comment ~= "") then
			err_msg = err_msg .. ". " .. comment
		end
		assert(false, err_msg) -- Should probably use stop()
	end
end}

Dataframe.assert_has_not_column = argcheck{
	doc = [[
<a name="Dataframe.assert_has_not_column">
### Dataframe.assert_has_not_column(@ARGP)

Asserts that column is not in the dataset

@ARGT


_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to check"},
	{name="comment", type="string", doc="Comments that are to be displayed with the error",
	 default=""},
	call=function(self, column_name, comment)

	local has_col = self:has_column(column_name)
	if (has_col) then
		-- The get_val_string is a little expensive and therefore better
		--  only do when the assertion actually fails
		local err_msg = ("The column '%s' already exist among: %s"):
		 format(column_name, table.get_val_string(self.column_order))
		if (comment ~= "") then
			err_msg = err_msg .. ". " .. comment
		end
		assert(false, err_msg) -- Should probably use stop()
	end
end}

Dataframe.drop = argcheck{
	doc = [[
<a name="Dataframe.drop">
### Dataframe.drop(@ARGP)

@ARGT

Delete column from dataset

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to drop"},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	self.dataset[column_name] = nil

	-- Drop the column from the column_order
	local col_ordr = {}
	for i=1,#self.column_order do
		if (self.column_order[i] ~= column_name) then
			table.insert(col_ordr, self.column_order[i])
		end
	end

	self.column_order = col_ordr

	if (table.exact_length(self.dataset) == 0) then
		self:__init()
	end

	return self
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

	return self
end}

Dataframe.add_column = argcheck{
	doc = [[
<a name="Dataframe.add_column">
### Dataframe.add_column(@ARGP)

Add new column to Dataframe. Automatically orders the column last, i.e. furthest to
the right.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to add"},
	{name="pos", type="number",
	 doc="The position to input the column at, 1 == furthest to the left",
	 default=-1},
	{name="default_value", type="number|string|boolean",
	 doc="The initial value for the elements",
	 default=0/0},
	{name="type", type="string",
	 doc="The type of column to add: integer, double, boolean or string",
	 opt=true},
	call=function(self, column_name, pos, default_value, type)
	if (not type) then
		if (isnan(default_value)) then
			type = "string"
		else
			type = get_variable_type(default_value)
		end
	end

	local column_data = Dataseries(self:size(1), type):fill(default_value)
	return self:add_column(column_name, pos, column_data)
end}

Dataframe.add_column = argcheck{
	doc = [[
If you have a column with values to add then directly input a tds.Vec

@ARGT

]],
	overload=Dataframe.add_column,
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to add"},
	{name="pos", type="number",
	 doc="The position to input the column at, 1 == furthest to the left",
	 default=-1},
	{name="column_data", type="Dataseries", doc="The data to be stored in the column"},
	call=function(self, column_name, pos, column_data)
	assert(isint(pos), "The pos should be an integer, you provided: " .. tostring(pos))

	self:assert_has_not_column(column_name)

	if (self:size(1) == 0) then
		self.n_rows = #column_data
	else
		assert(#column_data == self.n_rows,
		       ('The number of default values (%s) don\'t match the number of rows in dataset %d'):
		       format(#column_data, self.n_rows))
	end

	-- We copy the entire tds as there is otherwise a risk of accidental overwrite
	--  by reference
	self.dataset[column_name] = column_data:copy()

	-- Insert/append column order
	if (pos > 0 and pos <= #self.column_order) then
		table.insert(self.column_order, pos, column_name)
	else
		table.insert(self.column_order, column_name)
	end

	return self
end}

Dataframe.cbind =  argcheck{
	doc = [[
Bind data columnwise together

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="data", type="Dataframe", doc="The other dataframe to bind"},
	call=function(self, data)
	assert(self:size(1) == data:size(1),
		("The number of rows don't match %d ~= %d"):format(self:size(1), data:size(1)))
	for i=1,#data.column_order do
		self:assert_has_not_column(data.column_order[i])
	end

	for i=1,#data.column_order do
		self:add_column(data.column_order[i],
		                data:get_column(data.column_order[i]))
	end

	return self
end}

Dataframe.cbind =  argcheck{
	doc = [[

@ARGT

]],
	overload=Dataframe.cbind,
	{name="self", type="Dataframe"},
	{name="data", type="Df_Dict", doc="The other data to bind"},
	call=function(self, data)
	local df = Dataframe.new()
	df:load_table(data)
	return self:cbind(df)
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
	self:assert_has_column(column_name)

	local column_data = self.dataset[column_name]
	assert(column_data, "Data column " .. column_name .. " not present!")

	assert(not as_tensor or
	       column_data:is_numerical(),
	       "Converting to tensor requires a numerical/categorical variable." ..
	       " The column " .. column_name ..
	       " is of type " .. column_data:type(	))

	if (as_raw and column_data:is_categorical()) then
		return column_data:from_categorical(Df_Array(column_data:to_table()))
	elseif (as_tensor) then
		return column_data:to_tensor()
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

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The columns to reset'},
	{name='new_value', type='number|string|boolean', doc='New value to set', default=0/0},
	call=function(self, columns, new_value)
	columns = columns.data
	for i=1,#columns do
		self:reset_column(columns[i], new_value)
	end

	return self
end}

Dataframe.reset_column = argcheck{
	doc = [[

@ARGT

]],
	overload=Dataframe.reset_column,
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The column requested'},
	{name='new_value', type='number|string|boolean|nan', doc='New value to set',
	 default=0/0},
	call=function(self, column_name, new_value)
	self:assert_has_column(column_name)

	self.dataset[column_name]:fill(new_value)

end}

Dataframe.rename_column = argcheck{
	doc = [[
<a name="Dataframe.rename_column">
### Dataframe.rename_column(@ARGP)

Rename a column

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name='old_column_name', type='string', doc='The old column name'},
	{name='new_column_name', type='string', doc='The new column name'},
	call=function(self, old_column_name, new_column_name)
	self:assert_has_column(old_column_name)
	self:assert_has_not_column(new_column_name)
	assert(type(new_column_name) == "string" or
	       type(new_column_name) == "number",
	       "The column name can only be a number or a string value, yours is: " .. type(new_column_name))

	self.dataset[new_column_name] = self.dataset[old_column_name]
	self.dataset[old_column_name] = nil

	for k,v in pairs(self.column_order) do
		if v == old_column_name then
			self.column_order[k] = new_column_name
		end
	end

	return self
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

	self:assert_has_column(column_name)

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

Dataframe.swap_column_order = argcheck{
	doc = [[
<a name="Dataframe.swap_column_order">
### Dataframe.swap_column_order(@ARGP)

Swaps the column order for two columns

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="first", type="string", doc="The name of the first column"},
	{name="second", type="string", doc="The name of the second column"},
	call=function(self, first, second)

	self:assert_has_column(first)
	self:assert_has_column(second)

	local pos_first, pos_second
	for i,column_name in ipairs(self.column_order) do
		if (column_name == first) then
			pos_first = i
			if (pos_second) then
				break
			end
		end

		if (column_name == second) then
			pos_second = i
			if (pos_first) then
				break
			end
		end
	end

	self.column_order[pos_first] = second
	self.column_order[pos_second] =  first

	return self
end}

Dataframe.pos_column_order = argcheck{
	doc = [[
<a name="Dataframe.pos_column_order">
### Dataframe.pos_column_order(@ARGP)

Set a position in the column order

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The name of the column"},
	{name="position", type="number", doc="An integer that indicates the position to insert at"},
	call=function(self, column_name, position)

	self:assert_has_column(column_name)
	assert(isint(position), "Position has to be an integer")
	-- Avoid indexing outside of range
	position = math.max(1, math.min(position, #self.column_order))

	local current_pos
	for i,cn in ipairs(self.column_order) do
		if (cn == column_name) then
			current_pos = i
			break
		end
	end

	if (current_pos ~= position) then
		-- We must delete and reset numbering before we can insert the column at the intended position
		self.column_order[current_pos] = nil
		local tmp = {}
		for _,cn in pairs(self.column_order) do
			tmp[#tmp + 1] = cn
		end
		table.insert(tmp, position, column_name)

		self.column_order = tmp
	end

	return self
end}

Dataframe.boolean2tensor = argcheck{
	doc = [[
<a name="Dataframe.boolean2tensor">
### Dataframe.boolean2tensor(@ARGP)

Converts a boolean column into a torch.ByteTensor of type integer

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string",
	 doc="The boolean column that you want to convert"},
	{name="false_value", type="number",
	 doc="The numeric value for false"},
	{name="true_value", type="number",
	 doc="The numeric value for true"},
	call=function(self, column_name, false_value, true_value)
	self:assert_has_column(column_name)

	self:get_column(column_name):boolean2tensor{
		false_value = false_value,
		true_value = true_value
	}

	return self
end}
