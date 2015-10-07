-- Dataframe.lua

require 'torch'
require 'csvigo'

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
--		 - infer_schema 	(optional, default=true)	[boolean] 	: automatically detect columns type
--		 - separator 		(optional, default=',')		[string] 	: if has header on first line
--		 - skip			 	(optional, default=0) 		[number] 	: if has header on first line
-- 
-- RETURNS: nothing
-- 
function Dataframe:load_csv(options)
	if options == nil then
		error('Argument missing in Dataframe:load()')
		options = {}
	end

	self.dataset = {}
	self.columns = {}
	self.n_rows = 0

	local args = {}

	if options.path == nil then
		error('File name is missing in Dataframe:load()')
	end

	if type(options.header) == 'boolean' then args.header = options.header else args.header = true end
	if type(options.infer_schema) == 'boolean' then args.infer_schema = options.infer_schema else args.infer_schema = true end

	args.path = options.path
	args.separator = options.separator or ","
	args.skip = options.skip or 0

	self.dataset = csvigo.load{path=args.path,header=args.header,separator=args.separator,skip=args.skip}
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
function Dataframe:load_table(options)
	if options == nil then
		error('Argument missing in Dataframe:load()')
		options = {}
	end

	self.dataset = {}
	self.columns = {}
	self.n_rows = 0

	if type(options.data) ~= 'table' then
		error('Provided data must be table type')
	end

	if type(options.infer_schema) == 'boolean' then options.infer_schema = options.infer_schema else options.infer_schema = false end

	self.dataset = options.data

	self:_clean_columns()
	self:_refresh_metadata()

	if options.infer_schema then self:_infer_schema() end
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
	self.dataset[column_name] = nil

	temp_dataset = {}

	for k,v in pairs(self.dataset) do
		if k ~= column_name then
			temp_dataset[k] = v
		end
	end

	self.dataset = temp_dataset
	self:_refresh_metadata()
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
	default = default_value or 0
	self.dataset[column_name] = {}

	for i = 1, self.n_rows do
		self.dataset[column_name][i] = default
	end

	self:_refresh_metadata()
end

-- 
-- get_column('columnName') : get column content
-- 
-- ARGS: - column_name (required) [string] : column needed
-- 
-- RETURNS: column in table format
-- 
function Dataframe:get_column(column_name)
	return self.dataset[column_name]
end

-- 
-- insert({['first_column']={6,7,8,9},['second_column']={6,7,8,9}}) : insert values to dataset
-- 
-- ARGS: - rows (required) [table] : data to inset
-- 
-- RETURNS: nothing
-- 
function Dataframe:insert(rows)
	previous_size = 0
	n_columns = 0

	for k,v in pairs(rows) do
		size = 0

		if type(v) == 'table' then
			size = #v
		else
			size = 1
		end

		if previous_size == 0 then
			previous_size = size
		elseif size ~= previous_size then
			error('columns must have the same size')
		end

		n_columns = n_columns + 1
	end

	if n_columns ~= #self.columns then
		error('all columns must be present')
	end

	for k,v in pairs(rows) do
		if type(v) == 'table' then
			for i = 1,#v do
				table.insert(self.dataset[k], v[i])
			end
		else
			table.insert(self.dataset[k], v)
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

-- 
-- to_tensor() : convert dataset to tensor
-- 
-- ARGS: - filename (optional) [string] : path where save thensor, if missing the tensor is only returned by the function
-- 
-- RETURNS: torch.tensor
-- 
function Dataframe:to_tensor(filename)
	numeric_dataset = self:_get_numerics()
	tensor_data = torch.Tensor(self.n_rows,#numeric_dataset)
	i = 1

	for k,v in ipairs(numeric_dataset) do
		next_col =  torch.Tensor(numeric_dataset[k])
		tensor_data[{{},i}] = next_col
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
function Dataframe:to_csv(filename, sep)
	sep = sep or ','

	csvigo.save{path=filename,data=self.dataset,separator=sep}
end

-- 
-- head() : only display the table's first elements
-- 
-- ARGS: - n_items 			(required) [number] 	: items to print
-- 		 - html 			(optional) [boolean] 	: display or not in html mode
-- 
-- RETURNS: table
-- 
function Dataframe:head(n_items, html)
	if type(html) ~= 'boolean' then html = false end
	n_items = n_items or 10
	head = {}

	for i = 1, n_items do
		for index,key in pairs(self.columns) do
			if type(head[key]) == 'nil' then head[key] = {} end
			head[key][i] = self.dataset[key][i]
		end
	end

	if html then
		itorch.html(self:_to_html(head))
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
function Dataframe:tail(n_items, html)
	if type(html) ~= 'boolean' then html = false end
	n_items = n_items or 10
	tail = {}

	for i = self.n_rows - n_items, self.n_rows do
		for index,key in pairs(self.columns) do
			if type(tail[key]) == 'nil' then tail[key] = {} end
			tail[key][i] = self.dataset[key][i]
		end
	end

	if html then
		itorch.html(self:_to_html(tail, self.n_rows-10+1, self.n_rows))
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
-- ARGS: - column_name (required) [string] : column to inspect
-- 
-- RETURNS : table with unique values in key with the value 1 => {'unique1':1, 'unique2':1, 'unique6':1}
function Dataframe:unique(column_name, as_keys)
	if type(as_keys) ~= 'boolean' then as_keys = true end
	unique = {}
	unique_values = {}

	for i = 1,self.n_rows do
		current_key_value = self.dataset[column_name][i]

		if type(unique[current_key_value]) == 'nil' then
			unique[current_key_value] = 0

			if as_keys == false then
				table.insert(unique_values, current_key_value)
			end
		end
	end

	if as_keys == false then
		return unique_values
	else
		return unique
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
