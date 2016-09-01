local params = {...}
local Dataseries = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Metatable functions

]]

doc =  [[
<a name="Dataseries.[]">
### Dataseries.[]

The `__index__` function is a powerful tool that allows quick access to regular functions

- _Single integer_: it returns the raw elemet table (see `get()`)
- _Df_Array()_: select a set of interest (see `_create_subset()`)
- _"start:stop"_: get a row span using start/stop index, e.g. `"2:5"` (see `sub()`)
- _"$column_name"_: get a column by prepending the name with `$`, e.g. `"$a column name"` (see `get_column`)
- _"/subset_name"_: get a subset by prepending the name with `/`, e.g. `"/a subset name"` (see `get_subset`)

_Return value_: Table or Dataseries
]]

function Dataseries:__index__(index)
	local thtype = torch.type(index)
	if (thtype == "number" or
	    thtype == "Df_Array") then
		return self:get(index), true
	elseif (thtype == "string" and index:match("^[0-9]*:[0-9]*$")) then
		start = index:gsub(":.*", "")
		start = tonumber(start)

		stop = index:gsub("[^:]*:", "")
		stop = tonumber(stop)

		return self:sub(start, stop), true
	end


	return false
end


doc =  [[
<a name="Dataseries.[] =">
### Dataseries.[] =

The `__newindex__` allows updating of a single element (uses `set()`)

]]
function Dataseries:__newindex__(index, value)
	if (torch.type(index) == "number") then
		self:set(index, value)
		return true
	end

	return false
end

Dataseries.__len__ = argcheck{
	doc =  [[
<a name="Dataseries.#">
### Dataseries.#

Returns the number of elements

_Return value_: integer
]],
	{name="self", type="Dataseries"},
	{name="other", type="Dataseries", opt=true},
	call=function(self, other)
	return self:size()
end}

Dataseries.__tostring__ = argcheck{
	doc=[[
	<a name="Dataseries.__tostring__">
### Dataseries.__tostring__(@ARGP)

A wrapper for `tostring()`

@ARGT

_Return value_: string
]],
	{name="self", type="Dataseries"},
	call=function (self)
	return self:tostring()
end}
