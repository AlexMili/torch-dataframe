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
		{arg='verbose', type='boolean', help='verbose load', default=true}
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
	self:_refresh_metadata()

	-- Change all missing values to nan
	for k,v in pairs(self.dataset) do
		for i = 1,self.n_rows do
			if (v[i] == nil or v[i] == '') then
				v[i] = 0/0
			end
		end
		self.dataset[k] = v
	end

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
			self.dataset[k] = clone(v)
		end
	end

	-- Change all missing values to nan
	for k,v in pairs(self.dataset) do
		for i = 1,self.n_rows do
			if (v[i] == nil) then
			  v[i] = 0/0
			end
		end
		self.dataset[k] = v
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
