-- Main Dataseries file
require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

-- Since torchnet also uses docs we need to escape them when recording the documentation
local torchnet
if (doc.__record) then
	doc.stop()
	torchnet = require "torchnet"
	doc.record()
else
	torchnet = require "torchnet"
end

doc[[
## Dataseries

The Dataseries is an array of data with an additional layer
of missing data info. The class contains two main elements:

* A data container
* A hash with the missing data positions

The missing data are presented as `nan` values. A `nan` has the
behavior that `nan ~= nan` evaluates to `true`. There is a helper
function in the package, `isnan()`, that can be used to identify
`nan` values.

The class has the following metatable functions available:

* `__index__`: You can access any element by `[]`
* `__newindex__`: You can set the value of an element via `[]`
* `__len__`: The `#` returns the length of the series


]]

-- create class object
local Dataseries, parent_class = torch.class('Dataseries', 'tnt.Dataset')

Dataseries.__init = argcheck{
	doc =  [[
<a name="Dataseries.__init">
### Dataseries.__init(@ARGP)

Creates and initializes a Dataseries class. Envoked through `local my_series = Dataseries()`.
The type can be:
- boolean
- integer
- double
- string
- torch tensor or tds.Vec

@ARGT

]],
	{name="self", type="Dataseries"},
	{name="size", type="number", doc="The size of the new series"},
	{name="type", type="string", doc="The type of data storage to init.", opt=true},
	call=function(self, size, type)
	assert(isint(size) and size >= 0, "Size has to be a positive integer")
	parent_class.__init(self)
	if (type == "integer") then
		self.data = torch.IntTensor(size)
	elseif (type == "long") then
		self.data = torch.LongTensor(size)
	elseif (type == "double") then
		self.data = torch.DoubleTensor(size)
	elseif (type == "boolean" or
	        type == "string" or
	        type == "tds.Vec" or
	        type == nil) then
		self.data = tds.Vec()
		self.data:resize(size)
	elseif (type:match("torch.*Tensor")) then
		self.data = torch.Tensor(size):type(type)
	else
		assert(false, ("The type '%s' has not yet been implemented"):format(type))
	end
	self.missing = tds.Hash()
	self._variable_type = type
end}

Dataseries.__init = argcheck{
	doc =  [[

@ARGT

]],
	{name="self", type="Dataseries"},
	{name="data", type="torch.*Tensor|tds.Vec"},
	overload=Dataseries.__init,
	call=function(self, data)
	local size
	local thname = torch.type(data)
	if (thname:match("^tds")) then
		size = #data
	else
		size = data:size(1)
	end

	-- Create the basic datastructures
	self:__init(size, thname)

	-- Copy values
	for i=1,size do
		self:set(i, data[i])
	end
end}

