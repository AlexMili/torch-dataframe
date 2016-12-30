local params = {...}
local Dataseries = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Categorical functions

Here are functions are used for converting to and from categorical type. The
categorical series type is a hash table around a torch.IntTensor that maps
numerical values between integer and string values. The standard numbering is
from 1 to n unique values.

]]

Dataseries.as_categorical = argcheck{
	doc =  [[
<a name="Dataseries.as_categorical">
### Dataseries.as_categorical(@ARGP)

Set a series to categorical type. The keys retrieved from Dataseries.unique.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="levels", type="Df_Array|boolean",
	 doc=[[An optional array of the values that series might have taken.
	 The default is the unique set of values taken by Dataseries.unique,
	 sorted into increasing order. If you provide values that aren't present
	 within the current series the value will still be saved and may be envoked in
	 the future.]], opt=true},
	{name="labels", type="Df_Array|boolean",
	 doc=[[An optional character vector of labels for the levels
	 (in the same order as levels after removing those in exclude)]],
	 opt=true},
	{name="exclude", type="Df_Array|boolean",
	 doc=[[Values to be excluded when forming the set of levels. This should be
	 of the same type as the series, and will be coerced if necessary.]],
	 opt=true},
	call = function(self, levels, labels, exclude)
	assert(not self:is_categorical(), "Dataseries is already categorical")

	if (levels) then
		levels = table.array2hash(levels.data)
	elseif (self:is_boolean()) then
		return self:boolean2categorical()
	else
		levels = self:unique{as_keys = true}
	end

	if (exclude) then
		for _,v in ipairs(exclude.data) do
			if (levels[v] ~= nil) then
				-- Reduce all elements with a higher index by 1
				for key,index in pairs(levels) do
					if (index > levels[v]) then
						levels[key] = index - 1
					end
				end

				-- Delete element
				levels[v] = nil
			end
		end
	end

	-- drop '' as a key
	levels[''] = nil

	-- Replace the current data with an integer Dataseries
	local new_col = Dataseries.new(self:size(), "integer")
	for i=1,self:size() do
		local val = 0/0
		if (levels[self:get(i)] ~= nil) then
			val = levels[self:get(i)]
		end

		new_col:set(i, val)
	end

	self:_replace_data(new_col)
	self.categorical = levels
	if (labels) then
		labels = labels.data
		assert(table.exact_length(levels),
		       #labels,
		       "The labels must match the levels in length")
		self.categorical = table.array2hash(labels)
	end

	return self
end}

Dataseries.add_cat_key = argcheck{
	doc =  [[
<a name="Dataseries.add_cat_key">
### Dataseries.add_cat_key(@ARGP)

Adds a key to the keyset of a categorical series. Mostly intended for internal use.

@ARGT

_Return value_: index value for key (integer)
	]],
	{name="self", type="Dataseries"},
	{name="key", type="number|string", doc="The new key to insert"},
	{name="key_index", type="number", doc="The key index to use", opt=true},
	call = function(self, key, key_index)

	assert(self:is_categorical(), "The current Dataseries isn't categorical")
	assert(not isnan(key), "You can't add a nan key to categorical Dataseries")

	local keys = self:get_cat_keys()
	if (self:has_cat_key(key)) then
		assert(not key_index, "The key is already present in the series: " ..
		       table.collapse2str(keys))
		return self.categorical[key]
	end

	if (key_index) then
		assert(not self:has_cat_value(key_index),
		       "The key index is already present among the categoricals: " ..
		       table.collapse2str(keys))
	else
		key_index = table.exact_length(keys) + 1
	end
	keys[key] = key_index
	self.categorical = keys

	return key_index
end}

Dataseries.as_string = argcheck{
	doc =  [[
<a name="Dataseries.as_string">
### Dataseries.as_string(@ARGP)

Converts a categorical Dataseries to a string Dataseries. This can be used to revert
the Dataseries.as_categorical or as a way to convert numericals into strings.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	call= function(self)
	local new_data = Dataseries.new(self:size(), "string")
	if (self:is_categorical()) then
		for i=1,self:size() do
			new_data:set(i, self:get(i))
		end
	elseif(self:is_numerical()) then
		for i=1,self:size() do
			new_data:set(i, tostring(self:get(i)))
		end
	end

	self:_replace_data(new_data)
	self.categorical = nil

	return self
end}

Dataseries.clean_categorical = argcheck{
	doc =  [[
<a name="Dataseries.clean_categorical">
### Dataseries.clean_categorical(@ARGP)

@ARGT

Removes any categories no longer present from the keys

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name='reset_keys', type='boolean', doc='if all the keys should be reinitialized', default=false},
	call=function(self, reset_keys)
	assert(self:is_categorical(), "The series isn't categorical")
	if (reset_keys) then
		self:as_string()
		self:as_categorical()
	else
		local keys = self:get_cat_keys()
		local found_keys = {}
		for i=1,self:size() do
			local v = self:get(i)
			if (keys[v] ~= nil and not isnan(v)) then
				found_keys[v] = v
			end
		end

		for v,_ in pairs(keys) do
			if (found_keys[v] == nil) then
				keys[v] = nil
			end
		end

		self.categorical = keys
	end

	return self
end}

Dataseries.is_categorical = argcheck{
	doc =  [[
<a name="Dataseries.is_categorical">
### Dataseries.is_categorical(@ARGP)

Check if a Dataseries is categorical

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataseries"},
	call=function(self)
	return self.categorical ~= nil
end}

Dataseries.get_cat_keys = argcheck{
	doc =  [[
<a name="Dataseries.get_cat_keys">
### Dataseries.get_cat_keys(@ARGP)

Get keys

@ARGT

_Return value_: table with `["key"] = number` structure
]],
	{name="self", type="Dataseries"},
	call=function(self)
	assert(self:is_categorical(), "The series isn't a categorical")
	return self.categorical
end}

Dataseries.to_categorical = argcheck{
	doc =  [[
<a name="Dataseries.to_categorical">
### Dataseries.to_categorical(@ARGP)

Converts values to categorical according to a series's keys

@ARGT

_Return value_: string with the value. If provided `nan` it will also
 return a `nan`. It returns `nil` if no key is found
]],
	{name="self", type="Dataseries"},
	{name='key_index', type='number', doc='The integer to be converted'},
	call=function(self, key_index)

	local val = nil
	if (isnan(key_index)) then
		val = 0/0
	else
		for k,index in pairs(self.categorical) do
			if (index == key_index) then
				val = k
				break
			end
		end
	end

	return val
end}

Dataseries.to_categorical = argcheck{
	doc =  [[
You can also provide a tensor

@ARGT

_Return value_: table with values
]],
	overload=Dataseries.to_categorical,
	{name="self", type="Dataseries"},
	{name='data', type='torch.*Tensor', doc='The integers to be converted'},
	call=function(self, data)
	assert(#data:size() == 1,
	       "The function currently only supports single dimensional tensors")
	return self:to_categorical(Df_Array(torch.totable(data)))
end}

Dataseries.to_categorical = argcheck{
	doc =  [[
You can also provide an array

@ARGT

_Return value_: table with values
]],
	overload=Dataseries.to_categorical,
	{name="self", type="Dataseries"},
	{name='data', type='Df_Array', doc='The integers to be converted'},
	call=function(self, data)
	assert(self:is_categorical(), "The series isn't categorical")

	data = data.data

	for k,v in pairs(data) do
		if (not isnan(data[k])) then
			local val = tonumber(data[k])
			assert(type(val) == 'number',
			       "The data ".. tostring(val) .." in position " .. k .. " is not a valid number")
			data[k] = val
			assert(math.floor(data[k]) == data[k],
			       "The data " .. data[k] .. " in position " .. k .. " is not a valid integer")
		end
	end

	local ret = {}
	for _,v in pairs(data) do
		local val = self:to_categorical(v)
		assert(val ~= nil,
		       v .. " isn't present in the keyset among " ..
		       table.get_val_string(self.categorical))
		table.insert(ret, val)
	end

	return ret
end}

Dataseries.from_categorical = argcheck{
	doc =  [[
<a name="Dataseries.from_categorical">
### Dataseries.from_categorical(@ARGP)

Converts categorical to numerical according to a Dataseries's keys

@ARGT

_Return value_: table or tensor
]],
	{name="self", type="Dataseries"},
	{name='data', type='number|string', doc='The data to be converted'},
	call=function(self, data)
	local val = self.categorical[data]
	if (val == nil) then
		val = 0/0
	end
	return val
end}

Dataseries.from_categorical = argcheck{
	doc =  [[
You can also provide an array with values

@ARGT

_Return value_: table or tensor
]],
	overload=Dataseries.from_categorical,
	{name="self", type="Dataseries"},
	{name='data', type='Df_Array', doc='The data to be converted'},
	{name='as_tensor', type='boolean',
	 doc='If the returned value should be a tensor', default=false},
	call=function(self, data, as_tensor)
	assert(self:is_categorical(), "The series isn't categorical")

	data = data.data

	local ret = {}
	for _,v in pairs(data) do
		table.insert(ret, self:from_categorical(v))
	end

	if (as_tensor) then
		return torch.Tensor(ret)
	else
		return ret
	end
end}

Dataseries.has_cat_key = argcheck{
	doc =  [[
Checks if categorical key exists

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataseries"},
	{name='value', type='number|string',
	 doc='The value that should be present in the categorical hash'},
	call=function(self, value)
	assert(self:is_categorical(), "The series isn't categorical")

	return not isnan(self:from_categorical(value))
end}

Dataseries.has_cat_value = argcheck{
	doc =  [[
Checks if categorical value exists

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataseries"},
	{name='value', type='number|string',
	 doc='The value that should be present in the categorical hash'},
	call=function(self, value)
	assert(self:is_categorical(), "The series isn't categorical")

	return self:to_categorical(value) ~= nil
end}

Dataseries.boolean2categorical = argcheck{
	doc = [[
<a name="Dataseries.boolean2categorical">
### Dataseries.boolean2categorical(@ARGP)

Converts a boolean Dataseries into a categorical tensor

@ARGT

_Return value_: self, boolean indicating successful conversion
]],
	{name="self", type="Dataseries"},
	{name="false_str", type="string", default = "false",
	 doc="The string value for false"},
	{name="true_str", type="string", default = "true",
	 doc="The string value for true"},
	call=function(self, false_str, true_str)
	local _, success = self:boolean2tensor{
		false_value = 1,
		true_value = 2
	}
	if (success) then
		self.categorical = {
			[false_str]=1,
			[true_str]=2
		}
	else
		warning("Failed to convert boolean column to categorical")
	end

	return self, true
end}
