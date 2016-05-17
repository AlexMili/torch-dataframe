require 'torch'

-- create class object
local da = torch.class('Df_Array')

function da:__init(...)
	arg = {...}
	if (#arg == 1 and type(arg[1]) == 'table') then
		arg = arg[1]
	end

	local array_data = {}
	for i=1,#arg do
		assert(type(arg[i]) ~= "table", "The Dataframe array cannot contain tables")
		array_data[i] = arg[i]
	end

	self.data = array_data
end

return da
