local params = {...}
local Dataseries = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Statistics

Here are functions gather commmonly used descriptive statistics

]]

Dataseries.count_na = argcheck{
	doc = [[
<a name="Dataseries.count_na">
### Dataseries.count_na(@ARGP)

Count missing values

@ARGT

_Return value_: number
]],
	{name="self", type="Dataseries"},
	call=function(self)
	-- Thanks to the tds.Hash this is a valid
	return #self.missing
end}

Dataseries.unique = argcheck{
	doc =  [[
<a name="Dataseries.unique">
### Dataseries.unique(@ARGP)

Get unique elements

@ARGT

_Return value_: tds.Vec with unique values or
	tds.Hash if as_keys == true then the unique
	value as key with an incremental integer
	value => {'unique1':1, 'unique2':2, 'unique6':3}
]],
	{name="self", type="Dataseries"},
	{name='as_keys', type='boolean',
	 help='return table with unique as keys and a count for frequency',
	 default=false},
	{name='as_raw', type='boolean',
	 help='return table with raw data without categorical transformation',
	 default=false},
	call=function(self, as_keys, as_raw)

	local unique = tds.Hash()
	for i = 1,self:size() do
		local current_key_value = self:get(i, as_raw)
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

Dataseries.value_counts = argcheck{
	doc =  [[
<a name="Dataseries.value_counts">
### Dataseries.value_counts(@ARGP)

Counts number of occurences for each unique element (frequency/histogram).

@ARGT

_Return value_: Dataframe|table
]],
	{name="self", type="Dataseries"},
	{name='normalize', type='boolean', default=false,
	 doc=[[
		If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	{name='as_raw', type='boolean', default=false,
	 doc="Use raw numerical values instead of category label for categoricals"},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a Dataframe with `value` and `count` columns"},
	call=function(self, normalize, dropna, as_raw, as_dataframe)

	count = tds.Hash()
	no_missing = 0
	for i = 1,self:size() do
		current_key_value = self:get(i, as_raw)
		if (not isnan(current_key_value)) then

			if (count[current_key_value] == nil) then
				count[current_key_value] = 1
			else
				count[current_key_value] = count[current_key_value] + 1
			end

		else
			no_missing = no_missing + 1
		end
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

	return convert_table_2_dataframe{
		tbl = Df_Tbl(count),
		value_name = "count",
		key_name = "values"
	}
end}

Dataseries.which_max = argcheck{
	doc =  [[
<a name="Dataseries.which_max">
### Dataseries.which_max(@ARGP)

Retrieves the index for the rows with the highest value. Can be > 1 rows that
share the highest value.

@ARGT

_Return value_: table with the highest indexes, max value
]],
	{name="self", type="Dataseries"},
	call=function(self)
	assert(self:is_numerical() and not self:is_categorical(),
	       "Column has to be numerical: " .. self:get_variable_type() ..
	       " and not categorical: " .. tostring(self:is_categorical()))

	local indx = torch.range(1, self:size())
	local mask = self:get_data_mask()
	local data = self.data:maskedSelect(mask)
	local highest = self:get_max_value()
	indx = indx:maskedSelect(mask):maskedSelect(data:eq(highest):byte())
	return indx:totable(), highest
end}

Dataseries.which_min = argcheck{
	doc =  [[
<a name="Dataseries.which_min">
### Dataseries.which_min(@ARGP)

Retrieves the index for the rows with the lowest value. Can be > 1 rows that
share the lowest value.

@ARGT

_Return value_: table with the lowest indexes, lowest value
]],
	{name="self", type="Dataseries"},
	call=function(self)
	assert(self:is_numerical() and not self:is_categorical(),
	       "Column has to be numerical: " .. self:get_variable_type() ..
	       " and not categorical: " .. tostring(self:is_categorical()))

	local indx = torch.range(1, self:size())
	local mask = self:get_data_mask()
	local data = self.data:maskedSelect(mask)
	local lowest = self:get_min_value()
	indx = indx:maskedSelect(mask):maskedSelect(data:eq(lowest):byte())
	return indx:totable(), lowest
end}

Dataseries.get_mode = argcheck{
	doc =  [[
<a name="Dataseries.get_mode">
### Dataseries.get_mode(@ARGP)

Gets the mode for a Dataseries. A mode is defined as the most frequent value.
Note that if two or more values are equally common then there are several modes.
The mode is useful as it can be viewed as any algorithms most naive guess where
it always guesses the same value.

@ARGT

_Return value_: Table or Dataframe
]],
	{name="self", type="Dataseries"},
	{name='normalize', type='boolean', default=false,
	 doc=[[
		If True then the object returned will contain the relative frequencies of
		the unique values.]]},
	{name='dropna', type='boolean', default=true,
	 doc="Don’t include counts of NaN (missing values)."},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, normalize, dropna, as_dataframe)

	local mode_ret = {}
	if (torch.type(self.data):match("torch.*Tensor")) then
		local data = self.data:maskedSelect(self:get_data_mask())
		local org_size = data:size(1)
		if (not dropna) then
			org_size = self:size()
		end

		-- Since several variables may have the same frequency they should
		-- all be set as the mode. Torch only returns the most common variable
		-- and therefore we need to loop through all the possible modes
		local last_mode_val = 0/0
		while #data:size() > 0 and data:size(1) > 0 do
			local mode = data:mode()[1]
			mode_key = mode
			if (self:is_categorical()) then
				mode_key = self:to_categorical(mode)
			end
			local val = data:eq(mode):sum()

			-- This catches the case where we want to study missing
			if (isnan(last_mode_val) and
			    not dropna and val <= self:count_na()) then
				mode_key = "NA"
				val = self:count_na()
			end

			if (normalize) then
				val = val / org_size
			end

			if (not isnan(last_mode_val) and val < last_mode_val) then
				break
			end

			mode_ret[mode_key] = val

			-- Remove the previous mode from the data
			data = data:maskedSelect(data:ne(mode):byte())
			last_mode_val = val
		end
	else
		local counts = self:value_counts{normalize = normalize,
		                                 dropna = dropna,
		                                 as_dataframe = false}
		local max_val = 0/0
		for _,v in pairs(counts) do
			if (isnan(max_val) or max_val < v) then
				max_val  = v
			end
		end

		for key,v in pairs(counts) do
			if (max_val == v) then
				mode_ret[key] = v
			end
		end
	end

	if (as_dataframe) then
		mode_ret = convert_table_2_dataframe(Df_Tbl(mode_ret))
	end

	return mode_ret
end}

Dataseries.get_max_value = argcheck{
	doc=[[
<a name="Dataseries.get_max_value">
### Dataseries.get_max_value(@ARGP)

Gets the maximum value. Similar in function to which_max but it will also return
the maximum integer value for the categorical values. This can be useful when
deciding on the number of neurons in the final layer.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataseries"},
	call=function(self)

	if (self:is_categorical()) then
		local max = 0/0
		for k,i in pairs(self:get_cat_keys()) do
			if (isnan(max)) then
				max = i
			elseif (i > max) then
				max = i
			end
		end

		return max
	end

	assert(self:is_numerical(), "The column has to be numerical in order for a max value to exist")
	local data = self.data
	if (self:count_na() > 0) then
		data = data:maskedSelect(self:get_data_mask{ missing = false })
	end

	return torch.max(data)
end}

Dataseries.get_min_value = argcheck{
	doc=[[
<a name="Dataseries.get_min_value">
### Dataseries.get_min_value(@ARGP)

Gets the minimum value for a given column. Returns minimum values for all
numerical columns if none is provided.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataseries"},
	call=function(self)

	if (self:is_categorical()) then
		local min = 0/0

		for k,i in pairs(self:get_cat_keys()) do
			if (isnan(min)) then
				min = i
			elseif (i < min) then
				min = i
			end
		end

		return min
	end

	assert(self:is_numerical(), "The column has to be numerical in order for a max value to exist")
	local data = self.data
	if (self:count_na() > 0) then
		data = data:maskedSelect(self:get_data_mask{ missing = false })
	end

	return torch.min(data)
end}
