require 'torch'

-- create class object
local dtbl = torch.class('Df_Tbl')

-- This is the fastes table wrapper that doesn't care to copy the original
--  data. Should be used sparingly.
function dtbl:__init(table)
	self.data = table
end

return dtbl
