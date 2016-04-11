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

table.exact_length = function(tbl)
  i = 0
  for k,v in pairs(tbl) do
    i = i + 1
  end
  return i
end

function isint(n)
	return n == math.floor(n)
end

function isnan(n)
	return n ~= n
end

local function escapeCsv(s, separator)
   if string.find(s, '["' .. separator .. ']') then
   --if string.find(s, '[,"]') then
      s = '"' .. string.gsub(s, '"', '""') .. '"'
   end
   return s
end

-- convert an array of strings or numbers into a row in a csv file
local function tocsv(t, separator, column_order)
   local s = ""
	 for i=1,#column_order do
		 p = t[column_order[i]]
		 if (isnan(p)) then
			 p = ''
		 end
     s = s .. separator .. escapeCsv(p, separator)
   end
   return string.sub(s, 2) -- remove first comma
end

-- END UTILS


-- create class object
local Dataframe = torch.class('Dataframe')

-- construct a new Dataframe
--
-- Returns: a new Dataframe object
function Dataframe:__init()
	self:_clean{schema = true}
	self.print = {no_rows = 10,
								max_col_width = 20}
								sadsad = 1
end

-- Private function for cleaning all data
function Dataframe:_clean(...)
	local args = dok.unpack(
		{...},
		'Dataframe._clean',
		'Cleans and resets all data parameters',
		{arg='schema', type='boolean', help='Also clean schema', req=false})
	self.dataset = {}
	self.columns = {}
	self.column_order = {}
	self.n_rows = 0
	self.categorical = {}

  if (args.schema) then
		self.schema = {}
	end
end

-- Private function for copying core settings to new Dataframe
function Dataframe:_copy_meta(to)
	to.column_order = clone(self.column_order)
	to.schema = clone(self.schema)
	to.print = clone(self.print)
	to.categorical = clone(self.categorical)
	return to
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
	-- Remove previous data
	self:_clean()

	self.dataset = csvigo.load{path = args.path,
	                           header = args.header,
														 separator = args.separator,
														 skip = args.skip,
													   verbose = args.verbose}
	self:_clean_columns()
	self:_refresh_metadata()

	-- Change all missing values to nan
	for k,v in pairs(self.dataset) do
		for i = 1,self.n_rows do
			if (v[i] == nil or
			    v[i] == '') then
			  v[i] = 0/0
			end
		end
		self.dataset[k] = v
	end

	self.column_order = self:_getCsvHeaderOrder(args.path, args.separator)
	if args.infer_schema then self:_infer_schema() end
end

