-- Dataframe.lua

require 'torch'
require 'csvigo'
require 'dok'

-- UTILS

function trim(s)
	local from = s:match"^%s*()"
	return s:match"^%s*()" > #s and "" or s:match(".*%S", s:match"^%s*()")
end

function clone(t) -- shallow-copy a table
	if type(t) ~= "table" then return t end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do target[k] = v end
	setmetatable(target, meta)
	return target
end

-- END UTILS


-- create class object
local Dataframe = torch.class('Dataframe')

-- construct a new Dataframe
--
-- Returns: a new Dataframe object
function Dataframe:__init()
	self.dataset = {}
	self.columns = {}
	self.schema = {}
	self.n_rows = 0
end

--
-- load_csv{path='path/to/file'} : load csv file
--
-- ARGS: - path 			(required) 					[string]	: Path to the CSV
--		 - header 			(optional, default=true) 	[boolean]	: if has header on first line
--		 - infer_schema 	(optional, default=true)	[boolean] 	:
--		 - separator 		(optional, default=',')		[string] 	: if has header on first line
--		 - skip			 	(optional, default=0) 		[number] 	:
--
-- RETURNS: nothing
--
function Dataframe:load_csv(...)
	self.dataset = {}
	self.columns = {}
	self.n_rows = 0

	local args = dok.unpack(
		{...},
		'Dataframe.load_csv',
		'Loads a CSV file into Dataframe using csvigo as backend',
		{arg='path', type='string', help='path to file', req=true},
		{arg='header', type='boolean', help='if has header on first line', default=true},
		{arg='infer_schema', type='boolean', help='automatically detect columns\' type', default=true},
		{arg='separator', type='string', help='separator (one character)', default=','},
		{arg='skip', type='number', help='skip this many lines at start of file', default=0},
		{arg='verbose', type='boolean', help='verbose load', default=true}
	)

	self.dataset = csvigo.load{path = args.path,
	                           header = args.header,
														 separator = args.separator,
														 skip = args.skip,
													   verbose = args.verbose}
	self:_clean_columns()
	self:_refresh_metadata()

	if args.infer_schema then self:_infer_schema() end
end

--
-- load_table{data=your_table} : load table in Dataframe
--
-- ARGS: - data 			(required) 					[string]	: table to import
--		 - infer_schema 	(optional, default=false)	[boolean] 	: automatically detect columns type
--
-- RETURNS: nothing
--
function Dataframe:load_table(...)

	self.dataset = {}
	self.columns = {}
	self.n_rows = 0

	local args = dok.unpack(
		{...},
		'Dataframe.load_table',
		'Imports a table directly data into Dataframe',
		{arg='data', type='table', help='table to import', req=true},
		{arg='infer_schema', type='boolean', help='automatically detect columns\' type', default=true}
	)

	self.dataset = args.data

	self:_clean_columns()
	self:_refresh_metadata()

	if args.infer_schema then self:_infer_schema() end
end

-- Internal function to clean columns names
function Dataframe:_clean_columns()
	temp_dataset = {}

	for k,v in pairs(self.dataset) do
		temp_dataset[trim(k)] = v
	end

	self.dataset = temp_dataset
end

-- Internal function to collect columns names
function Dataframe:_refresh_metadata()
	keyset={}
	n=0

	for k,v in pairs(self.dataset) do
		n=n+1
		keyset[n]=k
	end

	self.columns = keyset
	self.n_rows = #self.dataset[self.columns[1]]
end

-- Internal function to detect columns types
function Dataframe:_infer_schema(explore_factor)
	factor = explore_factor or 0.5
	rows_to_explore = math.ceil(self.n_rows * factor)

	for index,key in pairs(self.columns) do
		is_a_numeric_column = true
		self.schema[key] = 'string'

		for i = 1, rows_to_explore do
			-- If the current cell is not a number and not nil (in case of empty cell, type inference is not compromised)
			if tonumber(self.dataset[key][i]) == nil and self.dataset[key][i] ~= nil and self.dataset[key][i] ~= '' then
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

