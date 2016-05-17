require 'torch'

-- create class object
local dict = torch.class('Df_Dict')

function dict:__init(table)
	local dict_data = {}
	for k,v in pairs(table) do
		-- Check dimension
		if (type(v) == "table") then
			for i=1,#v do
				assert(type(v[i]) ~= "table",
				      ("For key '%s' in the position %d the value is a table, this isn't allowed"):format(k, i))
			end
		end
		dict_data[k] = v
	end

	self.data = dict_data
end

return dict
