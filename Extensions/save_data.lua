require 'dok'
local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"

Dataframe.to_csv = argcheck{
	doc =  [[
<a name="Dataframe.to_csv">
### Dataframe.to_csv(@ARGP)

@ARGT

Saves a Dataframe into a CSV using csvigo as backend

_Return value_: void
	]],
	{name="self", type="Dataframe"},
	{name='path', type='string', doc='path to file'},
	{name="separator", type='string', doc='separator (one character)', default=','},
	{name='verbose', type='boolean', help='verbose load', default=false},
	call = function(self, path, separator, verbose)

	-- Make sure that categorical columns are presented in the correct way
	save_data = {}
	for _,k in pairs(self.columns) do
		save_data[k] = self:get_column(k)
	end

	csvigo.save{path = path,
	            data = save_data,
	            separator = separator,
	            verbose = verbose,
	            column_order = self.column_order,
	            nan_as_missing = true}
end}

Dataframe.to_tensor = argcheck{
	doc =  [[
<a name="Dataframe.to_tensor">
### Dataframe.to_tensor(@ARGP)

@ARGT

Convert the numeric section or specified columns of the dataset to a tensor

_Return value_: torch.tensor with self.n_rows rows and #columns
	]],
	{name="self", type="Dataframe"},
	{name='filename', type='string', doc='filename for tensor.save()', default=false},
	{name="columns", type='string|table', doc='the columns to export to labels', default=false},
	call = function(self, filename, columns)

	if (not columns) then
		numeric_dataset = {}
		for _,k in pairs(self:get_numerical_colnames()) do
			numeric_dataset[k] = self:get_column{column_name = k,
		                                       as_tensor = true}
		end
		assert(table.exact_length(numeric_dataset) > 0,
		       "Didn't find any numerical columns to export to tensor")
	else
		if (type(columns) == "string") then
			columns = {columns}
		end
		numeric_dataset = {}
		for _,k in pairs(columns) do
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

	if filename then
		torch.save(filename, tensor_data)
	end

	return tensor_data, tensor_col_names
end}