Dataseries.__init = argcheck{
	{name="self", type="Dataseries"},
	{name="data", type="Df_Array"},
	{name="max_elmnts4type", type="number",
	 doc="The maximum number of elements to traverse before settling a type",
	 default=1e3},
	overload=Dataseries.__init,
	call=function(self, data, max_elmnts4type)
	data = data.data
	max_elmnts4type = math.min(#data, max_elmnts4type)
	local type = nil
	for i=1,max_elmnts4type do
		type = get_variable_type{value = data[i], prev_type = type}
	end

	-- Create the basic datastructures
	self:__init(#data, type)

	-- Copy values
	for i=1,#data do
		self:set(i, data[i])
	end
end}

Dataseries.copy = argcheck{
	doc=[[
<a name="Dataseries.copy">
### Dataseries.copy(@ARGP)

Creates a new Dataseries and with a copy/clone of the current data

@ARGT

_Return value_: Dataseries
]],
	{name="self", type="Dataseries"},
	{name="type", type="string", opt=true,
	 doc="Specify type if you  want other type than the current"},
	call=function(self, type)
	type = type or self:get_variable_type()
	local ret = Dataseries.new(#self, type)
	for i=1,#self do
		ret:set(i, self:get(i))
	end

	return ret
end}

-- Function that copies another dataset into the current together with all the
--  metadata
Dataseries._replace_data = argcheck{
	{name="self", type="Dataseries"},
	{name="new_data", type="Dataseries"},
	call=function(self, new_data)
	assert(self:size() == new_data:size(), "Can't replace when of different size")

	for k,val in pairs(new_data) do
		self[k] = val
	end

	return self
end}

Dataseries.size = argcheck{
	doc=[[
<a name="Dataseries.size">
### Dataseries.size(@ARGP)

Returns the number of elements in the Dataseries

@ARGT

_Return value_: number
]],
	{name="self", type="Dataseries"},
	call=function(self)
	if (self:is_tensor()) then
		if (self.data:size():size() == 0) then
			return 0
		end
		return self.data:size(1)
	else
		return #self.data
	end
end}

Dataseries.resize = argcheck{
	doc=[[
<a name="Dataseries.resize">
### Dataseries.resize(@ARGP)

Resizes the underlying storage to the new size. If the size is shrunk
then it also clears any missing values in the hash. If the size is increased
the new values are automatically set to missing.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="new_size", type="number", doc="The new size for the series"},
	call=function(self, new_size)
	local current_size = self:size()
	if (current_size < new_size) then
		self.data:resize(new_size)
		for i = (current_size + 1), new_size do
			self.missing[i] = true
		end
	elseif(current_size > new_size) then
		self.data:resize(new_size)
		for i = (new_size + 1),current_size do
			self.missing[i] = nil
		end
	end

	return self
end}

Dataseries.assert_is_index = argcheck{
	doc=[[
<a name="Dataseries.assert_is_index">
### Dataseries.assert_is_index(@ARGP)

Assertion that checks if index is an integer and within the span of the series

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="index", type="number", doc="The index to check"},
	{name = "plus_one", type = "boolean", default = false,
	 doc= "When adding rows, an index of size(1) + 1 is OK"},
	 call = function(self, index, plus_one)
 	if (plus_one) then
 		if (not isint(index) or
 				index < 0 or
 				index > self:size() + 1) then
 				assert(false, ("The index has to be an integer between 1 and %d - you've provided %s"):
 					format(self:size() + 1, index))
 		end
 	else
 		if (not isint(index) or
 				index < 0 or
 				index > self:size()) then
 				assert(false, ("The index has to be an integer between 1 and %d - you've provided %s"):
 					format(self:size(), index))
 		end
 	end

	return self
end}

Dataseries.is_tensor = argcheck{
	{name="self", type="Dataseries"},
	call=function(self)
	if (torch.type(self.data):match(("torch.*Tensor"))) then
		return true
	else
		return false
	end
end}

Dataseries.is_numerical = argcheck{
	doc = [[
<a name="Dataseries.is_numerical">
### Dataseries.is_numerical(@ARGP)

Checks if numerical

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataseries"},
	call=function(self)

	return self:get_variable_type() == "integer" or
		self:get_variable_type() == "long" or
		self:get_variable_type() == "double"
end}

Dataseries.is_boolean = argcheck{
	doc = [[
<a name="Dataseries.is_boolean">
### Dataseries.is_boolean(@ARGP)

Checks if boolean

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataseries"},
	call=function(self)

	return self:get_variable_type() == "boolean"
end}

Dataseries.is_string = argcheck{
	doc = [[
<a name="Dataseries.is_string">
### Dataseries.is_string(@ARGP)

Checks if boolean

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataseries"},
	call=function(self)

	return self:get_variable_type() == "string"
end}

Dataseries.type = argcheck{
	doc=[[
<a name="Dataseries.type">
### Dataseries.type(@ARGP)

Gets the torch.typename of the storage

@ARGT

_Return value_: string
]],
	{name="self", type="Dataseries"},
	call=function(self)
	return torch.typename(self.data)
end}

Dataseries.type = argcheck{
	doc=[[

You can also set the type by calling type with a type argument

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="type", type="string", doc="The type of column that you want to convert to"},
	overload=Dataseries.type,
	call=function(self, type)
	local new_data = self:copy(type)

	self:_replace_data(new_data)

	return self
end}

Dataseries.get_variable_type = argcheck{
	doc=[[
<a name="Dataseries.get_variable_type">
### Dataseries.get_variable_type(@ARGP)

Gets the variable type that was used to initiate the Dataseries

@ARGT

_Return value_: string
]],
	{name="self", type="Dataseries"},
	call=function(self)
	return self._variable_type
end}

Dataseries.boolean2tensor = argcheck{
	doc = [[
<a name="Dataseries.boolean2tensor">
### Dataseries.boolean2tensor(@ARGP)

Converts a boolean Dataseries into a torch.ByteTensor

@ARGT

_Return value_: self, boolean indicating successful conversion
]],
	{name="self", type="Dataseries"},
	{name="false_value", type="number",
	 doc="The numeric value for false"},
	{name="true_value", type="number",
	 doc="The numeric value for true"},
	call=function(self, false_value, true_value)
	if (not self:is_boolean()) then
		warning("The series isn't a boolean")
		return self, false
	end

	local data = torch.ByteTensor(self:size())
	for i=1,self:size() do
		local val = self:get(i)
		if (not isnan(val)) then
			if (val) then
				data[i] = true_value
			else
				data[i] = false_value
			end
		end
	end
	self.data = data
	self._variable_type = "integer"

	return self, true
end}

Dataseries.fill = argcheck{
	doc = [[
<a name="Dataseries.fill">
### Dataseries.fill(@ARGP)

Fills all values with a default value

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="default_value", type="number|string|boolean",
	 doc="The default value"},
	call=function(self, default_value)

	for i=1,self:size() do
		self:set(i, default_value)
	end

	return self
end}

Dataseries.fill_na = argcheck{
	doc = [[
<a name="Dataseries.fill_na">
### Dataseries.fill_na(@ARGP)

Replace missing values with a specific value

@ARGT

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="default_value", type="number|string|boolean",
	 doc="The default missing value", default=0},
	call=function(self, default_value)

	if (self:is_categorical() and
	    not self:has_cat_key("__nan__")) then
		assert(isint(default_value), "The default value has to be an integer")
		assert(not self:has_cat_value(default_value),
		       "The value " .. default_value .. " is already present in the Dataseries")
		self:add_cat_key("__nan__", default_value)
		default_value = "__nan__"
	end

	for pos,_ in pairs(self.missing) do
		self:set(pos, default_value)
	end

	return self
end}

Dataseries.tostring = argcheck{
	doc = [[
<a name="Dataseries.tostring">
### Dataseries.tostring(@ARGP)

Converts the series into a string output

@ARGT

_Return value_: string
]],
	{name="self", type="Dataseries"},
	{name="max_elmnts", type="number", default=20},
	call=function(self, max_elmnts)
	max_elmnts = math.min(self:size(), max_elmnts)
	ret = ("Type: %s (%s)\nLength: %d\n-----"):
		format(self:get_variable_type(), self:type(), self:size())
	for i=1,max_elmnts do
		ret = ret .. "\n" .. tostring(self:get(i))
	end
	if (max_elmnts < self:size()) then
		ret = ret .. "\n..."
	end

	ret = ret .. "\n-----\n"
	return ret
end}

Dataseries.sub = argcheck{
	doc = [[
<a name="Dataseries.sub">
### Dataseries.sub(@ARGP)

Subsets the Dataseries to the element span

@ARGT

_Return value_: Dataseries
]],
	{name="self", type="Dataseries"},
	{name="start", type="number", default=1},
	{name="stop", type="number", opt=true},
	call=function(self, start, stop)
	stop = stop or self:size()

	self:assert_is_index(start)
	self:assert_is_index(stop)
	assert(start <= stop,
	      ("Start larger than stop, i.e. %d > %d"):format(start, stop))

	local ret = Dataseries.new(stop - start + 1, self:get_variable_type())
	for idx = start,stop do
		ret:set(idx + 1 - start, self:get(idx))
	end

	return ret
end}

Dataseries.eq = argcheck{
	doc = [[
<a name="Dataseries.eq">
### Dataseries.eq(@ARGP)

Compares to Dataseries or table in order to see if they are identical

@ARGT

_Return value_: string
]],
	{name="self", type="Dataseries"},
	{name="other", type="Dataseries|table"},
	call=function(self, other)

	if (#self ~= #other) then
		return false
	end

	for i=1,self:size() do
		if (self:get(i) ~= other[i]) then
			return false
		end
	end

	return true
end}

return Dataseries
