require 'torch'


local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Df_Array

The Df_Array is a class that is used to wrap an array table. An array table
has no key names, it only uses numbers for indexing and each element has to be
an atomic element, i.e. it may not contain any tables.

]]

-- create class object
local da = torch.class('Df_Array')


doc[[
<a name="Df_Array.__init">
### Df_Array.__init(...)

Df_Array accepts 5 type of init values :
- single value (string, integer, float, etc)
- table
- torch.*Tensor
- Dataseries
- arguments list (e.g. Df_Array(1,2,3,4,5) )

]]
-- (...) allows to call Df_Array with an infinite number of arguments
function da:__init(...)
	arg = {...}

	-- If there is only one value, which can be 
	-- a simple type (string, number, etc), a table or a tensor
	if (#arg == 1 and
		(torch.type(arg[1]) == 'table' or
		torch.isTensor(arg[1])) or
		torch.type(arg[1]) == "Dataseries") then
		-- If this is the case, arg var is set as its single value
		arg = arg[1]
	end

	local array_data = {}
	if (torch.isTensor(arg)) then
		-- If Df_Array is inited with a tensor, 
		-- it is simply converted into a table and set
		array_data = arg:totable()
	elseif (torch.type(arg) == "Dataseries") then
		-- Same fate for Dataseries
		array_data = arg:to_table()
	else
		-- If there is multiple arguments or 
		-- a table (thanks to #arg == 1 condition above),
		-- value is set row by row.
		-- in the case of a table, it allows to get rid of eventual 
		-- keys and only keep numerical indexes
		for i=1,#arg do
			assert(type(arg[i]) ~= "table",
			       ("The Dataframe array cannot contain tables - see position %d in your input"):format(i))
			array_data[i] = arg[i]
		end
	end

	self.data = array_data
end


doc[[
<a name="Df_Array.[]">
### Df_Array.[]

Returns the value at the given index

]]
function da:__index__(index)
	if (torch.type(index) == "number") then
		return self.data[index], true
	end

	return false
end

function da:__newindex__(index)
	return false
end


doc[[
<a name="Df_Array.#">
### Df_Array.#

Returns the number of elements

]]
da.__len__ = argcheck{
	{name="self", type="Df_Array"},
	{name="other", type="Df_Array"},-- used by lua when invoking #myArray
	call=function(self)
	return #self.data
end}

return da
