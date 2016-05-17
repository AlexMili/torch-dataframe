require 'torch'

-- create class object
local dict = torch.class('Df_Dict')

function dict:__init(table)
	local dict_data = {}
	for k,v in pairs(table) do
		assert(type(v) ~= "table", "The Dataframe dictionary cannot be a nested table")
		dict_data[k] = v
	end

	self.data = dict_data
end

return dict
