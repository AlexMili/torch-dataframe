require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Df_Dict

The Df_Dict is a class that is used to wrap a dictionary table. A dictionary table
has a string name corresponding to each key and an array as values, i.e. it may
not contain any tables.

The following properties are available :
It is possible to access the Df_Dict's keys with the property `keys`.
- `Df_Dict.keys`: list of the key
- `Df_Dict.length`: content size for each key
]]

-- create class object
local dict = torch.class('Df_Dict')

doc[[
<a name="Df_Dict.__init">
### Df_Dict.__init(table_data)

Create a Df_Dict object given a table

]]
function dict:__init(table_data)
	local dict_data = {}
	local dict_lengths = {}-- lengths of each key's value
	local dict_keys = {}


	assert(torch.type(table_data) == "table", "Argument must be a table")

	for k,v in pairs(table_data) do
		dict_lengths[k] = 0

		-- Check dimension
		if (torch.type(v) == "table") then
			for i=1,#v do
				assert(type(v[i]) ~= "table",
				      ("For key '%s' in the position %d the value is a table, this isn't allowed"):format(k, i))
				dict_lengths[k] = dict_lengths[k] + 1
			end
		else
			dict_lengths[k] = 1
		end

		-- store the key value in another table for future access
		table.insert(dict_keys,k)

		dict_data[k] = v
	end

	self.keys = dict_keys
	self.data = dict_data
	self.length = dict_lengths
end

doc[[
<a name="Df_Dict.check_lengths">
### Df_Dict.check_lengths()

Ensure every columns has the same size

_Return value_: boolean
]]
function dict:check_lengths()
	local previous_length = self.length[self.keys[1]]

	for key,value in pairs(self.length) do
		if previous_length ~= value then
			return false
		end

		previous_length = self.length[key]
	end

	return true
end

doc[[
<a name="Df_Dict.set_keys">
### Df_Dict.set_keys(table_data)

Replace all the keys by the given values

`table_data` must be a table and have the same item length as the keys

]]
function dict:set_keys(table_data)
	assert(torch.type(table_data) == "table", "You must provide a table as argument")
	assert(#table_data == #self.keys, 
		("The keys you provided (%d items) has not the same number of current elements (%d items)")
		:format(#table_data,#self.keys))

	local temp_data = {}

	for i=1,#self.keys do
		local old_key = self.keys[i]
		local new_key = table_data[i]

		temp_data[new_key] = self.data[old_key]
	end

	self.keys = table_data
	self.data = temp_data
end

doc[[
<a name="Df_Dict.[]">
### Df_Dict.[]

Returns the value with the given key
- _Single integer_: it returns the value corresponding
- _"$column_name"_: get a column by prepending the name with `$`, e.g. `"$a column name"`

_Return value_: Table or single value

]]
function dict:__index__(key)
	if (torch.type(key) == "number") then
		return self.data[key], true
	-- Index a column using a $ at the beginning of a string
	elseif (torch.type(key) == "string" and key:match("^[$]")) then
		local key_name = key:gsub("^[$]", "")
		return self.data[key_name], true
	end

	return false
end

function dict:__newindex__(index)
	return false
end

doc[[
<a name="Df_Dict.#">
### Df_Dict.#

Returns the number of elements

]]
dict.__len__ = argcheck{
	{name="self", type="Df_Dict"},
	{name="other", type="Df_Dict"},-- used by lua when invoking #myDict
	call=function(self)
		return table.exact_length(self.data)
end}

return dict
