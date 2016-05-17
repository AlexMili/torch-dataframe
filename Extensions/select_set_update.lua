local params = {...}
local Dataframe = params[1]


local argcheck = require "argcheck"

Dataframe.sub = argcheck{
	doc =  [[
<a name="Dataframe.sub">
### Dataframe.sub(@ARGP)

@ARGT

Selects a subset of rows and returns those

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	{name='start', type='number', doc='Row to start at', default=1},
	{name="stop", type='number', doc='Last row to include', default=false},
	call = function(self, start, stop)
	if (not stop) then
		stop = self.n_rows
	end

	assert(args.start <= args.stop, "Stop argument can't be less than the start argument")
	assert(args.start > 0, "Start position can't be less than 1")
	assert(args.stop <= self.n_rows, "Stop position can't be more than available rows")

	local indexes = {}
	for i = args.start,args.stop do
		table.insert(indexes, i)
	end

	return self:_create_subset(Df_Array(indexes))
end}

Dataframe.get_random = argcheck{
	doc =  [[
<a name="Dataframe.get_random">
### Dataframe.get_random(@ARGP)

@ARGT

Retrieves a random number of rows for exploring

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	{name='n_items', type='number', doc='Number of rows to retrieve', default=1},
	call = function(self, n_items)

	assert(isint(n_items), "The number must be an integer. You've provided " .. tostring(n_items))
	assert(n_items > 0 and
	       n_items < self.n_rows, "The number must be an integer between 0 and " ..
				 self.n_rows .. " - you've provided " .. tostring(n_items))
	local rperm = torch.randperm(self.n_rows)
	local indexes = {}
	for i = 1,n_items do
		table.insert(indexes, rperm[i])
	end
	return self:_create_subset(Df_Array(indexes))
end}

Dataframe.head = argcheck{
	doc =  [[
<a name="Dataframe.head">
### Dataframe.head(@ARGP)

@ARGT

Retrieves the first elements of a table

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	{name='n_items', type='number', doc='Number of rows to retrieve', default=10},
	call = function(self, n_items)

	head = self:sub(1, math.min(n_items, self.n_rows))

	return head
end}

Dataframe.tail = argcheck{
	doc =  [[
<a name="Dataframe.tail">
### Dataframe.tail(@ARGP)

@ARGT

Retrieves the last elements of a table

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	{name='n_items', type='number', doc='Number of rows to retrieve', default=10},
	call = function(self, n_items)

	start_pos = math.max(1, self.n_rows - args.n_items + 1)
	tail = self:sub(start_pos)

	return tail
end}

Dataframe._create_subset = argcheck{
	doc =  [[
<a name="Dataframe._create_subset">
### Dataframe._create_subset(@ARGP)

@ARGT

Creates a class and returns a subset based on the index items. Intended for internal
use.

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	{name='index_items', type='Df_Array', doc='The indexes to retrieve'},
	call = function(self, index_items)
	index_items = index_items.data

	for i=1,#index_items do
		local val = index_items[i]
		assert(isint(val) and
		       val > 0 and
		       val <= self.n_rows,
		       "There are values outside the allowed index range 1 to " .. self.n_rows ..
		       ": " .. tostring(val))
	end

	-- TODO: for some reason the categorical causes errors in the loop, this strange copy fixes it
	-- The above is most likely to global variables beeing overwritten due to lack of local definintions
	local tmp = clone(self.categorical)
	self.categorical = {}
	local ret = Dataframe.new()
	for _,i in pairs(index_items) do
		local val = self:get_row(i)
		ret:insert(val)
	end
	self.categorical = tmp
	ret = self:_copy_meta(ret)
	return ret
end}


--
-- where('column_name','my_value') :
--
-- ARGS: - column 		(required) [string] : column to browse or a condition_function that
--                                          takes a row and returns true/false depending
--                                          on the row values
--		 - item_to_find (required) [string] : value to find
--
-- RETURNS : Dataframe
--
Dataframe.where = argcheck{
	doc =  [[
<a name="Dataframe.where">
### Dataframe.where(@ARGP)

@ARGT

Find the rows where the column has the given value

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	{name='column', type='string',
	 doc='column to browse or findin the item argument'},
	{name='item_to_find', type='number|string|boolean',
	 doc='The value to find'},
	call = function(self, column, item_to_find)

	return self:where(function(row)
		return row[column] == item_to_find
	end)
end}

Dataframe.where = argcheck{
	doc =  [[
You can also provide a function for more advanced matching

@ARGT

]],
	{name="self", type="Dataframe"},
	{name='match_fn', type='function',
	 doc='Function that takes a row as an argument and returns boolean'},
	call = function(self, column, item_to_find)
	local matches = _where_search(self, condition_function)
	return self:_create_subset(Df_Array(matches))
end}

local _where_search = argcheck{
	{name="self", "Dataframe"},
	{name="condition_function", "function",
	 doc="Function to test if the current row will be updated"},
	call=function(self, condition_function)
		local matches = {}
		for i = 1, self.n_rows do
			local row = self:get_row(i)
			if condition_function(row) then
				table.insert(matches, i)
			end
		end

		return matches
	end
}

--
-- update(function(row) row['column'] == 'test' end, function(row) row['other_column'] = 'new_value' return row end) : Update according to condition
--
-- ARGS: - condition_function 	(required) [func] : function to test if the current row will be updated
--		 - update_function 		(required) [func] : function to update the row
--
-- RETURNS : nothing
--
function Dataframe:update(condition_function, update_function)
	local matches = _where_search(self, condition_function)
	for _, i in pairs(matches) do
		row = self:get_row(i)
		new_row = update_function(row)
		self:_update_single_row(i, new_row)
	end
end

--
-- set('my_value', 'column_name', 'new_value') : change value for a line
--
-- ARGS: - item_to_find 	(required)	[any]		: value to search
-- 		 - column_name 		(required) 	[string] 	: column where to search
--		 - new_value 		(required) 	[table]		: new value to set for the line
--
-- RETURNS: nothing
--
function Dataframe:set(item_to_find, column_name, new_value)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	temp_converted_cat_cols = {}
	column_data = self:get_column(column_name)
	for i = 1, self.n_rows do
		if column_data[i] == item_to_find then
			for _,k in pairs(self.columns) do
				-- If the column is being updated by the user
				if new_value[k] ~= nil then
					if (self:is_categorical(k)) then
						new_value[k] = self:_get_raw_cat_key(column_name, new_value[k])
					end
					self.dataset[k][i] = new_value[k]
				end
			end
			break
		end
	end
end

-- Internal function to update a single row from data and index
function Dataframe:_update_single_row(index_row, new_row)
	for _,key in pairs(self.columns) do
		if (self:is_categorical(key)) then
			new_row[key] = self:_get_raw_cat_key(key, new_row[key])
		end
		self.dataset[key][index_row] = new_row[key]
	end

	return row
end