-- Returns the order of the original CSV
function Dataframe:_getCsvHeaderOrder(filepath, separator)
	file, msg = io.open(filepath, 'r')
	if not file then error("Could not open file") end
  local line = file:read()
	file:close()
	if not line then error("Could not read line") end
	line = line:gsub('\r', '')

	line = line .. separator -- end with separator
	if separator == ' ' then separator = '%s+' end
	local t = {}
	count = 0
	local fieldstart = 1
	repeat
		count = count + 1
		-- next field is quoted? (starts with "?)
	  if string.find(line, '^"', fieldstart) then
			local a, c
	    local i = fieldstart
	    repeat
	      -- find closing quote
	      a, i, c = string.find(line, '"("?)', i+1)
	    until c ~= '"'  -- quote not followed by quote?

	    if not i then error('unmatched "') end
			local f = string.sub(line, fieldstart+1, i-1)
	    t[count] = (string.gsub(f, '""', '"'))

			-- Move along the line to next separator
	    fieldstart = string.find(line, separator, i) + 1
	  else
	     local nexti = string.find(line, separator, fieldstart)
	     t[count] = string.sub(line, fieldstart, nexti-1)
	     fieldstart = nexti + 1
	  end
	until fieldstart > string.len(line)
	return t
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
	local args = dok.unpack(
		{...},
		'Dataframe.load_table',
		'Imports a table directly data into Dataframe',
		{arg='data', type='table', help='table to import', req=true},
		{arg='infer_schema', type='boolean', help='automatically detect columns\' type', default=true},
		{arg='column_order', type='table', help='The column order', req=false}
	)
	self:_clean()

	local length = -1
	for k,v in pairs(args.data) do
		if (type(v) == 'table') then
			if (length > 1) then
				assert(length == table.maxn(v),
				       "The length of the provided tables do not match")
			else
				length = math.max(length, table.maxn(v))
			end
		else
			length = math.max(1, length)
		end
	end
	assert(length > 0, "Could not find any valid elements")

	count = 0
	for k,v in pairs(args.data) do
		count = count + 1
		self.column_order[count] = k
		if (type(v) ~= 'table') then
			-- Populate the table if single value has been provided
			tmp = {}
			for i = 1,length do
				tmp[i] = v
			end
			self.dataset[k] = tmp
		else
			self.dataset[k] = v
		end
	end
	self:_clean_columns()

	if (args.column_order) then
		no_cols = table.exact_length(self.dataset)
		assert(#args.column_order == no_cols,
					"The length of the column order " .. #args.column_order ..
					" should be the same as the data " .. no_cols)
		for i = 1,no_cols do
			assert(args.column_order[i] ~= nil, "The column order should be continous." ..
			       " Could not find column no. " .. i)
			found = false
		  for k,v in pairs(self.dataset) do
				if (k == args.column_order[i]) then
					found = true
					break
				end
			end
			assert(found, "Could not find the order column name " .. args.column_order[i] ..
			              " in the data columns")
		end
		self.column_order = args.column_order
	end

	self:_refresh_metadata()
	if args.infer_schema then self:_infer_schema() end
end

-- Internal function to clean columns names
function Dataframe:_clean_columns()
	temp_dataset = {}

	for k,v in pairs(self.dataset) do
		trimmed_column_name = trim(k)
		assert(temp_dataset[trimmed_column_name] == nil,
		       "The column name " .. trimmed_column_name ..
					 " appears more than once in your data")
		temp_dataset[trimmed_column_name] = v
	end

	self.dataset = temp_dataset
end

-- Internal function to collect columns names
function Dataframe:_refresh_metadata()
	keyset={}
  rows = -1
	for k,v in pairs(self.dataset) do
		table.insert(keyset, k)

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
function Dataframe:_infer_schema(explore_factor)
	factor = explore_factor or 0.5
	rows_to_explore = math.ceil(self.n_rows * factor)

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
	assert(not self:has_column('column_name'), "The column " .. column_name .. " already exists in the dataset")

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
				if (self:is_categorical(column_name)) then
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


function Dataframe:remove_index(index)
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
-- count_na() : count missing values in dataset
--
-- ARGS: nothing
--
-- RETURNS: table containing missing values per column
--
function Dataframe:count_na()
	count = {}

	for _,column_name in pairs(self.columns) do
		counter = 0
		for i = 1, self.n_rows do
			local val = self.dataset[column_name][i]
			if val == nil or val == '' or isnan(val) then
				counter = counter + 1
			end
		end
		count[column_name] = counter
	end

	return count
end

--
-- fill_na('column_name', 0) : replace missing value in a specific column
--
-- ARGS: - column_name 		(required) 				[string]	: column name to fill
--		 - default_value 	(optional, default=0) 	[any]		: default missing value
--
-- RETURNS: nothing
--
-- Enhancement : detect nil/na value at first reading or _infer_schema
function Dataframe:fill_na(column_name, default_value)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	default = default_value or 0

	for i = 1, self.n_rows do
		local val = self.dataset[column_name][i]
		if val == nil or val == '' or isnan(val) then
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

	for _,key in pairs(self.columns) do
		self:fill_na(key, default_value)
	end
end

-- Internal function to get all numerics columns
function Dataframe:_get_numerics()
	new_dataset = {}

	for k,v in pairs(self.dataset) do
		if (self:is_numerical(k)) then
			new_dataset[k] = v
		end
	end

	return new_dataset
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
-- to_tensor() : convert dataset to tensor
--
-- ARGS: - filename (optional) [string] : path where save tensor, if missing the tensor is only returned by the function
--
-- RETURNS: torch.tensor
--
function Dataframe:to_tensor(filename)
	numeric_dataset = self:_get_numerics()
	tensor_data = nil
	count = 1
	for col_no = 1,#self.column_order do
		found = false
		column_name = self.column_order[col_no]
		for k,v in pairs(numeric_dataset) do
			if (k == column_name) then
				found = true
				break
			end
		end
		if (found) then
			next_col =  torch.Tensor(numeric_dataset[column_name])
			if (torch.isTensor(tensor_data)) then
				tensor_data = torch.cat(tensor_data, next_col, 2)
			else
				tensor_data = next_col
			end
			count = count + 1
		end
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

	file, msg = io.open(args.path, 'w')
	if not file then error("Could not open file") end
	for i = 0,self.n_rows do
		if (i == 0) then
			row = {}
			for _,k in pairs(self.columns) do
				row[k] = k
			end
		else
			row = self:get_row(i)
		end
		res, msg = file:write(tocsv(row, args.separator, self.column_order), "\n")
		if (not res) then error(msg) end
	end
	file:close()
end

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
-- head() : only display the table's first elements
--
-- ARGS: - n_items 			(required) [number] 	: items to print
-- 		 - html 			(optional) [boolean] 	: display or not in html mode
--
-- RETURNS: Dataframe
--
function Dataframe:head(...)
	local args = dok.unpack(
		{...},
		'Dataframe.head',
		'Retrieves the first elements of a table',
		{arg='n_items', type='integer', help='The number of items to display', default=10},
		{arg='html', type='boolean', help='Display as html', default=false}
	)
	head = self:sub(1, math.min(args.n_items, self.n_rows))

	if args.html then
		itorch.html(self:_to_html{data=head.dataset})
	else
		return head
	end
end

--
-- __pairs() : overload the pairs() function. This helps the tail()/head() to behave
--             in the same way as previously
--
-- ARGS: - t (required) [Dataframe]
--
-- RETURNS: k, v as pairs
function Dataframe:__pairs(...)
	return pairs(self.dataset, ...)
end

--
-- tail() : only display the table's last elements
--
-- ARGS: - n_items 			(required) [number] 	: items to print
-- 		   - html 			(optional) [boolean] 	: display or not in html mode
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

	if args.html then
		itorch.html(self:_to_html{data=tail.dataset, start_at=self.n_rows-10+1, end_at=self.n_rows})
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

--
-- value_counts() : count number of occurences for each unique element (frequency/histogram)
--
-- ARGS: - see dok.unpack
--
-- RETURNS : table with the unique value as key and count as value
--
function Dataframe:value_counts(...)
	local args = dok.unpack(
		{...},
		'Dataframe.value_counts',
		'get value counts of elements given a column name',
		{arg='column_name', type='string', help='column to inspect', req=true}
	)
	assert(self:has_column(args.column_name),
	       "Invalid column name: " .. tostring(args.column_name))
	count = {}

	column_data = self:get_column(args.column_name)
	for i = 1,self.n_rows do
		current_key_value = column_data[i]
		if (not isnan(current_key_value)) then
			if (count[current_key_value] == nil) then
				count[current_key_value] = 1
			else
				count[current_key_value] = count[current_key_value] + 1
			end
		end
	end

  return count
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

-- Internal function for getting raw value for a categorical variable
function Dataframe:_get_raw_cat_key(column_name, key)
	keys = self:get_cat_keys(column_name)
	if (keys[key] ~= nil) then
		return keys[key]
	end

	return self:add_cat_key(column_name, key)
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
		for i = 1,#self.column_order do
			k = self.column_order[i]
			result = result.. '<th>' ..k.. '</th>'
			if n_rows == 0 then n_rows = #options.data[k] end
		end
		result = result.. '</tr>'
	end

	for i = options.start_at, options.end_at do
		result = result.. '<tr>'
		result = result.. '<td>'..i..'</td>'
		for i = 1,#self.column_order do
			k = self.column_order[i]
			result = result.. '<td>' ..tostring(options.data[k][i]).. '</td>'
		end
		result = result.. '</tr>'
	end

	if options.split_table ~= 'bottom' and options.split_table ~= 'all' then
		result = result.. '</table>'
	end

	return result
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

function Dataframe:__tostring()
  local no_rows = math.min(self.print.no_rows, self.n_rows)
	max_width = self.print.max_col_width

	-- Get the width of each column
	local lengths = {}
	for k,v in pairs(self.dataset) do
		lengths[k] = string.len(k)
		for i = 1,no_rows do
			if (v[i] ~= nil) then
				if (lengths[k] < string.len(v[i])) then
					lengths[k] = string.len(v[i])
				end
			end
		end
	end

	add_padding = function(df_string, out_len, target_len)
		if (out_len < target_len) then
			df_string = df_string .. string.rep(" ", (target_len - out_len))
		end
		return df_string
	end

	table_width = 0
	for _,l in pairs(lengths) do
		table_width = table_width + math.min(l, max_width)
	end
	table_width = table_width +
		3 * (table.exact_length(lengths) - 1) + -- All the " | "
		2 + -- The beginning of each line "| "
		2 -- The end of each line " |"

	add_separator = function(df_string, table_width)
		df_string = df_string .. "\n+" .. string.rep("-", table_width - 2) .. "+"
		return df_string
	end

	df_string = add_separator("", table_width)
	df_string = df_string .. "\n| "
	for i = 0,no_rows do
		if (i == 0) then
			row = {}
			for _,k in pairs(self.columns) do
				row[k] = k
			end
		else
			row = self:get_row(i)
		end

		if (i > 0) then
			-- Underline header with ----------------
			if (i == 1) then
				df_string = add_separator(df_string, table_width)
			end
			df_string = df_string .. "\n| "
		end

		for ii = 1,#self.column_order do
			column_name = self.column_order[ii]
			if (ii > 1) then
				df_string = df_string .. " | "
			end
			output = tostring(row[column_name])
			if (self:is_numerical(column_name)) then
				-- Right align numbers by padding to left
				df_string = add_padding(df_string, string.len(output), lengths[column_name])
				df_string = df_string .. output
			else
				if (string.len(output) > max_width) then
					output = string.sub(output, 1, max_width - 3) .. "..."
				end
				df_string = df_string .. output
				-- Padd left if needed
				df_string = add_padding(df_string, string.len(output), math.min(max_width, lengths[column_name]))
			end
		end
		df_string = df_string .. " |"
	end
	if (self.n_rows > no_rows) then
		df_string = df_string .. "\n| ..." .. string.rep(" ", table_width - 5 - 1) .. "|"
	end
	df_string = add_separator(df_string, table_width) .. "\n"
	return df_string
end

--
-- as_categorical('column_name') : set a column to categorical
--
-- ARGS: - column_name 		(required) 	[string|table] 	: column to set to categorical
--
-- RETURNS: nothing
function Dataframe:as_categorical(column_name)
	if (type(column_name) ~= 'table') then
		column_name = {column_name}
	end
	for _,cn in pairs(column_name) do
		assert(self:has_column(cn), "Could not find column: " .. cn)
		assert(not self:is_categorical(cn), "Column already categorical")
		keys = self:unique{column_name = cn,
											 as_keys = true,
											 trim_values = true}
		-- drop '' as a key
		keys[''] = nil
		column_data = self:get_column(cn)
		self.categorical[cn] = keys
		for i,v in ipairs(column_data) do
			self.dataset[cn][i] = keys[v]
		end
	end
	self:_infer_schema()
end

--
-- add_cat_key('column_name', 'key') ; adds a key to the keyset of a categorical column
--
-- ARGS: -column_name (required) [string] : the column name
--       -key         (required) [string|number] : the new key
--
-- RETURNS: new index value for key
function Dataframe:add_cat_key(column_name, key)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	assert(self:is_categorical(column_name), "The column isn't categorical: " .. tostring(column_name))
	assert(type(key) == "number" or
	       type(key) == "string",
				 "Keys can only be strings or numbers")
	keys = self:get_cat_keys(column_name)
	key_index = table.exact_length(keys) + 1
	keys[key] = key_index
	self.categorical[column_name] = keys
	return key_index
end

--
-- as_string('column_name') : converts a column to string, reverts the as_categorical
--
-- ARGS: - column_name 		(required) 	[string] 	: column to set to string
--
-- RETURNS: nothing
function Dataframe:as_string(column_name)
	assert(self:has_column(column_name), "Could not find column: " .. column_name)
	if (self:is_categorical(column_name)) then
		self.dataset[column_name] = self:get_column{column_name = column_name,
	                                              as_raw = false}
		self.categorical[column_name] = nil
	elseif(self:is_numerical(column_name)) then
		data = self:get_column(column_name)
		for i = 1,#self.n_rows do
			if (not isnan(data[i])) then
				data[i] = tostring(data[i])
			end
		end
		self.dataset[column_name] = data
	end
	self:_refresh_metadata()
	self:_infer_schema()
end

--
-- clean_categorical('column_name') : removes any categories no longer present from the keys
--
-- ARGS: see dok.unpack
--
-- RETURNS: void
function Dataframe:clean_categorical(...)
	local args = dok.unpack(
		{...},
		{"Dataframe.clean_categorical"},
		{"Removes categorical values no longer present in the column"},
		{arg='column_name', type='string', help='the name of the column', req=true},
		{arg='reset_keys', type='boolean', help='if all the keys should be reinitialized', default=false})
	assert(self:has_column(args.column_name), "Couldn't find column: " .. tostring(args.column_name))
	assert(self:is_categorical(args.column_name), tostring(args.column_name) .. " isn't categorical")
	if (args.reset_keys) then
		self:as_string(args.column_name)
		self:as_categorical(args.column_name)
	else
		keys = self:get_cat_keys(args.column_name)
		vals = self:get_column(args.column_name)
		found_keys = {}
		for _,v in pairs(vals) do
			if (keys[v] ~= nil) then
				found_keys[v] = v
			end
		end
		for v,_ in pairs(keys) do
			if (found_keys[v] == nil) then
				keys[v] = nil
			end
		end
		self.categorical[args.column_name] = keys
	end
end

--
-- is_categorical('column_name') : check if a column is categorical
--
-- ARGS: - column_name 		(required) 	[string] 	: column to check
--
-- RETURNS: boolean
function Dataframe:is_categorical(column_name)
	assert(self:has_column(column_name), "This column doesn't exist")
	return self.categorical[column_name] ~= nil
end

--
-- get_cat_keys('column_name') : get keys for a column
--
-- ARGS: - column_name 		(required) 	[string] 	: column to check
--
-- RETURNS: table
function Dataframe:get_cat_keys(column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	assert(self:is_categorical(column_name), "The " .. tostring(column_name) .. " isn't a categorical column")
  return self.categorical[column_name]
end
--
-- to_categorical(...) : Converts values to categorical according to a column's keys
--
-- ARGS: - data   (required) [number|table|tensor] : The numerical data to convert
--       - column_name (required) [string]         : The column name which keys to use
--
-- RETURNS: string if single value entered or table if multiple values
function Dataframe:to_categorical(...)
	local args = dok.unpack(
		{...},
		'Dataframe.to_categorical',
		'Converts values to categorical according to a column\'s keys',
		{arg='data', type='number|string|table|tensor', help='The data to be converted', req=true},
		{arg='column_name', type='string', help='The name of the column', req=true})
	assert(self:has_column(args.column_name), "Invalid column name: " .. args.column_name)
	assert(self:is_categorical(args.column_name), "Column isn't categorical")
	local single_value = false
	if (torch.isTensor(args.data)) then
		assert(#args.data:size() == 1,
		       "The function currently only supports single dimensional tensors")
		local tmp = {}
		for i = 1,args.data:size()[1] do
			table.insert(tmp, args.data[i])
		end
		args.data = tmp
	elseif(type(args.data) ~= 'table') then
		val = tonumber(args.data)
		assert(type(val) == 'number', "The data " .. args.data .. " is not a valid number")
		args.data = val
		assert(math.floor(args.data) == args.data, "The data is not a valid integer")
		single_value = true
		args.data = {args.data}
	else
		for k,v in pairs(args.data) do
			val = tonumber(args.data[k])
			assert(type(val) == 'number',
			       "The data ".. tostring(val) .." in position " .. k .. " is not a valid number")
			args.data[k] = val
			assert(math.floor(args.data[k]) == args.data[k],
			       "The data " .. args.data[k] .. " in position " .. k .. " is not a valid integer")
		end
	end

	ret = {}
	for _,v in pairs(args.data) do
		local val = nil
		for k,index in pairs(self.categorical[args.column_name]) do
			if (index == v) then
				val = k
				break
			end
		end
		assert(val ~= nil,
		       v .. " isn't present in the keyset")
		table.insert(ret, val)
	end
	if (single_value) then
		return ret[1]
	else
		return ret
	end
end

--
-- from_categorical(...) : Converts categorical to numerical according to a column's keys
--
-- ARGS: - data   (required) [number|table|tensor] : The numerical data to convert
--       - column_name (required) [string]         : The column name which keys to use
--       - as_tensor (optional) [boolean]          : If the return value should be a tensor
--
-- RETURNS: table or tensor
function Dataframe:from_categorical(...)
	local args = dok.unpack(
		{...},
		'Dataframe.from_categorical',
		'Converts categorical to numerical according to a column\'s keys',
		{arg='data', type='number|string|table', help='The data to be converted', req=true},
		{arg='column_name', type='string', help='The name of the column', req=true},
	  {arg='as_tensor', type='boolean', help='If the returned value should be a tensor'})
	assert(self:has_column(args.column_name), "Can't find the column: " .. args.column_name)
	assert(self:is_categorical(args.column_name), "Column isn't categorical")
	if(type(args.data) ~= 'table') then
		args.data = {args.data}
	end

	ret = {}
	for _,v in pairs(args.data) do
		local val = self.categorical[args.column_name][v]
		if (val == nil) then
			val = 0/0
		end
		table.insert(ret, val)
	end
	if (args.as_tensor) then
		return torch.Tensor(ret)
	else
		return ret
	end
end
