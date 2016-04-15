require 'dok'
local params = {...}
local Dataframe = params[1]

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
