require 'dok'
local params = {...}
local Dataframe = params[1]

--
-- sub() : Selects a subset of rows and returns those
--
-- ARGS: - start 			(optional) [number] 	: row to start at
-- 		   - stop 			(optional) [number] 	: last row to include
--
-- RETURNS: Dataframe
--
function Dataframe:sub(...)
	local args = dok.unpack(
		{...},
		'Dataframe.sub',
		'Retrieves a subset of elements',
		{arg='start', type='integer', help='row to start at', default=1},
		{arg='stop', type='integer', help='row to stop at', default=self.n_rows}
	)
	assert(args.start <= args.stop, "Stop argument can't be less than the start argument")
	assert(args.start > 0, "Start position can't be less than 1")
	assert(args.stop <= self.n_rows, "Stop position can't be more than available rows")

	indexes = {}
	for i = args.start,args.stop do
		table.insert(indexes, i)
	end
	return self:_create_subset(indexes)
end

--
-- get_random ('n_items') : Retrieves a random number of rows for exploring
--
-- ARGS: - n_items (optional) [integer] : number of rows to get
--
-- RETURNS: Dataframe
function Dataframe:get_random(...)
	local args = dok.unpack(
		{...},
		'Dataframe.get_random',
		'Retrieves a random number of rows for exploring',
		{arg='n_items', type='integer', help='The number of items to retreive', default=1}
	)
	assert(isint(args.n_items), "The number must be an integer. You've provided " .. tostring(args.n_items))
	assert(args.n_items > 0 and
	       args.n_items < self.n_rows, "The number must be an integer between 0 and " ..
				 self.n_rows .. " - you've provided " .. tostring(args.n_items))
	local rperm = torch.randperm(self.n_rows)
	local indexes = {}
	for i = 1,args.n_items do
		table.insert(indexes, rperm[i])
	end
	return self:_create_subset(indexes)
end

--
-- head() : get the table's first elements
--
-- ARGS: - n_items 			(required) [number] 	: items to print
--
-- RETURNS: Dataframe
--
function Dataframe:head(...)
	local args = dok.unpack(
		{...},
		'Dataframe.head',
		'Retrieves the first elements of a table',
		{arg='n_items', type='integer', help='The number of items to display', default=10}
	)
	head = self:sub(1, math.min(args.n_items, self.n_rows))
	return head
end

--
-- tail() : get the table's last elements
--
-- ARGS: - n_items 			(required) [number] 	: items to print
--
-- RETURNS: Dataframe
--
function Dataframe:tail(...)
	local args = dok.unpack(
		{...},
		'Dataframe.tail',
		'Retrieves the last elements of a table',
		{arg='n_items', type='integer', help='The number of items to display', default=10},
		{arg='html', type='boolean', help='Display as html', default=false}
	)
	start_pos = math.max(1, self.n_rows - args.n_items + 1)
	tail = self:sub(start_pos)
	return tail
end

-- Creates a class and returns a subset based on the index items
function Dataframe:_create_subset(index_items)
	if (type(index_items) ~= 'table') then
		index_items = {index_items}
	end

	for _,i in pairs(index_items) do
		assert(isint(i) and
		 			 i > 0 and
					 i <= self.n_rows,
					 "There are values outside the allowed index range 1 to " .. self.n_rows ..
					 ": " .. tostring(i))
	end

	-- TODO: for some reason the categorical causes errors in the loop, this strange copy fixes it
	tmp = clone(self.categorical)
	self.categorical = {}
	ret = Dataframe.new()
	for _,i in pairs(index_items) do
		val = self:get_row(i)
		ret:insert(val)
	end
	self.categorical = tmp
	ret = self:_copy_meta(ret)
	return ret
end


--
-- where('column_name','my_value') : find the first row where the column has the given value
--
-- ARGS: - column 		(required) [string] : column to browse or a condition_function that
--                                          takes a row and returns true/false depending
--                                          on the row values
--		 - item_to_find (required) [string] : value to find
--
-- RETURNS : Dataframe
--
function Dataframe:where(column, item_to_find)
	if (type(column) ~= 'function') then
		condition_function = function(row)
			return row[column] == item_to_find
		end
	else
		condition_function = column
	end

	local matches = self:_where(condition_function)
	return self:_create_subset(matches)
end

--
-- _where(column, item_to_find)
--
-- ARGS: - condition_function 	(required) [func] : function to test if the current row will be updated
--
-- RETURNS : table with the index of all the matches
--
function Dataframe:_where(condition_function)
	local matches = {}
	for i = 1, self.n_rows do
		local row = self:get_row(i)
		if condition_function(row) then
			table.insert(matches, i)
		end
	end

	return matches
end

--
-- update(function(row) row['column'] == 'test' end, function(row) row['other_column'] = 'new_value' return row end) : Update according to condition
--
-- ARGS: - condition_function 	(required) [func] : function to test if the current row will be updated
--		 - update_function 		(required) [func] : function to update the row
--
-- RETURNS : nothing
--
function Dataframe:update(condition_function, update_function)
	local matches = self:_where(condition_function)
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
