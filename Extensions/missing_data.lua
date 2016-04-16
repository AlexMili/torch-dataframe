require 'dok'
local params = {...}
local Dataframe = params[1]

--
-- count_na() : count missing values in dataset
--
-- ARGS: column_name (optional) [string] : if we only want a single columns na
--
-- RETURNS: table containing missing values per column or single integer
--
function Dataframe:count_na(...)
	local args = dok.unpack(
		{...},
		'Dataframe.count_na',
		'Count mising values in dataset',
		{arg='columns', type='string|table', help='the columns to count to labels'}
	)
	local single
	if (args.columns == nil) then
		args.columns = self.columns
	elseif(type(args.columns) == 'string') then
		single = true
		args.columns = {args.columns}
	else
		error("Invalid columns argument: " .. tostring(args.columns))
	end
	count = {}

	for _,column_name in pairs(args.columns) do
		counter = 0
		for i = 1, self.n_rows do
			local val = self.dataset[column_name][i]
			if val == nil or val == '' or isnan(val) then
				counter = counter + 1
			end
		end
		count[column_name] = counter
	end

	if (single) then
		return count[args.columns[1]]
	else
		return count
	end
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
	if (self:count_na(column_name) == 0) then
		return
	end

	default_value = default_value or 0
  if (self:is_categorical(column_name) and
      self.categorical[column_name][default_value] == nil) then
    self.categorical[column_name]["__nan__"] = default_value
  end

	for i = 1, self.n_rows do
		local val = self.dataset[column_name][i]
		if val == nil or val == '' or isnan(val) then
			self.dataset[column_name][i] = default_value
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
	for _,key in pairs(self.columns) do
		self:fill_na(key, default_value)
	end
end
