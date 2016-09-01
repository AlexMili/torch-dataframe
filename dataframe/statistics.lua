local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Statistical functions

]]

Dataframe.unique = argcheck{
	doc =  [[
<a name="Dataframe.unique">
### Dataframe.unique(@ARGP)

Get unique elements given a column name

@ARGT

_Return value_:  table with unique values or if as_keys == true then the unique
	value as key with an incremental integer value => {'unique1':1, 'unique2':2, 'unique6':3}
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', help='column to inspect', req=true},
	{name='as_keys', type='boolean',
	 help='return table with unique as keys and a count for frequency',
	 default=false},
	{name='as_raw', type='boolean',
	 help='return table with raw data without categorical transformation',
	 default=false},
	call=function(self, column_name, as_keys, as_raw)
	self:assert_has_column(column_name)

	return self:get_column(column_name):unique{as_keys = as_keys, as_raw = as_raw}
end}

Dataframe.value_counts = argcheck{
	doc =  [[
<a name="Dataframe.value_counts">
### Dataframe.value_counts(@ARGP)

Counts number of occurences for each unique element (frequency/histogram) in
a single column or set of columns. If a single column is requested then it returns
a simple table with element names as keys and counts/proportions as values.
If multiple keys have been requested it returns a table wrapping the single
column counts with column name as key.

@ARGT

_Return value_: Dataframe or nested table
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column to inspect'},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
 {name='as_dataframe', type='boolean', default=true,
	doc="Return a dataframe"},
	call=function(self, column_name, normalize, dropna, as_dataframe)
	self:assert_has_column(column_name)

	return self:get_column(column_name):value_counts{
		normalize = normalize,
		dropna = dropna,
		as_dataframe = as_dataframe
	}
end}

Dataframe.value_counts = argcheck{
	doc =  [[
Use the columns argument together with a Df_Array for specifying columns

@ARGT

_Return value_: Table or Dataframe
]],
	overload=Dataframe.value_counts,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The columns to inspect', opt=true},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, normalize, dropna, as_dataframe)
	if (columns) then
		columns = columns.data
	else
		columns = self:get_numerical_colnames()
	end

	assert(#columns > 0, "You haven't provided any columns")

	local value_counts = {}
	if (as_dataframe) then
		value_counts = Dataframe.new()
	end

	for _,cn in pairs(columns) do
		local ret = self:value_counts{
			column_name = cn,
			normalize = normalize,
			dropna = dropna,
			as_dataframe = as_dataframe
		}

		if (as_dataframe) then
			ret:add_column('column', 1, cn)
			value_counts:append(ret)
		else
			value_counts[cn] = ret
		end
	end

	return value_counts
end}

Dataframe.which_max = argcheck{
	doc =  [[
<a name="Dataframe.which_max">
### Dataframe.which_max(@ARGP)

Retrieves the index for the rows with the highest value. Can be > 1 rows that
share the highest value.

@ARGT

_Return value_: Table, max value
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column to inspect'},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):which_max()
end}

Dataframe.which_min = argcheck{
	doc =  [[
<a name="Dataframe.which_min">
### Dataframe.which_min(@ARGP)

Retrieves the index for the rows with the lowest value. Can be > 1 rows that
share the lowest value.

@ARGT

_Return value_: table with the lowest indexes, lowest value
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column to inspect'},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):which_min()
end}

Dataframe.get_mode = argcheck{
	doc =  [[
<a name="Dataframe.get_mode">
### Dataframe.get_mode(@ARGP)

Gets the mode for a Dataseries. A mode is defined as the most frequent value.
Note that if two or more values are equally common then there are several modes.
The mode is useful as it can be viewed as any algorithms most naive guess where
it always guesses the same value.

@ARGT

_Return value_: Table or Dataframe
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column to inspect'},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, column_name, normalize, dropna, as_dataframe)
	self:assert_has_column(column_name)

	return self:get_column(column_name):get_mode{
		normalize = normalize,
		dropna = dropna,
		as_dataframe = as_dataframe
	}
end}

Dataframe.get_mode = argcheck{
	doc =  [[

@ARGT

]],
	overload=Dataframe.get_mode,
	{name="self", type="Dataframe"},
	{name="columns", type="Df_Array", doc="The columns of interest", opt=true},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, normalize, dropna, as_dataframe)
	if (columns) then
		columns = columns.data
	else
		columns = self:get_numerical_colnames()
	end

	local modes = {}
	if (as_dataframe) then
		modes = Dataframe.new()
	end

	for i = 1,#columns do
		local cn = columns[i]
		local value =
			self:get_mode{column_name = cn,
			              normalize = normalize,
			              dropna = dropna,
			              as_dataframe = as_dataframe}
		if (as_dataframe) then
			value:add_column{
				column_name = 'Column',
				pos = 1,
				default_value = cn,
				type = "string"
			}
			modes:append(value)
		else
			modes[cn] = value
		end
	end

	return modes
end}

Dataframe.get_max_value = argcheck{
	doc=[[
<a name="Dataframe.get_max_value">
### Dataframe.get_max_value(@ARGP)

Gets the maximum value. Similar in function to which_max but it will also return
the maximum integer value for the categorical values. This can be useful when
deciding on the number of neurons in the final layer.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The name of the column'},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):get_max_value()
end}

Dataframe.get_max_value = argcheck{
	doc=[[
You can in addition choose or supplying a Df_Array with the columns of interest

@ARGT

_Return value_: Table or Dataframe
]],
	overload=Dataframe.get_max_value,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The names of the columns of interest', opt=true},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, with_named_keys, as_dataframe)
	if (columns) then
		columns = columns.data
	else
		columns = self:get_numerical_colnames()
	end

	ret = {}
	for col_no = 1,#self.column_order do
		local cn = self.column_order[col_no]
		if (table.has_element(columns, cn)) then
			local max = self:get_max_value(cn)
			if (with_named_keys) then
				ret[cn] = max
			else
				table.insert(ret, max)
			end
		end
	end

	if (as_dataframe) then
		if (with_named_keys) then
			ret = convert_table_2_dataframe(Df_Tbl(ret))
		else
			ret = Dataframe.new(Df_Dict({value=ret}))
		end
	end

	return ret
end}

Dataframe.get_min_value = argcheck{
	doc=[[
<a name="Dataframe.get_min_value">
### Dataframe.get_min_value(@ARGP)

Gets the minimum value for a given column. Returns minimum values for all
numerical columns if none is provided.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The name of the column'},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):get_min_value()
end}

Dataframe.get_min_value = argcheck{
	doc=[[
You can in addition choose or supplying a Df_Array with the columns of interest

@ARGT

_Return value_: Table or Dataframe
]],
	overload=Dataframe.get_min_value,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The names of the columns of interest', opt=true},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, with_named_keys, as_dataframe)
	if (columns) then
		columns = columns.data
	else
		columns = self:get_numerical_colnames()
	end

	ret = {}
	for col_no = 1,#self.column_order do
		local cn = self.column_order[col_no]
		if (table.has_element(columns, cn)) then
			local max = self:get_min_value(cn)
			if (with_named_keys) then
				ret[cn] = max
			else
				table.insert(ret, max)
			end
		end
	end

	if (as_dataframe) then
		if (with_named_keys) then
			ret = convert_table_2_dataframe(Df_Tbl(ret))
		else
			ret = Dataframe.new(Df_Dict({value=ret}))
		end
	end

	return ret
end}
