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

Set a column to categorical type.

@ARGT

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
	call = function(self, column_name, levels, labels, exclude)
	self:assert_has_column(column_name)
	self:get_column(column_name):as_categorical{
		levels = levels,
		labels = labels,
		exclude = exclude
	}

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
	call = function(self, column_array, levels, labels, exclude)
	column_array = column_array.data

	for _,cn in pairs(column_array) do
		self:as_categorical(cn, levels, labels, exclude)
	end

	return self
end}

Dataframe.add_cat_key = argcheck{
	doc =  [[
<a name="Dataframe.add_cat_key">
### Dataframe.add_cat_key(@ARGP)

Adds a key to the keyset of a categorical column. Mostly intended for internal use.

@ARGT

_Return value_: index value for key (integer)
	]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name"},
	{name="key", type="number|string", doc="The new key to insert"},
	call = function(self, column_name, key)
	self:assert_has_column(column_name)

	return self:get_column(column_name):add_cat_key{
		key = key
	}
end}

Dataframe.as_string = argcheck{
	doc =  [[
<a name="Dataframe.as_string">
### Dataframe.as_string(@ARGP)

Converts a categorical column to a string column. This can be used to revert
the Dataframe.as_categorical or as a way to convert numericals into strings.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column name"},
	call= function(self, column_name)
	self:assert_has_column(column_name)

	self:get_column(column_name):as_string()

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
	self:get_column(column_name):clean_categorical(reset_keys)

	return self
end}

Dataframe.is_categorical = argcheck{
	doc =  [[
<a name="Dataframe.is_categorical">
### Dataframe.is_categorical(@ARGP)

Check if a column is categorical

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='the name of the column'},
	call=function(self, column_name)
	self:assert_has_column(column_name)
	return self:get_column(column_name):is_categorical()
end}

Dataframe.get_cat_keys = argcheck{
	doc =  [[
<a name="Dataframe.get_cat_keys">
### Dataframe.get_cat_keys(@ARGP)

Get keys from a categorical column.

@ARGT

_Return value_: table with `["key"] = number` structure
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='the name of the column'},
	call=function(self, column_name)
	self:assert_has_column(column_name)
	return self:get_column(column_name):get_cat_keys()
end}

Dataframe.to_categorical = argcheck{
	doc =  [[
<a name="Dataframe.to_categorical">
### Dataframe.to_categorical(@ARGP)

Converts values to categorical according to a column's keys

@ARGT

_Return value_: string with the value
]],
	{name="self", type="Dataframe"},
	{name='data', type='number|torch.*Tensor|Df_Array', doc='The integer to be converted'},
	{name='column_name', type='string', doc='The name of the column  which keys to use'},
	call=function(self, data, column_name)
	self:assert_has_column(column_name)
	return self:get_column(column_name):to_categorical(data)
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
	{name='data', type='Df_Array', doc='The data to be converted'},
	{name='column_name', type='string', doc='The name of the column'},
	{name='as_tensor', type='boolean', doc='If the returned value should be a tensor', default=false},
	call=function(self, data, column_name, as_tensor)
	self:assert_has_column(column_name)
	return self:get_column(column_name):from_categorical(data, as_tensor)
end}

Dataframe.from_categorical = argcheck{
	doc=[[

@ARGT

]],
	{name="self", type="Dataframe"},
	{name='data', type='number|string', doc='The data to be converted'},
	{name='column_name', type='string', doc='The name of the column'},
	overload=Dataframe.from_categorical,
	call=function(self, data, column_name)
	self:assert_has_column(column_name)
	return self:get_column(column_name):from_categorical(data)
end}

Dataframe.boolean2categorical = argcheck{
	doc = [[
<a name="Dataframe.boolean2categorical">
### Dataframe.boolean2categorical(@ARGP)

Converts a boolean column into a torch.ByteTensor of type integer

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string",
	 doc="The boolean column that you want to convert"},
	{name="false_str", type="string", default = "false",
	 doc="The string value for false"},
	{name="true_str", type="string", default = "true",
	 doc="The string value for true"},
	call=function(self, column_name, false_str, true_str)
	self:assert_has_column(column_name)

	self:get_column(column_name):boolean2categorical{
		false_str = false_str,
		true_str = true_str
	}

	return self
end}
