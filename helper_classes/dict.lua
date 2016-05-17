require 'torch'

-- create class object
local dict = torch.class('Df_Dict')

function dict:__init(table)
	local dict_data = {}
	for k,v in pairs(table) do
		dict_data[k] = v
	end

	self.data = dict_data
end

return dict
