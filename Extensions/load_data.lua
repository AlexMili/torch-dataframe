require 'dok'
local params = {...}
local Dataframe = params[1]

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
		{arg='verbose', type='boolean', help='verbose load', default=false}
	)
	-- Remove previous data
	self:_clean()

	self.column_order,self.dataset = csvigo.load{path = args.path,
												header = args.header,
												separator = args.separator,
												skip = args.skip,
												verbose = args.verbose,
												column_order = true}
	self:_clean_columns()
	self.column_order = trim_table_strings(self.column_order)
	self:_refresh_metadata()

	if args.infer_schema then
		self:_infer_schema()
	else
		-- Default value for self.schema
		for key,value in pairs(self.column_order) do
			self.schema[value] = 'number'
		end
	end

	-- Change all missing values to nan
	self:_fill_missing()
end

--
-- load_table{data=your_table} : Imports a table data directly into Dataframe
--
-- ARGS: - data 			(required) 					[string]	: table to import
--		 - infer_schema 	(optional, default=false)	[boolean] 	: automatically detect columns type
--		 - column_order 	(optional)					[table] 	: the column order
--
-- RETURNS: nothing
--
function Dataframe:load_table(args)
	-- local args = dok.unpack(
	-- 	{...},
	-- 	'Dataframe.load_table',
	-- 	'Imports a table data directly into Dataframe',
	-- 	-- See https://github.com/torch/dok/issues/13
	-- 	{arg='data', type='table', help='table to import', req=true},
	-- 	{arg='infer_schema', type='boolean', help='automatically detect columns\' type', default=true},
	-- 	{arg='column_order', type='table', help='The column order', req=false}
	-- )
	-- infer_schema default value
	if not args.infer_schema then args.infer_schema = true end

	self:_clean()

	-- Check that all columns with a length > 1 has the same number of rows (length)
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
		self.column_order[count] = trim(k)

		-- if there is only one value for this column we need to duplicate the value to all next rows
		if (type(v) ~= 'table') then
			-- Populate the table if single value has been provided
			tmp = {}
			for i = 1,length do
				tmp[i] = v
			end
			self.dataset[k] = tmp
		else
			self.dataset[k] = clone(v)
		end
	end

	if args.column_order then args.column_order = trim_table_strings(args.column_order) end
	self:_clean_columns()

	if (args.column_order and not tables_equals(args.column_order,self.column_order)) then
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
	
	if args.infer_schema then
		self:_infer_schema()
	else
		-- Default value for self.schema
		for key,value in pairs(self.column_order) do
			self.schema[value] = 'number'
		end
	end

	-- Change all missing values to nan
	self:_fill_missing()
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

-- Count missing values 
function Dataframe:_count_missing()
	counter =0
	for index,col in pairs(self.columns) do
		for i = 1,self.n_rows do
			if (self.dataset[col][i] == nil) then
				counter = counter + 1
			end
		end
	end

	return counter
end

-- Fill missing values with NaN value
function Dataframe:_fill_missing()
	for index,col in pairs(self.columns) do
		for i = 1,self.n_rows do
			-- In CSV mode - only needed by number columns because the nil value is due to tonumber() from _infer_schema()
			if (self.dataset[col][i] == nil and self.schema[col] == 'number') then
				self.dataset[col][i] = 0/0
			-- In table mode only
			elseif (self.dataset[col][i] == nil and self.schema[col] == 'string') then
				self.dataset[coll][i] = 'n/a'
			end
		end
	end
end