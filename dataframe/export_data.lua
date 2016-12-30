local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Data save/export functions

]]

Dataframe.to_csv = argcheck{
	doc =  [[
<a name="Dataframe.to_csv">
### Dataframe.to_csv(@ARGP)

Saves a Dataframe into a CSV using csvigo as backend

_Return value_: self (Dataframe)

@ARGT

]],
	{name="self", type="Dataframe"},
	{name='path', type='string', doc='path to file'},
	{name="separator", type='string', doc='separator (one character)', default=','},
	{name='verbose', type='boolean', help='verbose load', default=false},
	call = function(self, path, separator, verbose)

	-- Make sure that categorical columns are presented in the correct way
	save_data = {}
	for _,k in pairs(self.column_order) do
		save_data[k] = self:get_column(k):to_table{boolean2string = true}
	end

	-- TODO: The csvigo will have memory issues when used with regular tables
	csvigo.save{path = path,
	            data = save_data,
	            separator = separator,
	            verbose = verbose,
	            column_order = self.column_order,
	            nan_as_missing = true}

	return self
end}

Dataframe.to_tensor = argcheck{
	doc =  [[
<a name="Dataframe.to_tensor">
### Dataframe.to_tensor(@ARGP)

Convert the numeric section or specified columns of the dataset to a tensor

@ARGT

_Return value_: (1) torch.tensor with self:size(1) rows and self:size(2) columns,
 (2) exported column names

]],
	{name="self", type="Dataframe"},
	call = function(self)

	return self:to_tensor(Df_Array(self:get_numerical_colnames()))
end}

Dataframe.to_tensor = argcheck{doc=[[

You can export selected columns using the columns argument:

@ARGT
]],
	overload=Dataframe.to_tensor,
	{name="self", type="Dataframe"},
	{name="columns", type='Df_Array', doc='The columns to export to labels'},
	call = function(self, columns)

	columns = columns.data

	-- Check data integrity
	local numeric_dataset = {}
	local type = -1
	local tensor_types = {
		"ByteTensor" -- contains unsigned chars
		,"CharTensor" -- contains signed chars
		,"ShortTensor" -- contains shorts
		,"IntTensor" -- contains ints
		,"LongTensor" -- contains longs
		,"FloatTensor" -- contains floats
		,"DoubleTensor"
	}
	for _,k in pairs(columns) do
		self:assert_has_column(k)
		assert(self:is_numerical(k), "Column " .. tostring(k) .. " is not numerical")
		local col = self:get_column(k)
		numeric_dataset[k] =  col:to_tensor()
		local current_type = col:type()

		for idx,tnsr_type in ipairs(tensor_types) do
			if (current_type:match(tnsr_type)) then
				current_type = idx
				break
			end
		end
		if (current_type > type) then
			type = current_type
		end
	end

	-- Convert all tensors to the same format before concat
	type = ("torch.%s"):format(tensor_types[type])
	for cn,col in pairs(numeric_dataset) do
		numeric_dataset[cn] = numeric_dataset[cn]:type(type)
	end

	tensor_data = nil
	tensor_col_names = {}
	for col_no = 1,#self.column_order do
		-- Find the next column that is present in the numerics
		found = false
		column_name = self.column_order[col_no]
		for k,v in pairs(numeric_dataset) do
			if (k == column_name) then
				found = true
				break
			end
		end

		-- If column found we then concatenate that with our tensor_data
		if (found) then
			next_col =  numeric_dataset[column_name]
			if (torch.isTensor(tensor_data)) then
				tensor_data = torch.cat(tensor_data, next_col, 2)
			else
				tensor_data = next_col
			end
			table.insert(tensor_col_names, column_name)
		end
	end

	if (#tensor_col_names == 1) then
		-- Reshape to tabular if this is only a single column
		tensor_data	= tensor_data:reshape(tensor_data:size(1), 1)
	end

	return tensor_data, tensor_col_names
end}

Dataframe.to_tensor = argcheck{
	doc=[[

If a filename is provided the tensor will be saved (`torch.save`) to that file:

@ARGT
]],
	overload=Dataframe.to_tensor,
	{name="self", type="Dataframe"},
	{name='filename', type='string', doc='Filename for tensor.save()'},
	{name="columns", type='Df_Array', doc='The columns to export to labels', default=false},
	call = function(self, filename, columns)

	if (columns) then
		tensor_data, tensor_col_names = self:to_tensor{columns = columns}
	else
		tensor_data, tensor_col_names = self:to_tensor()
	end

	torch.save(filename, tensor_data)

	return tensor_data, tensor_col_names
end}

Dataframe.get = argcheck{
	doc =  [[
<a name="Dataframe.get">
### Dataframe.get(@ARGP)

A funtion for *torchnet* compliance. It subsets a single index and returns the
`to_tensor` on that example.

@ARGT

_Return value_: (1) torch.tensor with 1 row and #numerical columns

]],
	{name="self", type="Dataframe"},
	{name="idx", type="number"},
	call = function(self, idx)
	local row = self:sub(idx, idx)
	return row:to_tensor()
end}
