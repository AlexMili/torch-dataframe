local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Categorical functions

]]

Dataframe.as_categorical = argcheck{
	doc =  [[
<a name="Dataframe.as_categorical">
### Dataframe.as_categorical(@ARGP)

@ARGT

Set a column to categorical type. Adds the column to self.categorical table with
the keuys retrieved from Dataframe.unique.

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string",
	 doc="The column name to convert"},
	call = function(self, column_name)
		return self:as_categorical(Df_Array(column_name))
end}

Dataframe.as_categorical = argcheck{
	overload=Dataframe.as_categorical,
	doc =  [[

@ARGT

]],
	{name="self", type="Dataframe"},
	{name="column_array", type="Df_Array",
	 doc="An array with column names"},
	call = function(self, column_array)
	column_array = column_array.data

	for _,cn in pairs(column_array) do
		assert(self:has_column(cn), "Could not find column: " .. cn)
		assert(not self:is_categorical(cn), "Column already categorical")

		keys = self:unique(cn, true, true)
		-- drop '' as a key
		keys[''] = nil
		column_data = self:get_column(cn)
		self.categorical[cn] = keys
		for i,v in ipairs(column_data) do
			if (keys[v] == nil) then
				self.dataset[cn][i] = 0/0
			else
				self.dataset[cn][i] = keys[v]
			end
		end
	end
	self:_infer_schema()
end
}

Dataframe.add_cat_key = argcheck{
	doc =  [[
<a name="Dataframe.add_cat_key">
### Dataframe.add_cat_key(@ARGP)

@ARGT

Adds a key to the keyset of a categorical column. Mostly intended for internal use.

_Return value_: index value for key (integer)
	]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name"},
	{name="key", type="number|string", doc="The new key to insert"},
	call = function(self, column_name, key)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	assert(self:is_categorical(column_name), "The column isn't categorical: " .. tostring(column_name))
	assert(not isnan(key), "You can't add a nan key to "  .. tostring(column_name))
	keys = self:get_cat_keys(column_name)
	key_index = table.exact_length(keys) + 1
	keys[key] = key_index
	self.categorical[column_name] = keys
	return key_index
end}

Dataframe.as_string = argcheck{
	doc =  [[
<a name="Dataframe.as_string">
### Dataframe.as_string(@ARGP)

@ARGT

Converts a categorical column to a string column. This can be used to revert
the Dataframe.as_categorical or as a way to convert numericals into strings.

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name"},
	call= function(self, column_name)
	assert(self:has_column(column_name), "Could not find column: " .. column_name)
	if (self:is_categorical(column_name)) then
		self.dataset[column_name] = self:get_column{column_name = column_name,
	                                              as_raw = false}
		self.categorical[column_name] = nil
	elseif(self:is_numerical(column_name)) then
		data = self:get_column(column_name)
		for i = 1,#self.n_rows do
			if (not isnan(data[i])) then
				data[i] = tostring(data[i])
			end
		end
		self.dataset[column_name] = data
	end
	self:_refresh_metadata()
	self:_infer_schema()
end}

Dataframe.clean_categorical = argcheck{
	doc =  [[
<a name="Dataframe.clean_categorical">
### Dataframe.clean_categorical(@ARGP)

@ARGT

Removes any categories no longer present from the keys

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='the name of the column'},
	{name='reset_keys', type='boolean', doc='if all the keys should be reinitialized', default=false},
	call=function(self, column_name, reset_keys)
	assert(self:has_column(column_name), "Couldn't find column: " .. tostring(column_name))
	assert(self:is_categorical(column_name), tostring(column_name) .. " isn't categorical")
	if (reset_keys) then
		self:as_string(column_name)
		self:as_categorical(column_name)
	else
		keys = self:get_cat_keys(column_name)
		vals = self:get_column(column_name)
		found_keys = {}
		for _,v in pairs(vals) do
			if (keys[v] ~= nil and not isnan(v)) then
				found_keys[v] = v
			end
		end
		for v,_ in pairs(keys) do
			if (found_keys[v] == nil) then
				keys[v] = nil
			end
		end
		self.categorical[column_name] = keys
	end
end}

Dataframe.is_categorical = argcheck{
	doc =  [[
<a name="Dataframe.is_categorical">
### Dataframe.is_categorical(@ARGP)

@ARGT

Check if a column is categorical

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='the name of the column'},
	call=function(self, column_name)
	assert(self:has_column(column_name), "This column doesn't exist")
	return self.categorical[column_name] ~= nil
end}

Dataframe.get_cat_keys = argcheck{
	doc =  [[
<a name="Dataframe.get_cat_keys">
### Dataframe.get_cat_keys(@ARGP)

@ARGT

Get keys from a categorical column.

_Return value_: table with `["key"] = number` structure
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='the name of the column'},
	call=function(self, column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	assert(self:is_categorical(column_name), "The " .. tostring(column_name) .. " isn't a categorical column")
  return self.categorical[column_name]
end}

Dataframe.to_categorical = argcheck{
	doc =  [[
<a name="Dataframe.to_categorical">
### Dataframe.to_categorical(@ARGP)

@ARGT

Converts values to categorical according to a column's keys

_Return value_: string with the value
]],
	{name="self", type="Dataframe"},
	{name='data', type='number', doc='The integer to be converted'},
	{name='column_name', type='string', doc='The name of the column  which keys to use'},
	call=function(self, data, column_name)
	ret = self:to_categorical(Df_Array(data), column_name)
	return ret[1]
end}

Dataframe.to_categorical = argcheck{
	doc =  [[
You can also provide a tensor

@ARGT

_Return value_: table with values
]],
	overload=Dataframe.to_categorical,
	{name="self", type="Dataframe"},
	{name='data', type='torch.*Tensor', doc='The integers to be converted'},
	{name='column_name', type='string', doc='The name of the column  which keys to use'},
	call=function(self, data, column_name)
	assert(#data:size() == 1,
	       "The function currently only supports single dimensional tensors")
	return self:to_categorical(Df_Array(torch.totable(data)), column_name)
end}

Dataframe.to_categorical = argcheck{
	doc =  [[
You can also provide an array

@ARGT

_Return value_: table with values
]],
	overload=Dataframe.to_categorical,
	{name="self", type="Dataframe"},
	{name='data', type='Df_Array', doc='The integers to be converted'},
	{name='column_name', type='string', doc='The name of the column  which keys to use'},
	call=function(self, data, column_name)
	assert(self:has_column(column_name), "Invalid column name: " .. column_name)
	assert(self:is_categorical(column_name), "Column isn't categorical")

	data = data.data

	for k,v in pairs(data) do
		if (not isnan(data[k])) then
			val = tonumber(data[k])
			assert(type(val) == 'number',
			       "The data ".. tostring(val) .." in position " .. k .. " is not a valid number")
			data[k] = val
			assert(math.floor(data[k]) == data[k],
			       "The data " .. data[k] .. " in position " .. k .. " is not a valid integer")
		end
	end

	ret = {}
	for _,v in pairs(data) do
		local val = nil
		if (isnan(v)) then
			val = 0/0
		else
			for k,index in pairs(self.categorical[column_name]) do
				if (index == v) then
					val = k
					break
				end
			end
			assert(val ~= nil,
			       v .. " isn't present in the keyset")
		end
		table.insert(ret, val)
	end

	return ret
end}

Dataframe.from_categorical = argcheck{
	doc =  [[
<a name="Dataframe.from_categorical">
### Dataframe.from_categorical(@ARGP)

@ARGT

Converts categorical to numerical according to a column's keys

_Return value_: table or tensor
]],
	{name="self", type="Dataframe"},
	{name='data', type='number|string', doc='The data to be converted'},
	{name='column_name', type='string', doc='The name of the column'},
	{name='as_tensor', type='boolean', doc='If the returned value should be a tensor', default=false},
	call=function(self, data, column_name, as_tensor)
		return self:from_categorical(Df_Array(data), column_name, as_tensor)
end}

Dataframe.from_categorical = argcheck{
	doc =  [[
You can also provide an array with values

@ARGT

_Return value_: table or tensor
]],
	overload=Dataframe.from_categorical,
	{name="self", type="Dataframe"},
	{name='data', type='Df_Array', doc='The data to be converted'},
	{name='column_name', type='string', doc='The name of the column'},
	{name='as_tensor', type='boolean', doc='If the returned value should be a tensor', default=false},
	call=function(self, data, column_name, as_tensor)
	assert(self:has_column(column_name), "Can't find the column: " .. column_name)
	assert(self:is_categorical(column_name), "Column isn't categorical")

	data = data.data

	ret = {}
	for _,v in pairs(data) do
		local val = self.categorical[column_name][v]
		if (val == nil) then
			val = 0/0
		end
		table.insert(ret, val)
	end

	if (as_tensor) then
		return torch.Tensor(ret)
	else
		return ret
	end
end}
