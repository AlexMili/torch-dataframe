require 'torch'

-- create class object
local dict = torch.class('Df_Dict')

function dict:__init(table)
	tmp = {}
	for k,v in pairs(table) do
		assert(type(v) ~= "table", "The Dataframe dictionary cannot be a nested table")
		tmp[k] = v
	end

	self.data = tmp
end

return dict
