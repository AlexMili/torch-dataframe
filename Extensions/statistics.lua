require 'dok'
local params = {...}
local Dataframe = params[1]

--
-- value_counts() : count number of occurences for each unique element (frequency/histogram)
--
-- ARGS: - see dok.unpack
--
-- RETURNS : table with the unique value as key and count as value
--
function Dataframe:value_counts(...)
	local args = dok.unpack(
		{...},
		'Dataframe.value_counts',
		'get value counts of elements given a column name',
		{arg='column_name', type='string', help='column to inspect', req=true}
	)
	assert(self:has_column(args.column_name),
	       "Invalid column name: " .. tostring(args.column_name))
	count = {}

	column_data = self:get_column(args.column_name)
	for i = 1,self.n_rows do
		current_key_value = column_data[i]
    if (not isnan(current_key_value)) then
      assert(current_key_value ~= nil, "invalid data for row " .. i)
			if (count[current_key_value] == nil) then
				count[current_key_value] = 1
			else
				count[current_key_value] = count[current_key_value] + 1
			end
		end
	end

  return count
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
