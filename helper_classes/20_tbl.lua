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

doc[[
<a name="Df_Tbl.__init">
### Df_Tbl.__init(table)

This is the fastes table wrapper that doesn't care to copy the original data. Should be used sparingly.

]]
function dtbl:__init(table_data)
	self.data = table_data
end

doc[[
<a name="Df_Tbl.#">
### Df_Tbl.#

Returns the number of elements

]]
dtbl.__len__ = argcheck{
	{name="self", type="Df_Tbl"},
	{name="other", type="Df_Tbl"},
	call=function(self)
	return table.exact_length(self.data)
end}

return dtbl
