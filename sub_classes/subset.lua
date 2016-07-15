local params = {...}
local Dataframe = params[1]
local current_file_path = params[2] -- used for loading extensions at the end

require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Df_Subset class

The subset class contains all the information for a specific subset of an
associated Dataframe. It is generally owned by a dataframe and simply initiates
values/functions associated with subsetting, e.g. samplers, which indexes are
in a particular subset.

]]

-- create class object
local subset = torch.class('Df_Subset', 'Dataframe')

subset.__init = argcheck{
	doc =  [[
<a name="Df_Subset.__init">
### Df_Subset.__init(@ARGP)

Creates and initializes a Df_Subset class.

@ARGT

]],
	{name="self", type="Df_Subset"},
	{name="indexes", type="Df_Array", doc="The indexes in the original dataset to use for sampling"},
	{name="sampler", type="string", doc="The sampler to use with this data"},
	{name="parent", type="Dataframe", doc="The parent Dataframe that will be stored by reference"},
	call=function(self, indexes, sampler, parent)
	Dataframe.__init(self)
	self:
		_clean():
		set_idxs(indexes):
		set_sampler(sampler)

	self.parent = parent
end}

subset.__init = argcheck{
doc =  [[
Some of the samplers require a label column to which the samples will be balanced.
The label-distribution furthermore also requires a distribution,
e.g. `{train = {distribution = Df_Dict({A = 2, B=10})}}`

@ARGT

]],
	overload=subset.__init,
	{name="self", type="Df_Subset"},
	{name="indexes", type="Df_Array", doc="The indexes in the original dataset to use for sampling"},
	{name="sampler", type="string", doc="The sampler to use with this data"},
	{name="labels", type="Df_Array",
	 doc="The column with all the labels (note this is passed by reference)"},
	{name="sampler_args", type="Df_Dict",
	 doc=[[Optional arguments for the sampler function, currently only used for
	 the label-distribution sampler.]],
	 default=false},
	{name="parent", type="Dataframe", doc="The parent Dataframe that will be stored by reference"},
	call=function(self, indexes, sampler, labels, sampler_args, parent)
	Dataframe.__init(self)

	self:
		_clean():
		set_idxs(indexes):
		set_labels(labels)
	if (sampler_args) then
			self:set_sampler(sampler, sampler_args)
	else
		self:set_sampler(sampler)
	end

	self.parent = parent
end}

subset._clean = argcheck{
doc =  [[
<a name="Df_Subset._clean">
### Df_Subset._clean(@ARGP)

Reset the internal data

@ARGT

_Return value_: self
]],
{name="self", type="Df_Subset"},
call=function(self)
	Dataframe._clean(self)

	self.indexes = {}
	self.sampler = nil
	self.reset = nil
	self.labels = nil

	return self
end}

