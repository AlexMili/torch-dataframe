local params = {...}

require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"
local tnt
if (doc.__record) then
	doc.stop()
	tnt = require "torchnet"
	doc.record()
else
	v = require "torchnet"
end

doc[[

## Df_Subset

The subset class contains all the information for a specific subset of an
associated Dataframe. It is generally owned by a dataframe and simply initiates
values/functions associated with subsetting, e.g. samplers, which indexes are
in a particular subset.

]]

-- create class object
local subset, parent_class = torch.class('Df_Subset', 'Dataframe')

subset.__init = argcheck{
	doc =  [[
<a name="Df_Subset.__init">
### Df_Subset.__init(@ARGP)

Creates and initializes a Df_Subset class.

@ARGT

]],
	{name="self", type="Df_Subset"},
	{name="parent", type="Dataframe", doc="The parent Dataframe that will be stored by reference"},
	{name="indexes", type="Df_Array", doc="The indexes in the original dataset to use for sampling"},
	{name="sampler", type="string", opt=true,
	 doc="The sampler to use with this data"},
	{name="label_column", type="string", opt=true,
	 doc="The column with all the labels (a local copy will be generated)"},
	{name="sampler_args", type="Df_Dict", opt=true,
	 doc=[[Optional arguments for the sampler function, currently only used for
		the label-distribution sampler.]]},
	{name='batch_args', type='Df_Tbl', opt=true,
	 doc="Arguments to be passed to the Batchframe class initializer"},
	call=function(self, parent,
		indexes, sampler, label_column,
		sampler_args, batch_args)
	parent_class.__init(self)
	self:
		_clean():
		set_idxs(indexes)

	self.parent = parent

	if (label_column) then
		self:set_labels(label_column)
	end

	if (sampler) then
		if (sampler_args) then
			self:set_sampler(sampler, sampler_args)
		else
			self:set_sampler(sampler)
		end
	end

	if (batch_args) then
		self.batch_args = batch_args.data
	end
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
	parent_class._clean(self)

	self.indexes = {}
	self.sampler = nil
	self.reset = nil
	self.label_column = nil

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

	self:add_column('indexes', Dataseries(indexes))

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
	{name="label_column", type="string",
	 doc="The column with all the labels"},
	call=function(self, label_column)

	-- Remove previous column if it exists
	if (self:has_column('labels')) then
		self:drop('labels')
	end

	self.parent:assert_has_column(label_column)
	local label_column = self.parent:get_column(label_column)

	-- A little hacky but it should speed up and re-checking makes no sense
	local labels = Df_Array()
	local indexes = self:get_column("indexes")
	for i=1,self:size() do
		labels.data[#labels.data + 1] = label_column[indexes[i]]
	end

	-- TODO: an appealing alternative would be to store the label by ref. but this requires quite a few changes...
	-- Column does not have to be numerical for this to work
	self:add_column('labels', Dataseries(labels))

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
local ext_path = string.gsub(paths.thisfile(), "[^/]+$", "") .. "subset_extensions/"
load_dir_files(ext_path, {subset})

subset.get_batch = argcheck{
	doc =  [[
<a name="Df_Subset.get_batch">
### Df_Subset.get_batch(@ARGP)

Retrieves a batch of given size using the set sampler. If sampler needs resetting
then the second return statement will be `true`. Note that the last batch may be
smaller than the requested number when using samplers that require resetting. Once
you ave retrieved all available examples using one of the resetting samplers the
returned batch will be `nil`.

@ARGT

_Return value_: Batchframe, boolean (if reset_sampler() should be called)
]],
	{name="self", type="Df_Subset"},
	{name='no_lines', type='number', doc='The number of lines/rows to include (-1 for all)'},
	{name='class_args', type='Df_Tbl', opt=true,
		doc='Arguments to be passed to the class initializer'},
	call=function(self, no_lines, class_args)

	assert(isint(no_lines) and
	       (no_lines > 0 or
	      	no_lines == -1),
	       "The number of files to load has to be either -1 for all files or " ..
	       " a positive integer." ..
	       " You provided " .. tostring(no_lines))


	if (not class_args) then
		class_args = Df_Tbl(self.batch_args)
	end

	local reset = false
	if (no_lines == -1 or
	    no_lines > self:size(1)) then
		no_lines = self:size(1)
		reset = true -- The sampler only triggers the reset after passing > 1 epoch
	end

	local indexes = {}
	for i=1,no_lines do
		local idx
		idx, reset = self.sampler()

		if (idx == nil) then
			reset = true
			break
		end
		table.insert(indexes, idx)

		if (reset) then
			break;
		end
	end

	if (#indexes == 0) then
		return nil, reset
	end

	return self.parent:_create_subset{index_items = Df_Array(indexes),
	                                  frame_type = "Batchframe",
	                                  class_args = class_args}, reset
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

subset.get_iterator = argcheck{
	doc = [[
<a name="Df_Subset.get_iterator">
### Df_Subset.get_iterator(@ARGP)

**Important**: See the docs for Df_Iterator

@ARGT

_Return value_: `Df_Iterator`
	]],
	{name="self", type="Df_Subset"},
	{name="batch_size", type="number", doc="The size of the batches"},
	{name='filter', type='function', default=function(sample) return true end,
	 doc="See `tnt.DatasetIterator` definition"},
	{name='transform', type='function', default=function(sample) return sample end,
	 doc="See `tnt.DatasetIterator` definition. Runs immediately after the `get_batch` call"},
	{name='input_transform', type='function', default=function(val) return val end,
	 doc="Allows transforming the input (data) values after the `Batchframe:to_tensor` call"},
	{name='target_transform', type='function', default=function(val) return val end,
	 doc="Allows transforming the target (label) values after the `Batchframe:to_tensor` call"},
	call=function(self, batch_size, filter, transform, input_transform, target_transform)
	return Df_Iterator{
		dataset = self,
		batch_size = batch_size,
		filter = filter,
		transform = transform,
		input_transform = input_transform,
		target_transform = target_transform
	}
end}

subset.get_parallel_iterator = argcheck{
	doc = [[
<a name="Df_Subset.get_parallel_iterator">
### Df_Subset.get_parallel_iterator(@ARGP)

**Important**: See the docs for Df_Iterator and Df_ParallelIterator

@ARGT

_Return value_: `Df_ParallelIterator`
	]],
	{name="self", type="Df_Subset"},
	{name="batch_size", type="number", doc="The size of the batches"},
	{name='init', type='function', default=function(idx)
		-- Load the libraries needed
		require 'torch'
		require 'Dataframe'
	end,
	 doc=[[`init(threadid)` (where threadid=1..nthread) is a closure which may
	 initialize the specified thread as needed, if needed. It is loading
	 the libraries 'torch' and 'Dataframe' by default.]]},
	{name='nthread', type='number',
	 doc='The number of threads used to parallelize is specified by `nthread`.'},
	{name='filter', type='function', default=function(sample) return true end,
	 doc=[[is a closure which returns `true` if the given sample
	 should be considered or `false` if not. Note that filter is called _after_
	 fetching the data in a threaded manner and _before_ the `to_tensor` is called.]]},
	{name='transform', type='function', default=function(sample) return sample end,
	 doc='a function which maps the given sample to a new value. This transformation occurs before filtering.'},
	{name='input_transform', type='function', default=function(val) return val end,
	 doc="Allows transforming the input (data) values after the `Batchframe:to_tensor` call"},
	{name='target_transform', type='function', default=function(val) return val end,
	 doc="Allows transforming the target (label) values after the `Batchframe:to_tensor` call"},
	{name='ordered', type='boolean', opt=true,
	 doc=[[This option is particularly useful for repeatable experiments.
	 By default `ordered` is false, which means that order is not guaranteed by
	 `run()` (though often the ordering is similar in practice).]]},
	call =
	function(self, batch_size, init, nthread,
		       filter, transform, input_transform, target_transform, ordered)
	return Df_ParallelIterator{
		dataset = self,
		batch_size = batch_size,
		init = init,
		nthread = nthread,
		filter = filter,
		transform = transform,
		input_transform = input_transform,
		target_transform = target_transform,
		ordered = ordered
	}
end}

subset.__tostring__ = argcheck{
	doc=[[
	<a name="Df_Subset.__tostring__">
### Df_Subset.__tostring__(@ARGP)

@ARGT

_Return value_: string
]],
	{name="self", type="Dataframe"},
	call=function (self)
	return ("\nThis is a subset with %d rows and %d columns."):
		format(self:size(1), self:size(2)) ..
		"\n ------ \n" ..
		" the subset core data consists of: \n" ..
		parent_class.__tostring__(self)
end}


subset.set_data_retriever = argcheck{
	doc =  [[
<a name="Df_Subset.set_data_retriever">
### Df_Subset.set_data_retriever(@ARGP)

Sets the self.batch_args.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

@ARGT

_Return value_: self
]],
	{name="self", type="Df_Subset"},
	{name="data", type="function|Df_Array", opt=true,
	 doc="The data loading procedure/columns. If omitted the retriever will be erased"},
	call=function(self, data)


	if (not self.batch_args) then
		self.batch_args = {}
	end
	self.batch_args.data = data

	return self
end}

subset.set_label_retriever = argcheck{
	doc =  [[
<a name="Df_Subset.set_label_retriever">
### Df_Subset.set_label_retriever(@ARGP)

Sets the self.batch_args.data to either a function for loading data or
a set of columns that should be used in the to_tensor functions.

@ARGT

_Return value_: self
]],
	{name="self", type="Df_Subset"},
	{name="label", type="function|Df_Array", opt=true,
	 doc="The label loading procedure/columns. If omitted the retriever will be erased"},
	call=function(self, label)

	if (not self.batch_args) then
		self.batch_args = {}
	end
	self.batch_args.label = label

	return self
end}

subset.set_label_shape = argcheck{
	doc =  [[
<a name="Df_Subset.set_label_shape">
### Df_Subset.set_label_shape(@ARGP)

Sets the self.batch_args.label_shape for transforming the data into
requested format

@ARGT

_Return value_: self
]],
	{name="self", type="Df_Subset"},
	{name="label_shape", type="string", opt=true,
	 doc=[[The shape in witch the labels should be provided. Some criterion require
	 to subset the labels on the column and not the row, e.g. `nn.ParallelCriterion`,
	 and thus the shape must be `NxM` or `NxMx1` for it to work as expected.]]},
	call=function(self, label_shape)

	if (not self.batch_args) then
		self.batch_args = {}
	end
	self.batch_args.label_shape = label_shape

	return self
end}
return subset
