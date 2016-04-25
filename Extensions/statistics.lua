require 'dok'
local params = {...}
local Dataframe = params[1]

-- ARGS: - see dok.unpack
function Dataframe:value_counts(...)
	local args = dok.unpack(
		{...},
		'Dataframe.value_counts',
		[[
		Counts number of occurences for each unique element (frequency/histogram) in
		a single column or set of columns. If a single column is requested then it returns
		a simple table with element names as keys and counts/proportions as values.
		If multiple keys have been requested it returns a table wrapping the single
		column counts with column name as key.
		]],
		{arg='column_name', type='string', help='column to inspect'},
		{arg='normalize', type='boolean', default=false,
		 help=[[
		 	If True then the object returned will contain the relative frequencies of
			the unique values.]]},
		{arg='dropna', type='boolean', default=true,
		 help="Don’t include counts of NaN (missing values)."}
	)
	local single = false
	if (not args.column_name) then
		args.column_name = self:get_numerical_colnames()
		if (#args.column_name == 1) then
			single = true
		end
	elseif(type(args.column_name) == 'string') then
		args.column_name = {args.column_name}
		single = true
	end
	value_counts = {}
	for _,cn in pairs(args.column_name) do
		value_counts[cn] = self:_single_col_value_counts{
			column_name = cn,
			normalize = args.normalize,
			dropna = args.dropna
		}
	end
	if (single) then
		return value_counts[args.column_name[1]]
	else
		return value_counts
	end
end

function Dataframe:_single_col_value_counts(...)
	local args = dok.unpack(
		{...},
		'Dataframe._single_col_value_counts',
		'get value counts of elements given a column name',
		{arg='column_name', type='string', help='column to inspect', req=true},
		{arg='normalize', type='boolean', default=false,
		 help=[[
			If True then the object returned will contain the relative frequencies of
			the unique values.]]},
		{arg='dropna', type='boolean', default=true,
		 help="Don’t include counts of NaN (missing values)."}
	)
	assert(self:has_column(args.column_name),
				 "Invalid column name: " .. tostring(args.column_name))
	count = {}

	-- Experiencing odd behavior with large data > 254459 rows
	--  better to use raw data and then convert the names at the end
	column_data = self:get_column{column_name = args.column_name,
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
	if (self:is_categorical(args.column_name)) then
		tmp = {}
		for key,no_found in pairs(count) do
			name = self:to_categorical(key, args.column_name)
			tmp[name] = no_found
		end
		count = tmp
	end
	if (not args.dropna) then
		count["_missing_"] = no_missing
	end
	if (args.normalize) then
		total = 0
		for _,n in pairs(count) do
			total = total + n
		end
		for i,n in pairs(count) do
			count[i] = n/total
		end
	end
	return count
end
--
-- see dok.unpack
--
function Dataframe:get_mode(...)
	local args = dok.unpack(
		{...},
		'Dataframe.get_mode',
		[[gets the most occurring value in a certain column, i.e. the mode.
		If no column is provided retrieves all numerical columns in a named table.]],
		{arg='column_name', type='string', help='column to inspect'},
		{arg='normalize', type='boolean', default=false,
		 help=[[
		 	If True then the object returned will contain the relative frequencies of
			the mode.]]},
		{arg='dropna', type='boolean', default=true,
		 help="Don’t include counts of NaN (missing values)."}
	)
	local single = false
	if (not args.column_name) then
		args.column_name = self:get_numerical_colnames()
		if (#args.column_name == 1) then
			single = true
		end
	elseif(type(args.column_name) == 'string') then
		args.column_name = {args.column_name}
		single = true
	end
	modes = {}
	for i = 1,#args.column_name do
		local cn = args.column_name[i]
		local counts = self:_single_col_value_counts{column_name = cn,
								                                 normalize = args.normalize,
																								 dropna = args.dropna}
		local max_val = 0/0
		for _,v in pairs(counts) do
			if (isnan(max_val) or max_val < v) then
				max_val  = v
			end
		end
		modes[cn] = {}
		for key,v in pairs(counts) do
			if (max_val == v) then
				modes[cn][key] = v
			end
		end
	end
	if single then
		return modes[args.column_name[1]]
	else
		return modes
	end
end

--
-- get_max_value(...) : see dok.unpack for details
---
function Dataframe:get_max_value(...)
	local args = dok.unpack(
		{...},
		'Dataframe.get_max_value',
		[[
		Gets the maximum value for a given column. Returns maximum values for all
		numerical columns if none is provided. Keeps the order although not if
		with_named_keys == true as the keys will be sorted in alphabetic order.
	  ]],
		{arg='column_name', type='string', help='the name of the column'},
		{arg='with_named_keys', type='boolean', help='if the index should be named keys', default=false}
	)
  local single = false
	if (args.column_name == nil) then
		args.column_name = self:get_numerical_colnames()
	elseif (type(args.column_name) == 'string') then
    single = true
		args.column_name = {args.column_name}
	else
		error("Invalid column_name argument: " .. tostring(args.column_name))
	end

	for _,k in pairs(args.column_name) do
		assert(self:has_column(k), "Could not find column: " .. tostring(k))
	end
	ret = {}
	for col_no = 1,#self.column_order do
		local cn = self.column_order[col_no]
		local found = false
		for _,k in pairs(args.column_name) do
			if (k == cn) then
				found = true
				break
			end
		end
		if (found) then
			local max = 0/0
			if (self:is_categorical(cn)) then
				for k,i in pairs(self:get_cat_keys(cn)) do
          if (isnan(max)) then
            max = i
          elseif (i > max) then
						max = i
					end
				end
			elseif (self:is_numerical(cn)) then
				for _,v in pairs(self:get_column{column_name = cn, as_raw = true}) do
          if (isnan(max)) then
            max = v
					elseif (v > max) then
						max = v
					end
				end
			end
			if (args.with_named_keys and not single) then
				ret[cn] = max
			else
				table.insert(ret, max)
			end
		end
	end
  if (single) then
    return ret[1]
  else
    return ret
  end
end

--
-- get_min_value(...) : see dok.unpack for details
---
function Dataframe:get_min_value(...)
	local args = dok.unpack(
		{...},
		'Dataframe.get_min_value',
		[[
		Gets the minimum value for a given column. Returns maximum minimum for all
		numerical columns if none is provided. Keeps the order although not if
		with_named_keys == true as the keys will be sorted in alphabetic order.
	  ]],
		{arg='column_name', type='string', help='the name of the column'},
		{arg='with_named_keys', type='boolean', help='if the index should be named keys', default=false}
	)
  local single = false
	if (args.column_name == nil) then
		args.column_name = self:get_numerical_colnames()
	elseif (type(args.column_name) == 'string') then
    single = true
		args.column_name = {args.column_name}
	else
		error("Invalid column_name argument: " .. tostring(args.column_name))
	end

	for _,k in pairs(args.column_name) do
		assert(self:has_column(k), "Could not find column: " .. tostring(k))
	end
	ret = {}
	for col_no = 1,#self.column_order do
		local cn = self.column_order[col_no]
		local found = false
		for _,k in pairs(args.column_name) do
			if (k == cn) then
				found = true
				break
			end
		end
		if (found) then
			local min = 0/0
			if (self:is_categorical(cn)) then
				for k,i in pairs(self:get_cat_keys(cn)) do
          if (isnan(min)) then
            min = i
					elseif (i < min) then
						min = i
					end
				end
			elseif (self:is_numerical(cn)) then
				for _,v in pairs(self:get_column{column_name = cn, as_raw = true}) do
          if (isnan(min)) then
            min = v
					elseif (v < min) then
						min = v
					end
				end
			end
			if (args.with_named_keys and not single) then
				ret[cn] = min
			else
				table.insert(ret, min)
			end
		end
	end
  if (single) then
    return ret[1]
  else
    return ret
  end
end
