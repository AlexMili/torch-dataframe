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
<a name="Dataseries.set">
### Dataseries.set(@ARGP)

Gets a single element

@ARGT

_Return value_:  number|string|boolean
]],
	{name="self", type="Dataseries"},
	{name="index", type="string"},
	overload=Dataseries.get,
	call=function(self, index)
	assert(index:match("^[0-9]*:[0-9]*$"),
	       "Index must be in the form of start:stop where start and stop are integers")
	start = index:gsub(":.*", "")
	start = tonumber(start)
	if (start == nil) then
		start = 1
	end
	self:assert_is_index(start)

	stop = index:gsub("[^:]*:", "")
	stop = tonumber(stop)
	if (stop == nil) then
		stop = self:size()
	end
	self:assert_is_index(stop)

	assert(start <= stop, "Start should not be larger than the stop")

	local ret = Dataseries.new(stop - start + 1, self:get_variable_type())
	for idx = start,stop do
		ret:set(idx + 1 - start, self:get(idx))
	end

	return ret
end}

Dataseries.get = argcheck{
	doc=[[
@ARGT

_Return value_:  Dataseries
]],
	{name="self", type="Dataseries"},
	{name="index", type="Df_Array"},
	overload=Dataseries.get,
	call=function(self, index)
	index = index.data
	local ret = Dataseries.new(#index, self:get_variable_type())
	for ret_idx,org_idx in ipairs(index) do
		ret:set(ret_idx, self:get(org_idx))
	end
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
		if (index == self:size()) then
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
	for i=0,(self:size() - index + 1) do
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
