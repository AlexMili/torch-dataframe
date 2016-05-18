local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Statistical functions

]]

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

_Return value_: Table
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column to inspect'},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	call=function(self, column_name, normalize, dropna)
	assert(self:has_column(column_name),
				 "Invalid column name: " .. tostring(column_name))

	count = {}
	-- Experiencing odd behavior with large data > 254459 rows
	--  better to use raw data and then convert the names at the end
	column_data = self:get_column{column_name = column_name,
																as_raw = true}
	no_missing = 0
	for i = 1,self.n_rows do
		current_key_value = column_data[i]
		if (not isnan(current_key_value)) then
			assert(current_key_value ~= nil, "invalid data for row " .. i)

			if (count[current_key_value] == nil) then
				count[current_key_value] = 1
			else
				count[current_key_value] = count[current_key_value] + 1
			end
		else
			no_missing = no_missing + 1
		end
	end

	if (self:is_categorical(column_name)) then
		count_w_keys = {}
		for key,no_found in pairs(count) do
			name = self:to_categorical(key, column_name)
			count_w_keys[name] = no_found
		end
		count = count_w_keys
	end

	if (not dropna) then
		count["_missing_"] = no_missing
	end

	if (normalize) then
		total = 0
		for _,n in pairs(count) do
			total = total + n
		end
		for i,n in pairs(count) do
			count[i] = n/total
		end
	end
	return count
end}

Dataframe.value_counts = argcheck{
	doc =  [[
If columns is left out then all numerical columns are used

@ARGT

]],
	overload=Dataframe.value_counts,
	{name="self", type="Dataframe"},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	call=function(self, normalize, dropna)
	return self:value_counts(Df_Array(self:get_numerical_colnames()), normalize, dropna)
end}

Dataframe.value_counts = argcheck{
	doc =  [[
Use the columns argument together with a Df_Array for specifying columns

@ARGT

_Return value_: Table
]],
	overload=Dataframe.value_counts,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The columns to inspect'},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	call=function(self, columns, normalize, dropna)
	columns = columns.data
	assert(#columns > 0, "You haven't provided any columns")

	value_counts = {}
	for _,cn in pairs(columns) do
		value_counts[cn] = self:value_counts{
			column_name = cn,
			normalize = normalize,
			dropna = dropna
		}
	end

	return value_counts
end}

Dataframe.get_mode = argcheck{
	doc =  [[
<a name="Dataframe.get_mode">
### Dataframe.get_mode(@ARGP)

@ARGT

_Return value_: Table
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column to inspect'},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	call=function(self, column_name, normalize, dropna)

	local counts = self:value_counts{column_name = column_name,
	                                 normalize = normalize,
	                                 dropna = dropna}
	local max_val = 0/0
	for _,v in pairs(counts) do
		if (isnan(max_val) or max_val < v) then
			max_val  = v
		end
	end

	local modes = {}
	for key,v in pairs(counts) do
		if (max_val == v) then
			modes[key] = v
		end
	end
	return modes
end}

Dataframe.get_mode = argcheck{
	doc =  [[
If you provide no column name then all numerical columns will be used

@ARGT

_Return value_: Table
]],
	overload=Dataframe.get_mode,
	{name="self", type="Dataframe"},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	 call=function(self, normalize, dropna)
	return self:get_mode(Df_Array(self:get_numerical_colnames()), normalize, dropna)
end}

Dataframe.get_mode = argcheck{
	doc =  [[

@ARGT

]],
	overload=Dataframe.get_mode,
	{name="self", type="Dataframe"},
	{name="columns", type="Df_Array", doc="The columns of interest"},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	call=function(self, columns, normalize, dropna)
	columns = columns.data

	local modes = {}
	for i = 1,#columns do
		local cn = columns[i]
		local key, value =
			self:get_mode{column_name = cn,
			              normalize = normalize,
			              dropna = dropna}
		modes[cn] = key
	end

	return modes
end}

Dataframe.get_max_value = argcheck{
	doc=[[
<a name="Dataframe.get_max_value">
### Dataframe.get_max_value(@ARGP)

Gets the maximum value for a given column. Returns maximum values for all
numerical columns if none is provided. Keeps the order although not if
with_named_keys == true as the keys will be sorted in alphabetic order.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The name of the column'},
	call=function(self, column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(k))

	local max = 0/0
	if (self:is_categorical(column_name)) then
		for k,i in pairs(self:get_cat_keys(column_name)) do
			if (isnan(max)) then
				max = i
			elseif (i > max) then
				max = i
			end
		end
	elseif (self:is_numerical(column_name)) then
		for _,v in pairs(self:get_column{column_name = column_name, as_raw = true}) do
			if (isnan(max)) then
				max = v
			elseif (v > max) then
				max = v
			end
		end
	end

	return max
end}

Dataframe.get_max_value = argcheck{
	doc=[[
You can in addition choose or supplying a Df_Array with the columns of interest

@ARGT

_Return value_: Table
]],
	overload=Dataframe.get_max_value,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The names of the columns of interest'},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	call=function(self, columns, with_named_keys)
	columns = columns.data

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

  return ret
end}

Dataframe.get_max_value = argcheck{
	doc=[[
You can in addition choose all numerical columns by skipping the column name

@ARGT

_Return value_: Table
]],
	overload=Dataframe.get_max_value,
	{name="self", type="Dataframe"},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	call=function(self, with_named_keys)
	return self:get_max_value(Df_Array(self:get_numerical_colnames()), with_named_keys)
end}

Dataframe.get_min_value = argcheck{
	doc=[[
<a name="Dataframe.get_min_value">
### Dataframe.get_min_value(@ARGP)

Gets the minimum value for a given column. Returns minimum values for all
numerical columns if none is provided. Keeps the order although not if
with_named_keys == true as the keys will be sorted according to Lua's hash table
algorithm.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The name of the column'},
	call=function(self, column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))

	local min = 0/0
	if (self:is_categorical(column_name)) then
		for k,i in pairs(self:get_cat_keys(column_name)) do
			if (isnan(min)) then
				min = i
			elseif (i < min) then
				min = i
			end
		end
	elseif (self:is_numerical(column_name)) then
		for _,v in pairs(self:get_column{column_name = column_name, as_raw = true}) do
			if (isnan(min)) then
				min = v
			elseif (v < min) then
				min = v
			end
		end
	end

	return min
end}

Dataframe.get_min_value = argcheck{
	doc=[[
You can in addition choose or supplying a Df_Array with the columns of interest

@ARGT

_Return value_: Table
]],
	overload=Dataframe.get_min_value,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The names of the columns of interest'},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	call=function(self, columns, with_named_keys)
	columns = columns.data

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

  return ret
end}

Dataframe.get_min_value = argcheck{
	doc=[[
You can in addition choose all numerical columns by skipping the column name

@ARGT

_Return value_: Table
]],
	overload=Dataframe.get_min_value,
	{name="self", type="Dataframe"},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	call=function(self, with_named_keys)
	return self:get_min_value(Df_Array(self:get_numerical_colnames()), with_named_keys)
end}
