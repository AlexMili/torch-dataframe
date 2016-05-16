require 'torch'

-- create class object
local dtbl = torch.class('Df_Tbl')

function dtbl:__init(table)
	self.data = clone(table)
end

return dtbl
