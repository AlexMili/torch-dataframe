require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Df_Dict

The Df_Dict is a class that is used to wrap a dictionary table. A dictionary table
has a string name corresponding to each key and an array as values, i.e. it may
not contain any tables.

]]

-- create class object
local dict = torch.class('Df_Dict')

function dict:__init(table)
	local dict_data = {}
	for k,v in pairs(table) do
		-- Check dimension
		if (torch.type(v) == "table") then
			for i=1,#v do
				assert(type(v[i]) ~= "table",
				      ("For key '%s' in the position %d the value is a table, this isn't allowed"):format(k, i))
			end
		end
		dict_data[k] = v
	end

	self.data = dict_data
end

dict.__len__ = argcheck{
	{name="self", type="Df_Dict"},
	{name="other", type="Df_Dict", opt=true},
	call=function(self, other)
	return table.exact_length(self.data)
end}

return dict
