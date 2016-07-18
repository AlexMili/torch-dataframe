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

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string",
	 doc="The column name to convert"},
	{name="levels", type="Df_Array|boolean",
	 doc=[[An optional array of the values that column might have taken.
	 The default is the unique set of values taken by Dataframe.unique,
	 sorted into increasing order. If you provide values that aren't present
	 within the current column the value will still be saved and may be envoked in
	 the future.]], default=false},
	{name="labels", type="Df_Array|boolean",
	 doc=[[An optional character vector of labels for the levels
	 (in the same order as levels after removing those in exclude)]],
	 default=false},
	{name="exclude", type="Df_Array|boolean",
	 doc=[[Values to be excluded when forming the set of levels. This should be
	 of the same type as column, and will be coerced if necessary.]],
	 default=false},
	{name="infer_schema", type="boolean", doc="Run the Dataframe.infer_schema after run",
	 default=true},
	call = function(self, column_name, levels, labels, exclude, infer_schema)
	self:assert_has_column(column_name)
	assert(not self:is_categorical(column_name), "Column is already categorical")

	if (not levels) then
		levels = self:unique(column_name, true, true)
	else
		levels = table.array2hash(levels.data)
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

	-- Do the conversion
	column_data = self:get_column(column_name)
	self.categorical[column_name] = levels
	for i,v in ipairs(column_data) do
		if (levels[v] == nil) then
			self.dataset[column_name][i] = 0/0
		else
			self.dataset[column_name][i] = levels[v]
		end
	end

	if (labels) then
		labels = labels.data
		assert(table.exact_length(levels),
		       #labels,
		       "The labels must match the levels in length")
		self.categorical[column_name] = table.array2hash(labels)
	end

	if (infer_schema) then
		self:_infer_schema()
	end

	return self
end}

Dataframe.as_categorical = argcheck{
	overload=Dataframe.as_categorical,
	doc =  [[

@ARGT

]],
	{name="self", type="Dataframe"},
	{name="column_array", type="Df_Array",
	 doc="An array with column names"},
	{name="levels", type="Df_Array|boolean",
	 doc=[[An optional array of the values that column might have taken.
	 The default is the unique set of values taken by Dataframe.unique,
	 sorted into increasing order. If you provide values that aren't present
	 within the current column the value will still be saved and may be envoked in
	 the future.]], default=false},
	{name="labels", type="Df_Array|boolean",
	 doc=[[An optional character vector of labels for the levels
	 (in the same order as levels after removing those in exclude)]],
	 default=false},
	{name="exclude", type="Df_Array|boolean",
	 doc=[[Values to be excluded when forming the set of levels. This should be
	 of the same type as column, and will be coerced if necessary.]],
	 default=false},
	{name="infer_schema", type="boolean", doc="Run the Dataframe.infer_schema after run",
	 default=true},
	call = function(self, column_array, levels, labels, exclude, infer_schema)
	column_array = column_array.data

	for _,cn in pairs(column_array) do
		self:as_categorical(cn, levels, labels, exclude, infer_schema)
	end

	if (infer_schema) then
		self:_infer_schema()
	end

	return self
end}

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
	self:assert_has_column(column_name)
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

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name"},
	call= function(self, column_name)
	self:assert_has_column(column_name)
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

	return self
end}

Dataframe.clean_categorical = argcheck{
	doc =  [[
<a name="Dataframe.clean_categorical">
### Dataframe.clean_categorical(@ARGP)

@ARGT

Removes any categories no longer present from the keys

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='the name of the column'},
	{name='reset_keys', type='boolean', doc='if all the keys should be reinitialized', default=false},
	call=function(self, column_name, reset_keys)
	self:assert_has_column(column_name)
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

	return self
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
	self:assert_has_column(column_name)
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
	self:assert_has_column(column_name)
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
	self:assert_has_column(column_name)
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
			       v .. " isn't present in the keyset among " ..
			table.get_key_string(self.categorical[column_name]))
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
	self:assert_has_column(column_name)
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
