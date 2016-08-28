local params = {...}
local Dataseries = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Single element functions

Here are functions are mainly used for manipulating a single element.

]]

Dataseries.get = argcheck{
	doc=[[
<a name="Dataseries.get">
### Dataseries.get(@ARGP)

Gets a single or a set of elements.

@ARGT

_Return value_: number|string|boolean
]],
	{name="self", type="Dataseries"},
	{name="index", type="number", doc="The index to set the value to"},
	{name="as_raw", type="boolean", default=false,
	 doc="Set to true if you want categorical values to be returned as their raw numeric representation"},
	call=function(self, index, as_raw)
	self:assert_is_index(index)

	local ret
	if (self.missing[index]) then
		ret = 0/0
	else
		ret = self.data[index]
	end

	-- Convert categorical values to strings unless directly asked not to
	if (not as_raw and self:is_categorical()) then
		ret = self:to_categorical(ret)
	end

	return ret
end}

Dataseries.get = argcheck{
	doc=[[
If you provde a Df_Array you get back a Dataseries of elements

@ARGT

_Return value_:  Dataseries
]],
	{name="self", type="Dataseries"},
	{name="index", type="Df_Array"},
	overload=Dataseries.get,
	call=function(self, index, as_raw)
	index = index.data

	local ret = Dataseries.new(#index, self:get_variable_type())
	for ret_idx,org_idx in ipairs(index) do
		ret:set(ret_idx, self:get(org_idx, true))
	end
	ret.categorical = self.categorical

	return ret
end}

Dataseries.set = argcheck{
	doc=[[
<a name="Dataseries.set">
### Dataseries.set(@ARGP)

Sets a single element

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="index", type="number", doc="The index to set the value to"},
	{name="value", type="*", doc="The data to set"},
	call=function(self, index, value)
	self:assert_is_index{index = index, plus_one = true}

	if (index == self:size() + 1) then
		return self:append(value)
	end

	if (isnan(value) or value == nil) then
		self.missing[index] = true
	else
		if (self:is_categorical()) then
			local new_value = self:from_categorical(value)
			if (isnan(new_value)) then
				value = self:add_cat_key(value)
			else
				value = new_value
			end
		end
		self.missing[index] = nil
		self.data[index] = value
	end

	return self
end}

Dataseries.append = argcheck{
	doc=[[
<a name="Dataseries.append">
### Dataseries.append(@ARGP)

Appends a single element to series. This function resizes the tensor to +1
and then calls the `set` function so if possible try to directly size the
series to apropriate length before setting elements as this alternative is
slow and should only be used with a few values at the time.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="value", type="*", doc="The data to set"},
	call=function(self, value)
	local new_size = self:size() + 1
	self:resize(new_size)
	return self:set(new_size, value)
end}

Dataseries.remove = argcheck{
	doc=[[
<a name="Dataseries.remove">
### Dataseries.remove(@ARGP)

Removes a single element

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="index", type="number", doc="The index to remove"},
	call=function(self, index)
	self:assert_is_index(index)

	-- Update missing positions
	self.missing[index] = nil
	for i=(index + 1),self:size() do
		if (self.missing[i]) then
			self.missing[i - 1] = true
			self.missing[i] = nil
		end
	end

	if (self:type():match("^tds.Vec")) then
		self.data:remove(index)
	else
		if (self:size() == 1) then
			self.data:resize(0)
		elseif (index == self:size()) then
			self.data = self.data[{{1,index - 1}}]
		elseif (index == 1) then
			self.data = self.data[{{index + 1, self:size()}}]
		else
			self.data = torch.cat(
				self.data[{{1,index - 1}}],
				self.data[{{index + 1, self:size()}}],
				1)
		end
	end


	return self
end}

Dataseries.insert = argcheck{
	doc=[[
<a name="Dataseries.insert">
### Dataseries.insert(@ARGP)

Inserts a single element

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="index", type="number", doc="The index to insert at"},
	{name="value", type="!table", doc="The value to insert"},
	call=function(self, index, value)
	self:assert_is_index{index = index, plus_one = true}
	if (index > self:size()) then
		return self:append(value)
	end

	-- Shift the missing one step to the right
	for i=0,(self:size() - index) do
		local pos = self:size() - i
		if (self.missing[pos]) then
			self.missing[pos + 1] = true
			self.missing[pos] = nil
		end
	end

	-- Insert an element that we later on can set with the value
	if (self:type():match("^tds.Vec")) then
		self.data:insert(index, 0)
	else
		sngl_elmnt = torch.Tensor(1):type(self:type()):fill(-1)

		if (index == 1) then
			self.data = torch.cat(sngl_elmnt, self.data, 1)
		else
			local tmp = torch.cat(
				self.data[{{1,index-1}}],
				sngl_elmnt,
				1)

			self.data = torch.cat(
				tmp,
				self.data[{{index, self:size()}}],
				1)
		end
	end

	self:set(index, value)

	return self
end}
