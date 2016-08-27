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
	call=function(self)
	local ret = Dataseries.new(#self, self:get_variable_type())
	for i=1,#self do
		ret:set(i, self:get(i))
	end

	return ret
end}

Dataseries.get = argcheck{
	doc=[[
<a name="Dataseries.get">
### Dataseries.get(@ARGP)

Gets a single or a set of elements. If you provde a string
`start:stop` then the span between start and stop will be
selected including the start and stop element.

@ARGT

_Return value_: number
]],
	{name="self", type="Dataseries"},
	{name="index", type="number", doc="The index to set the value to"},
	call=function(self, index)
	self:assert_is_index(index)

	if (self.missing[index]) then
		 return 0/0
	else
		return self.data[index]
	end
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

_Return value_: self
]],
	{name="self", type="Dataseries"},
	{name="false_value", type="number",
	 doc="The numeric value for false"},
	{name="true_value", type="number",
	 doc="The numeric value for true"},
	call=function(self, false_value, true_value)
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

	return self
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
	ret = ("Type: %s\nLength: %d\n-----"):format(self:type(), self:size())
	for i=1,max_elmnts do
		ret = ret .. "\n" .. self:get(i)
	end
	if (max_elmnts < self:size()) then
		ret = ret .. "\n..."
	end

	ret = ret .. "\n-----\n"
	return ret
end}

local paths = require 'paths'
local dataseries_path = paths.thisfile():gsub("init.lua$", "?.lua")

-- Load all extensions, i.e. .lua files in extensions directory
ext_path = string.gsub(dataseries_path, "[^/]+$", "") .. "dataseries_ext/"
local ext_files = paths.get_sorted_files(ext_path)
for _, extension_file in pairs(ext_files) do
  local file = ext_path .. extension_file
  assert(loadfile(file))(Dataseries)
end
