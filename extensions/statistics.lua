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

	local unique = {}

	local column_values =
		self:get_column{column_name = column_name,
		                as_raw = as_raw}

	for i = 1,self.n_rows do
		local current_key_value = column_values[i]
		if (current_key_value ~= nil and
		    not isnan(current_key_value)) then

			-- Check if has hash
			if (unique[current_key_value] == nil) then
				unique[current_key_value] = true
			end

		end
	end

	-- Extract an array with values
	local unique_values = {}
	for k,_ in pairs(unique) do
		unique_values[#unique_values + 1] = k
	end
	table.sort(unique_values)

	if as_keys == false then
		return unique_values
	else
		-- Set the index in the original unique table, actually just a table flip
		--  where the value becomes the key and the index the value
		--  We reuse the unique just for convenience
		for index,key in ipairs(unique_values) do
			unique[key] = index
		end

		return unique
	end
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

	if (not as_dataframe) then
		return count
	end

	local data = {values  = {}, count = {}}
	local i = 0
	for v,c in pairs(count) do
		i = i + 1
		data.values[i] = v
		data.count[i] = c
	end
	return Dataframe.new(Df_Dict(data))
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
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, normalize, dropna, as_dataframe)
	return self:value_counts(Df_Array(self:get_numerical_colnames()), normalize, dropna, as_dataframe)
end}

Dataframe.value_counts = argcheck{
	doc =  [[
Use the columns argument together with a Df_Array for specifying columns

@ARGT

_Return value_: Table or Dataframe
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
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, normalize, dropna, as_dataframe)
	columns = columns.data
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
	assert(self:is_numerical(column_name) and not self:is_categorical(column_name),
	       "Column has to be numerical")

	local highest_indx = {}
	local highest = false
	local values = self:get_column(column_name)
	for i=1,self.n_rows do
		local v = values[i]
		if (not highest or highest < v) then
			highest = v
			highest_indx = {i}
		elseif (highest == v) then
			table.insert(highest_indx, i)
		end
	end

	return highest_indx, highest
end}

Dataframe.which_min = argcheck{
	doc =  [[
<a name="Dataframe.which_min">
### Dataframe.which_min(@ARGP)

Retrieves the index for the rows with the lowest value. Can be > 1 rows that
share the lowest value.

@ARGT

_Return value_: Table, lowest value
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column to inspect'},
	call=function(self, column_name)
	self:assert_has_column(column_name)
	assert(self:is_numerical(column_name) and not self:is_categorical(column_name),
	       "Column has to be numerical")

	local lowest_indx = {}
	local lowest = false
	local values = self:get_column(column_name)
	for i=1,self.n_rows do
		local v = values[i]
		if (not lowest or lowest > v) then
			lowest = v
			lowest_indx = {i}
		elseif (lowest == v) then
			table.insert(lowest_indx, i)
		end
	end

	return lowest_indx, lowest
end}

Dataframe.get_mode = argcheck{
	doc =  [[
<a name="Dataframe.get_mode">
### Dataframe.get_mode(@ARGP)

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

	local counts = self:value_counts{column_name = column_name,
	                                 normalize = normalize,
	                                 dropna = dropna,
	                                 as_dataframe = false}
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

	if (as_dataframe) then
		modes = self:_convert_table_2_dataframe(Df_Tbl(modes))
	end

	return modes
end}

Dataframe._convert_table_2_dataframe = argcheck{
	{name="self", type="Dataframe"},
	{name="tbl", type="Df_Tbl"},
	{name="value_name", type="string", default="value",
	 doc="The name of the value column"},
	{name="key_name", type="string", default="key",
	 doc="The name of the key column"},
	call=function(self, tbl, value_name, key_name)
	tbl = tbl.data

	local tmp = {[value_name]={}, [key_name]={}}
	for key, value in pairs(tbl) do
		table.insert(tmp[value_name], value)
		table.insert(tmp[key_name], key)
	end

	return Dataframe.new(Df_Dict(tmp), Df_Array(key_name, value_name))
end}

Dataframe.get_mode = argcheck{
	doc =  [[
If you provide no column name then all numerical columns will be used

@ARGT

]],
	overload=Dataframe.get_mode,
	{name="self", type="Dataframe"},
	{name='normalize', type='boolean', default=false,
	 doc=[[
	 	If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	 call=function(self, normalize, dropna, as_dataframe)
	return self:get_mode(Df_Array(self:get_numerical_colnames()), normalize, dropna, as_dataframe)
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
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, normalize, dropna, as_dataframe)
	columns = columns.data

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
			value:add_column('Column', 1, cn)
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

Gets the maximum value for a given column. Returns maximum values for all
numerical columns if none is provided. Keeps the order although not if
with_named_keys == true as the keys will be sorted in alphabetic order.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='The name of the column'},
	call=function(self, column_name)
	self:assert_has_column(column_name)

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

	if (isnan(max)) then
		self:output()
	end
	return max
end}

Dataframe.get_max_value = argcheck{
	doc=[[
You can in addition choose or supplying a Df_Array with the columns of interest

@ARGT

_Return value_: Table or Dataframe
]],
	overload=Dataframe.get_max_value,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The names of the columns of interest'},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, with_named_keys, as_dataframe)
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

	if (as_dataframe) then
		if (with_named_keys) then
			ret = self:_convert_table_2_dataframe(Df_Tbl(ret))
		else
			ret = Dataframe.new(Df_Dict({value=ret}))
		end
	end

	return ret
end}

Dataframe.get_max_value = argcheck{
	doc=[[
You can in addition choose all numerical columns by skipping the column name

@ARGT
]],
	overload=Dataframe.get_max_value,
	{name="self", type="Dataframe"},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, with_named_keys, as_dataframe)
	return self:get_max_value(Df_Array(self:get_numerical_colnames()), with_named_keys, as_dataframe)
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
	self:assert_has_column(column_name)

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

_Return value_: Table or Dataframe
]],
	overload=Dataframe.get_min_value,
	{name="self", type="Dataframe"},
	{name='columns', type='Df_Array', doc='The names of the columns of interest'},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, with_named_keys, as_dataframe)
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

	if (as_dataframe) then
		if (with_named_keys) then
			ret = self:_convert_table_2_dataframe(Df_Tbl(ret))
		else
			ret = Dataframe.new(Df_Dict({value=ret}))
		end
	end

	return ret
end}

Dataframe.get_min_value = argcheck{
	doc=[[
You can in addition choose all numerical columns by skipping the column name

@ARGT
]],
	overload=Dataframe.get_min_value,
	{name="self", type="Dataframe"},
	{name='with_named_keys', type='boolean', doc='If the index should be named keys', default=false},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, with_named_keys, as_dataframe)
	return self:get_min_value(Df_Array(self:get_numerical_colnames()), with_named_keys, as_dataframe)
end}
