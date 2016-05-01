require 'dok'
local params = {...}
local Dataframe = params[1]

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
		{arg='verbose', type='boolean', help='verbose load', default=false}
	)

	-- Make sure that categorical columns are presented in the correct way
	save_data = {}
	for _,k in pairs(self.columns) do
		save_data[k] = self:get_column(k)
	end

	csvigo.save{path = args.path,
				data = save_data,
				separator = args.separator,
				verbose = args.verbose,
				column_order = self.column_order,
				nan_as_missing = true}
end

--
-- to_tensor() : convert dataset to tensor
--
-- ARGS: - filename (optional) [string] : path where save tensor, if missing the tensor is only returned by the function
--
-- RETURNS: torch.tensor, table with label names
--
function Dataframe:to_tensor(...)
	local args = dok.unpack(
		{...},
		'Dataframe.to_tensor',
		'Convert the numeric section or specified columns of the dataset to a tensor',
		{arg='filename', type='string', help='the name of the column'},
		{arg='columns', type='string|table', help='the columns to export to labels'}
	)

	if (args.columns == nil) then
		numeric_dataset = {}
		for _,k in pairs(self:get_numerical_colnames()) do
			numeric_dataset[k] = self:get_column{column_name = k,
		                                       as_tensor = true}
		end
		assert(table.exact_length(numeric_dataset) > 0,
		       "Didn't find any numerical columns to export to tensor")
	else
		if (type(args.columns) == "string") then
			args.columns = {args.columns}
		end
		assert(type(args.columns) == "table", "Columns to export can either be a single string value or a table with column values")
		numeric_dataset = {}
		for _,k in pairs(args.columns) do
			assert(self:has_column(k), "Could not find column: '" .. tostring(k) .. "'"..
			                           " in " .. table.collapse_to_string(self.columns))
			assert(self:is_numerical(k), "Column " .. tostring(k) .. " is not numerical")
			numeric_dataset[k] =  self:get_column{column_name = k,
			                                      as_tensor = true}
		end
	end

	tensor_data = nil
	count = 1
	tensor_col_names = {}
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
			next_col =  numeric_dataset[column_name]
			if (torch.isTensor(tensor_data)) then
				tensor_data = torch.cat(tensor_data, next_col, 2)
			else
				tensor_data = next_col
			end
			count = count + 1
			table.insert(tensor_col_names, column_name)
		end
	end

	if args.filename ~= nil then
		torch.save(args.filename, tensor_data)
	end

	return tensor_data, tensor_col_names
end
