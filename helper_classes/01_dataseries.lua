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
	assert(isint(index) and index > 0 and index <= self:size() + 1,
	      "The index has to be a positive integer within a valid range")

	if (self.missing[index]) then
		 return 0/0
	else
		return self.data[index]
	end
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
	local ret = Dataseries.new(#index, self:type())
	for ret_idx,org_idx in ipairs(index) do
		ret:set(ret_idx, self:get(org_idx))
	end
	return ret
end}

Dataseries.get = argcheck{
	doc=[[
@ARGT

_Return value_:  Dataseries
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
	assert(start > 0 and start <= self:size(),
	       "Start has to be a positive integer less or equal to the lenght of the series")

	stop = index:gsub("[^:]*:", "")
	stop = tonumber(stop)
	if (stop == nil) then
		stop = self:size()
	end
	assert(stop > 0 and stop <= self:size(),
	       "Stop has to be a positive integer less or equal to the lenght of the series")
	assert(start <= stop, "Start should not be larger than the stop")

	local ret = Dataseries.new(stop - start + 1, self:type())
	for idx = start,stop do
		ret:set(idx + 1 - start, self:get(idx))
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
	assert(isint(index) and index > 0 and index <= self:size() + 1,
	      "The index has to be a positive integer within a valid range")
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
	if (self:isTensor()) then
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

Dataseries.isTensor = argcheck{
	{name="self", type="Dataseries"},
	call=function(self)
	if (torch.type(self.data):match(("torch.*Tensor"))) then
		return true
	else
		return false
	end
end}

Dataseries.type = argcheck{
	{name="self", type="Dataseries"},
	call=function(self)
	return torch.typename(self.data)
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

-- Metatable functions
doc =  [[
<a name="Dataseries.[]">
### Dataseries.[]

The `__index__` function is a powerful tool that allows quick access to regular functions

- _Single integer_: it returns the raw elemet table (see `get()`)
- _Df_Array()_: select a set of interest (see `_create_subset()`)
- _"start:stop"_: get a row span using start/stop index, e.g. `"2:5"` (see `sub()`)
- _"$column_name"_: get a column by prepending the name with `$`, e.g. `"$a column name"` (see `get_column`)
- _"/subset_name"_: get a subset by prepending the name with `/`, e.g. `"/a subset name"` (see `get_subset`)

_Return value_: Table or Dataseries
]]

function Dataseries:__index__(index)
	local thtype = torch.type(index)
	if (thtype == "number" or
	   (thtype == "Df_Array") or
	   (thtype == "string" and index:match("^[0-9]*:[0-9]*$"))) then
		return self:get(index), true
	end

	return false
end


doc =  [[
<a name="Dataseries.[] =">
### Dataseries.[] =

The `__newindex__` allows updating of a single element (uses `set()`)

]]
function Dataseries:__newindex__(index, value)
	if (torch.type(index) == "number") then
		self:set(index, value)
		return true
	end

	return false
end

Dataseries.__len__ = argcheck{
	doc =  [[
<a name="Dataseries.#">
### Dataseries.#

Returns the number of elements

_Return value_: integer
]],
	{name="self", type="Dataseries"},
	{name="other", type="Dataseries", opt=true},
	call=function(self, other)
	return self:size()
end}
