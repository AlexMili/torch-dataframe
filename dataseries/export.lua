local params = {...}
local Dataseries = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Export functions

Here are functions are used for exporting to a different format. Generally `to_`
functions should reside here. Only exception is the `tostring`.

]]

Dataseries.to_tensor = argcheck{
	doc=[[
<a name="Dataseries.to_tensor">
### Dataseries.to_tensor(@ARGP)

Returns the values in tensor format. Note that if you don't provide a replacement
for missing values and there are missing values the function will throw an error.

*Note*: boolean columns are not tensors and need to be manually converted to a
tensor. This since 0 would be a natural value for false but can cause issues as
neurons are labeled 1 to n for classification tasks. See the `Dataframe.update`
function for details or run the `boolean2tensor`.

@ARGT

_Return value_: `torch.*Tensor` of the current type
]],
	{name="self", type="Dataseries"},
	{name="missing_value", type="number",
	 doc="Set a value for the missing data",
	 opt=true},
	{name="copy", type="boolean", default=true,
	 doc="Set to false if you want the original data to be returned."},
	call=function(self, missing_value)
	assert(self:type():match("torch.*Tensor"),
	       "Can only automatically retrieve columns that already are tensors")
	assert(self:count_na() == 0 or missing_value,
	       "Missing data should be replaced with a default value before retrieving tensor")

	local ret
	if (copy) then
		ret = self:copy()
	else
		ret = self
	end

	if (missing_value and self:count_na() > 0) then
		assert(copy, "Replacing missing values is not allowed in to_tensor unless you are returning a copy")
		ret:fill_na(missing_value)
	end

	return ret.data
end}

Dataseries.to_table = argcheck{
	doc=[[
<a name="Dataseries.to_table">
### Dataseries.to_table(@ARGP)

Returns the values in table format

@ARGT

_Return value_: table
]],
	{name="self", type="Dataseries"},
	{name="boolean2string", type="boolean", opt=true,
	 doc="Convert boolean values to strings since they cause havoc with csvigo"},
	call=function(self, boolean2string)
	local ret = {}
	for i=1,self:size() do
		ret[i] = self:get(i)
	end

	if (boolean2string and self:type() == "tds.Vec") then
		for i=1,#ret do
			if (type(ret[i]) == "boolean") then
				ret[i] = tostring(ret[i])
			end
		end
	end

	return ret
end}
