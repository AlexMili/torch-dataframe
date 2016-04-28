require 'dok'
local params = {...}
local Dataframe = params[1]

--
-- as_categorical('column_name') : set a column to categorical
--
-- ARGS: - column_name 		(required) 	[string|table] 	: column to set to categorical
--
-- RETURNS: nothing
function Dataframe:as_categorical(column_name)
	if (type(column_name) ~= 'table') then
		column_name = {column_name}
	end
	for _,cn in pairs(column_name) do
		assert(self:has_column(cn), "Could not find column: " .. cn)
		assert(not self:is_categorical(cn), "Column already categorical")
		keys = self:unique{column_name = cn,
											 as_keys = true,
											 trim_values = true}
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

--
-- add_cat_key('column_name', 'key') ; adds a key to the keyset of a categorical column
--
-- ARGS: -column_name (required) [string] : the column name
--       -key         (required) [string|number] : the new key
--
-- RETURNS: new index value for key
function Dataframe:add_cat_key(column_name, key)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	assert(self:is_categorical(column_name), "The column isn't categorical: " .. tostring(column_name))
	assert(not isnan(key), "You can't add a nan key to "  .. tostring(column_name))
	assert(type(key) == "number" or
	       type(key) == "string",
				 "Keys can only be strings or numbers, you have provided: " .. tostring(key) .. " of type: " .. type(key))
	keys = self:get_cat_keys(column_name)
	key_index = table.exact_length(keys) + 1
	keys[key] = key_index
	self.categorical[column_name] = keys
	return key_index
end

--
-- as_string('column_name') : converts a column to string, reverts the as_categorical
--
-- ARGS: - column_name 		(required) 	[string] 	: column to set to string
--
-- RETURNS: nothing
function Dataframe:as_string(column_name)
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
end

--
-- clean_categorical('column_name') : removes any categories no longer present from the keys
--
-- ARGS: see dok.unpack
--
-- RETURNS: void
function Dataframe:clean_categorical(...)
	local args = dok.unpack(
		{...},
		{"Dataframe.clean_categorical"},
		{"Removes categorical values no longer present in the column"},
		{arg='column_name', type='string', help='the name of the column', req=true},
		{arg='reset_keys', type='boolean', help='if all the keys should be reinitialized', default=false})
	assert(self:has_column(args.column_name), "Couldn't find column: " .. tostring(args.column_name))
	assert(self:is_categorical(args.column_name), tostring(args.column_name) .. " isn't categorical")
	if (args.reset_keys) then
		self:as_string(args.column_name)
		self:as_categorical(args.column_name)
	else
		keys = self:get_cat_keys(args.column_name)
		vals = self:get_column(args.column_name)
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
		self.categorical[args.column_name] = keys
	end
end

--
-- is_categorical('column_name') : check if a column is categorical
--
-- ARGS: - column_name 		(required) 	[string] 	: column to check
--
-- RETURNS: boolean
function Dataframe:is_categorical(column_name)
	assert(self:has_column(column_name), "This column doesn't exist")
	return self.categorical[column_name] ~= nil
end

--
-- get_cat_keys('column_name') : get keys for a column
--
-- ARGS: - column_name 		(required) 	[string] 	: column to check
--
-- RETURNS: table
function Dataframe:get_cat_keys(column_name)
	assert(self:has_column(column_name), "Could not find column: " .. tostring(column_name))
	assert(self:is_categorical(column_name), "The " .. tostring(column_name) .. " isn't a categorical column")
  return self.categorical[column_name]
end

--
-- to_categorical(...) : Converts values to categorical according to a column's keys
--
-- ARGS: - data   (required) [number|table|tensor] : The numerical data to convert
--       - column_name (required) [string]         : The column name which keys to use
--
-- RETURNS: string if single value entered or table if multiple values
function Dataframe:to_categorical(...)
	local args = dok.unpack(
		{...},
		'Dataframe.to_categorical',
		'Converts values to categorical according to a column\'s keys',
		{arg='data', type='number|string|table|tensor', help='The data to be converted', req=true},
		{arg='column_name', type='string', help='The name of the column', req=true})
	assert(self:has_column(args.column_name), "Invalid column name: " .. args.column_name)
	assert(self:is_categorical(args.column_name), "Column isn't categorical")
	local single_value = false
	if (torch.isTensor(args.data)) then
		assert(#args.data:size() == 1,
		       "The function currently only supports single dimensional tensors")
		local tmp = {}
		for i = 1,args.data:size()[1] do
			table.insert(tmp, args.data[i])
		end
		args.data = tmp
	elseif(type(args.data) ~= 'table') then
		if (not isnan(args.data)) then
			val = tonumber(args.data)
			assert(type(val) == 'number', "The data " .. args.data .. " is not a valid number")
			args.data = val
			assert(math.floor(args.data) == args.data, "The data is not a valid integer")
		end
		single_value = true
		args.data = {args.data}
	else
		for k,v in pairs(args.data) do
			if (not isnan(args.data[k])) then
				val = tonumber(args.data[k])
				assert(type(val) == 'number',
				       "The data ".. tostring(val) .." in position " .. k .. " is not a valid number")
				args.data[k] = val
				assert(math.floor(args.data[k]) == args.data[k],
				       "The data " .. args.data[k] .. " in position " .. k .. " is not a valid integer")
			end
		end
	end

	ret = {}
	for _,v in pairs(args.data) do
		local val = nil
		if (isnan(v)) then
			val = 0/0
		else
			for k,index in pairs(self.categorical[args.column_name]) do
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
	if (single_value) then
		return ret[1]
	else
		return ret
	end
end

--
-- from_categorical(...) : Converts categorical to numerical according to a column's keys
--
-- ARGS: - data   (required) [number|table|tensor] : The numerical data to convert
--       - column_name (required) [string]         : The column name which keys to use
--       - as_tensor (optional) [boolean]          : If the return value should be a tensor
--
-- RETURNS: table or tensor
function Dataframe:from_categorical(...)
	local args = dok.unpack(
		{...},
		'Dataframe.from_categorical',
		'Converts categorical to numerical according to a column\'s keys',
		{arg='data', type='number|string|table', help='The data to be converted', req=true},
		{arg='column_name', type='string', help='The name of the column', req=true},
	  {arg='as_tensor', type='boolean', help='If the returned value should be a tensor'})
	assert(self:has_column(args.column_name), "Can't find the column: " .. args.column_name)
	assert(self:is_categorical(args.column_name), "Column isn't categorical")
	if(type(args.data) ~= 'table') then
		args.data = {args.data}
	end

	ret = {}
	for _,v in pairs(args.data) do
		local val = self.categorical[args.column_name][v]
		if (val == nil) then
			val = 0/0
		end
		table.insert(ret, val)
	end
	if (args.as_tensor) then
		return torch.Tensor(ret)
	else
		return ret
	end
end