--
-- shape() : give the number of rows and columns
--
-- ARGS: nothing
--
-- RETURNS: {rows=x,cols=y}
--
function Dataframe:shape()
  return {rows=#self.dataset[self.columns[1]],cols=#self.columns}
end

--
-- drop('columnName') : delete column from dataset
--
-- ARGS: - column_name (required) [string]	: column to delete
--
-- RETURNS: nothing
--
function Dataframe:drop(column_name)
	if (not self:has_column(column_name)) then
		error("The column " .. column_name .. " doesn't exist")
	end
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
		self:_refresh_metadata()
	else
		self:__init()
	end
end

--
-- add_column('columnName', 0) : add new column to Dataframe
--
-- ARGS: - column_name 		(required) 				[string]	: column name to add
--		 - default_value 	(optional, default=0) 	[any]		: column default value
--
-- RETURNS: nothing
--
function Dataframe:add_column(column_name, default_value)
	if (self:has_column('column_name')) then
		error("The column " .. column_name .. " already exists in the dataset")
	end

  if (default_value ~= 0) then
		if (type(default_value) == 'table') then
			assert(#default_value == self.n_rows,
			       'The default values don\'t match the number of rows')
		end
		default_value = default_value
	else
		default_value =  0
	end

	self.dataset[column_name] = {}
	for i = 1, self.n_rows do
		if (type(default_value) == 'table') then
			self.dataset[column_name][i] = default_value[i]
		else
			self.dataset[column_name][i] = default_value
		end
	end

	self:_refresh_metadata()
end

function Dataframe:has_column(column_name)
	for k,v in pairs(self.columns) do
    if (v == column_name) then
			return true
		end
  end
	return false
end
--
-- get_column('columnName') : get column content
--
-- ARGS: - column_name (required) [string] : column needed
--
-- RETURNS: column in table format
--
function Dataframe:get_column(column_name)
	if (self:has_column(column_name)) then
		return self.dataset[column_name]
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
	max_rows_to_insert = 0

	for k,v in pairs(rows) do
		max_rows_to_insert = math.max(max_rows_to_insert, #rows[k])
	end

	for i = 1,#self.columns do
		-- If the column is not currently inserted by the user
		if rows[self.columns[i]] == nil then
			-- Default rows are inserted
			for j = 1,max_rows_to_insert do
				table.insert(self.dataset[self.columns[i]], 0)
			end
		else
			if #rows[self.columns[i]] < max_rows_to_insert then
				for j = 1,#rows[self.columns[i]] do
					table.insert(self.dataset[self.columns[i]], rows[self.columns[i]][j])
				end
				for i = #rows[self.columns[i]]+1,max_rows_to_insert do
					table.insert(self.dataset[self.columns[i]], rows[self.columns[i]][j])
				end
			else
				for j = 1,max_rows_to_insert do
					table.insert(self.dataset[self.columns[i]], rows[self.columns[i]][j])
				end
			end
		end
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
	for k in pairs(column_name) do
		for i = 1,self.n_rows do
			self.dataset[column_name[k]][i] = new_value
		end
	end
end


function Dataframe:remove_index(index)
	for i = 1,#self.columns do
		table.remove(self.dataset[self.columns[i]],index)
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
	temp_dataset = {}

	for k,v in pairs(self.dataset) do
		if k ~= old_column_name then
			temp_dataset[k] = v
		else
			temp_dataset[new_column_name] = v
		end
	end

	self.dataset = temp_dataset
	self:_refresh_metadata()
end

--
-- count_na() : count missing values in dataset
--
-- ARGS: nothing
--
-- RETURNS: table containing missing values per column
--
function Dataframe:count_na()
	count = {}

	for index,key in pairs(self.columns) do
		counter = 0
		for i = 1, self.n_rows do
			if self.dataset[key][i] == nil or self.dataset[key][i] == '' then
				counter = counter + 1
			end
		end
		count[key] = counter
	end

	return count
end

--
-- fill_na('columnName', 0) : replace missing value in a specific column
--
-- ARGS: - column_name 		(required) 				[string]	: column name to fill
--		 - default_value 	(optional, default=0) 	[any]		: default missing value
--
-- RETURNS: nothing
--
-- Enhancement : detect nil/na value at first reading or _infer_schema
function Dataframe:fill_na(column_name, default_value)
	default = default_value or 0

	for i = 1, self.n_rows do
		if self.dataset[column_name][i] == nil or self.dataset[column_name][i] == '' then
			self.dataset[column_name][i] = default
		end
	end
end

--
-- fill_all_na(0) : replace missing value in the whole dataset
--
-- ARGS: - default_value (optional, default=0) [any] : default missing value
--
-- RETURNS: nothing
--
-- Enhancement : detect nil/na value at first reading or _infer_schema
function Dataframe:fill_all_na(default_value)
	default = default_value or 0

	for index,key in pairs(self.columns) do
		for i = 1, self.n_rows do
			if self.dataset[key][i] == nil or self.dataset[key][i] == '' then
				self.dataset[key][i] = default
			end
		end
	end
end

-- Internal function to get all numerics columns
function Dataframe:_get_numerics()
	new_dataset = {}

	for k,v in pairs(self.dataset) do
		if self.schema[k] == 'number' then
			new_dataset[k] = v
		end
	end

	return new_dataset
end

function Dataframe:get_column_no(column_name)
	i = 0
	for k,v in pairs(self.dataset) do
		i = i + 1
		if (column_name == k) then
			return i
		end
	end
	return nil
end
--
-- to_tensor() : convert dataset to tensor
--
-- ARGS: - filename (optional) [string] : path where save tensor, if missing the tensor is only returned by the function
--
-- RETURNS: torch.tensor
--
function Dataframe:to_tensor(filename)
	numeric_dataset = self:_get_numerics()
	tensor_data = nil
	i = 1
	for k,v in pairs(numeric_dataset) do
		next_col =  torch.Tensor(numeric_dataset[k])
		if (torch.isTensor(tensor_data)) then
			tensor_data = torch.cat(tensor_data, next_col, 2)
		else
			tensor_data = next_col
		end
		i=i+1
	end

	if filename ~= nil then
		torch.save(filename, tensor_data)
	end

	return tensor_data
end

--
-- to_csv() : convert dataset to CSV file
--
-- ARGS: - filename 	(required) 				[string] : path where to save CSV file
-- 		 - separator 	(optional, default=',') [string]	: character to split items in one CSV line
--
-- RETURNS: nothing
--
function Dataframe:to_csv(...)
	local args = dok.unpack(
		{...},
		'Dataframe.to_csv',
		'Saves a Dataframe into a CSV using csvigo as backend',
		{arg='path', type='string', help='path to file', req=true},
		{arg='separator', type='string', help='separator (one character)', default=','},
		{arg='verbose', type='boolean', help='verbose load', default=true}
	)

	csvigo.save{path=args.path,data=self.dataset,
	            separator=args.separator,verbose=args.verbose}
end

--
-- head() : only display the table's first elements
--
-- ARGS: - n_items 			(required) [number] 	: items to print
-- 		 - html 			(optional) [boolean] 	: display or not in html mode
--
-- RETURNS: table
--
function Dataframe:head(...)
	local args = dok.unpack(
		{...},
		'Dataframe.head',
		'Retrieves the first elements of a table',
		{arg='n_items', type='integer', help='The number of items to display', default=10},
		{arg='html', type='boolean', help='Display as html', default=false}
	)
	head = {}
	for i = 1, args.n_items do
		for index,key in pairs(self.columns) do
			if type(head[key]) == 'nil' then head[key] = {} end
			head[key][i] = self.dataset[key][i]
		end
	end

	if args.html then
		itorch.html(self:_to_html{data=head})
	else
		return head
	end
end

--
-- tail() : only display the table's last elements
--
-- ARGS: - n_items 			(required) [number] 	: items to print
-- 		 - html 			(optional) [boolean] 	: display or not in html mode
--
-- RETURNS: table
--
function Dataframe:tail(...)
	local args = dok.unpack(
		{...},
		'Dataframe.tail',
		'Retrieves the last elements of a table',
		{arg='n_items', type='integer', help='The number of items to display', default=10},
		{arg='html', type='boolean', help='Display as html', default=false}
	)
	tail = {}

	start_pos = self.n_rows - args.n_items + 1
	if (start_pos < 1) then
		start_pos = 1
	end
	for i = start_pos, self.n_rows do
		for index,key in pairs(self.columns) do
			if type(tail[key]) == 'nil' then tail[key] = {} end
			tail[key][i] = self.dataset[key][i]
		end
	end

	if args.html then
		itorch.html(self:_to_html{data=tail, start_at=self.n_rows-10+1, end_at=self.n_rows})
	else
		return tail
	end
end

--
-- show() : print dataset
--
-- ARGS: nothing
--
-- RETURNS: nothing
--
function Dataframe:show()
	head = self:head()
	tail = self:tail()

	if itorch ~= nil then
		text = ''
		text = text..self:_to_html{data=head,split_table='bottom'}
		text = text..'<tr>'
		text = text..'<td><span style="font-size:20px;">...</span></td>' -- index cell
		for k,v in pairs(head) do
			text = text..'<td><span style="font-size:20px;">...</span></td>'
		end
		text = text..'</tr>'
		text = text..self:_to_html{data=tail, start_at=self.n_rows-10+1, end_at=self.n_rows, split_table='top'}

		itorch.html(text)
	else
		print(head)
		print('...')
		print(tail)
	end
end

--
-- unique() : get unique elements given a column name
--
-- ARGS: - column_name (required) [string] :
--
-- RETURNS : table with unique values in key with the value 1 => {'unique1':1, 'unique2':1, 'unique6':1}
--
function Dataframe:unique(...)
	local args = dok.unpack(
		{...},
		'Dataframe.unique',
		'get unique elements given a column name',
		{arg='column_name', type='string', help='column to inspect', req=true},
		{arg='as_keys', type='boolean',
		 help='return table with unique as keys and a count for frequency',
		 default=false}
	)
	unique = {}
	unique_values = {}

	for i = 1,self.n_rows do
		current_key_value = self.dataset[args.column_name][i]
		if (current_key_value ~= nil) then
			if type(unique[current_key_value]) == 'nil' then
				unique[current_key_value] = 1

				if args.as_keys == false then
					table.insert(unique_values, current_key_value)
				end
			else
				unique[current_key_value] = unique[current_key_value] + 1
			end
		end
	end

	if args.as_keys == false then
		return unique_values
	else
		return unique
	end
end

--
-- where('column_name','my_value') : find the first row where the column has the given value
--
-- ARGS: - column 		(required) [string] : column to browse
--		 - item_to_find (required) [string] : value to find
--
-- RETURNS : table
--
function Dataframe:where(column, item_to_find)
	for i = 1, self.n_rows do
		if self.dataset[column][i] == item_to_find then
			return self:_extract_row(i)
		end
	end

	return nil
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
	for i = 1, self.n_rows do
		row = self:_extract_row(i)

		if condition_function(row) then
			new_row = update_function(row)

			self:_update_single_row(i, new_row)
		end
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
	for i = 1, self.n_rows do
		if self.dataset[column_name][i] == item_to_find then
			for j = 1,#self.columns do
				-- If the column is being updated by the user
				if new_value[self.columns[j]] ~= nil then
					self.dataset[self.columns[j]][i] = new_value[self.columns[j]]
				end
			end
			break
		end
	end
end

-- Internal function to convert a table to html (only works for 1D table)
function Dataframe:_to_html(options)--data, start_at, end_at, split_table)
	options.split_table = options.split_table or 'none' -- none, top, bottom, all
	options.start_at = options.start_at or 1
	options.end_at = options.end_at or 10

	result = ''
	n_rows = 0

	if options.split_table ~= 'top' and options.split_table ~= 'all' then
		result = result.. '<table>'
	end

	if options.split_table ~= 'top' then
		result = result.. '<tr>'
		result = result.. '<th></th>'
		for k,v in pairs(options.data) do
			result = result.. '<th>' ..k.. '</th>'
			if n_rows == 0 then n_rows = #options.data[k] end
		end
		result = result.. '</tr>'
	end

	for i = options.start_at, options.end_at do
		result = result.. '<tr>'
		result = result.. '<td>'..i..'</td>'
		for k,v in pairs(options.data) do
			result = result.. '<td>' ..tostring(options.data[k][i]).. '</td>'
		end
		result = result.. '</tr>'
	end

	if options.split_table ~= 'bottom' and options.split_table ~= 'all' then
		result = result.. '</table>'
	end

	return result
end

-- Internal function to extract a row from the dataset
function Dataframe:_extract_row(index_row)
	row = {}

	for index,key in pairs(self.columns) do
		row[key] = self.dataset[key][index_row]
	end

	return row
end

-- Internal function to update a single row from data and index
function Dataframe:_update_single_row(index_row, new_row)
	for index,key in pairs(self.columns) do
		self.dataset[key][index_row] = new_row[key]
	end

	return row
end