subset.set_idxs = argcheck{
	doc =  [[
<a name="Df_Subset.set_idxs">
### Df_Subset.set_idxs(@ARGP)

Set the indexes

@ARGT

_Return value_: self
]],
	{name="self", type="Df_Subset"},
	{name="indexes", type="Df_Array", doc="The indexes in the original dataset to use for sampling"},
	call=function(self, indexes)
	for i=1,#indexes.data do
		local idx = indexes.data[i]
		assert(isint(idx) and idx > 0,
		       "The index must be a positive integer, you've provided " .. tostring(idx))
	end

	-- Remove previous column if it exists
	if (self:has_column('indexes')) then
		assert(#indexes.data == self:size(1),
		       ("The rows of the new (%d) and old data (%d) don't match"):
		       format(#indexes.data, self:size(1)))
		self:drop('indexes')
	end

	self:add_column('indexes', indexes)

	return self
end}


subset.get_idx = argcheck{
	doc =  [[
<a name="Df_Subset.get_idx">
### Df_Subset.get_idx(@ARGP)

Get the index fromm the parent Dataframe that a local index corresponds to

@ARGT

_Return value_: integer
]],
	{name="self", type="Df_Subset"},
	{name="index", type="number", doc="The subset's index that you want the original index for"},
	call=function(self, index)
	self:assert_is_index(index)

	return self:get_column('indexes')[index]
end}

subset.set_labels = argcheck{
	doc =  [[
<a name="Df_Subset.set_labels">
### Df_Subset.set_labels(@ARGP)

Set the labels needed for certain samplers

@ARGT

_Return value_: self
]],
	{name="self", type="Df_Subset"},
	{name="labels", type="Df_Array",
	 doc="The column with all the labels (note this is passed by reference)"},
	call=function(self, labels)

	-- Remove previous column if it exists
	if (self:has_column('labels')) then
		assert(#labels.data == self:size(1),
		       ("The rows of the new (%d) and old data (%d) don't match"):
		       format(#labels.data, self:size(1)))
		self:drop('labels')
	end

	self:add_column('labels', labels)

	return self
end}

subset.set_sampler = argcheck{
	doc =  [[
<a name="Df_Subset.set_sampler">
### Df_Subset.set_sampler(@ARGP)

Set the sampler function that is associated with this subset

@ARGT

_Return value_: self
]],
	{name="self", type="Df_Subset"},
	{name="sampler", type="string", doc="The indexes in the original dataset to use for sampling"},
	{name="sampler_args", type="Df_Dict",
	 doc=[[Optional arguments for the sampler function, currently only used for
	 the label-distribution sampler.]],
	 default=false},
	call=function(self, sampler, sampler_args)
	if (sampler_args) then
		self.sampler, self.reset = self:get_sampler(sampler, sampler_args)
	else
		self.sampler, self.reset = self:get_sampler(sampler)
	end
	return self
end}

-- Load the extensions
local ext_path = string.gsub(current_file_path, "[^/]+$", "") .. "subset_extensions/"
for extension_file,_ in lfs.dir (ext_path) do
  if (string.match(extension_file, "[.]lua$")) then
    local file = ext_path .. extension_file
    assert(loadfile(file))(subset)
  end
end

subset.get_batch = argcheck{
	doc =  [[
<a name="Df_Subset.get_batch">
### Df_Subset.get_batch(@ARGP)

Retrieves a batch of given size using the set sampler. If sampler needs resetting
then the batch will be either smaller than the requested number or nil.

@ARGT

_Return value_: Batchframe, boolean (if reset_sampler() should be called)
]],
	{name="self", type="Df_Subset"},
	{name='no_lines', type='number', doc='The number of lines/rows to include (-1 for all)'},
	call=function(self, no_lines)

	assert(isint(no_lines) and
				 (no_lines > 0 or
					no_lines == -1) and
					no_lines <= self:size(1),
				 "The number of files to load has to be either -1 for all files or " ..
				 " a positive integer less or equeal to the number of observations in that category " ..
				 self:size(1) .. "." ..
				 " You provided " .. tostring(no_lines))

	local reset = false
	if (no_lines == -1) then
		no_lines = self:size(1)
		reset = true -- The sampler only triggers the reset after passing > 1 epoch
	end

	local indexes = {}
	for i=1,no_lines do
		local idx = self.sampler()
		if (idx == nil) then
			reset = true
			break
		end
		table.insert(indexes, idx)
	end

	if (#indexes == nil) then
		return nil, reset
	end

	return self.parent:_create_subset{index_items = Df_Array(indexes),
	                                  frame_type = "Batchframe"}, reset
end}

subset.reset_sampler = argcheck{
	doc =  [[
<a name="Df_Subset.reset_sampler">
### Df_Subset.reset_sampler(@ARGP)

Resets the sampler. This is needed for a few samplers and is easily checked for
in the 2nd return value from `get_batch`

@ARGT

_Return value_: self
]],
	{name="self", type="Df_Subset"},
	call=function(self)
	self.reset()
	return self
end}

return subset
