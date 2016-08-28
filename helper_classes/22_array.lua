require 'torch'


local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Df_Array

The Df_Array is a class that is used to wrap an array table. An array table
no key names, it only uses numbers for indexing and each element has to be
an atomic element, i.e. it may not contain any tables.

]]

-- create class object
local da = torch.class('Df_Array')

function da:__init(...)
	arg = {...}
	if (#arg == 1 and
		(torch.type(arg[1]) == 'table' or
		torch.isTensor(arg[1]))) then
		arg = arg[1]
	end

	local array_data = {}
	if (torch.isTensor(arg)) then
		array_data = arg:totable()
	elseif (torch.type(arg) == "Dataseries") then
		array_data = arg:to_table()
	else
		for i=1,#arg do
			assert(type(arg[i]) ~= "table",
			       ("The Dataframe array cannot contain tables - see position %d in your input"):format(i))
			array_data[i] = arg[i]
		end
	end

	self.data = array_data
end

da.__len__ = argcheck{
	{name="self", type="Df_Array"},
	{name="other", type="Df_Array", opt=true},
	call=function(self, other)
	return #self.data
end}

return da
