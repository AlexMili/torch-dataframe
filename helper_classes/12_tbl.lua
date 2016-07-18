require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Df_Tbl

The Df_Tbl is a class that is used to wrap a table. In contrast with Df_Array
and Df_Dict it does not check any input data.

]]

-- create class object
local dtbl = torch.class('Df_Tbl')

-- This is the fastes table wrapper that doesn't care to copy the original
--  data. Should be used sparingly.
function dtbl:__init(table)
	self.data = table
end

dtbl.__len__ = argcheck{
	{name="self", type="Df_Tbl"},
	{name="other", type="Df_Tbl", opt=true},
	call=function(self, other)
	return table.exact_length(self.data)
end}

return dtbl
