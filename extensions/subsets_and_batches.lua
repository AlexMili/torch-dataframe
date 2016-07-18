local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Subsets and batches

The core idea behind loading batches and is that you split your dataset using the
`create_subsets` function where you can also choose the sampler that you want. The
sampler will decide how `get_batch` retrieves a Batchframe object. The Batchframe
is a sub_class to Dataframe with the major difference being the `to_tensor` functionality
that has here been extended so that you can load data and labels from the same dataset.

If you want to run the batch loader in parallel you need to keep the sampling in
the main thread and do the `to_tensor` conversion in the threads. This as the offset
for the sampler is hidden inside the samplers local environement and the main thread
has no way of knowing that you've sampled the next 30 cases in the data in a subthread.

]]

Dataframe.create_subsets = argcheck{
	doc = [[
<a name="Dataframe.create_subsets">
### Dataframe.create_subsets(@ARGP)

Initializes the metadata needed for batch loading:

_ Subsets e.g. for training, validating, and testing

_ Samplers associated with the above

The default data subsets and propotions are:
```
{['train'] = 0.7,
 ['validate'] = 0.2,
 ['test'] = 0.1}
```

The samplers defaults to permutation for the train set while the validate and
test have a linear. If you provide a string identifying the sampler it will be
used by all the subsets.

You can specify the data and label loaders used in the `Batchframe` by passing
the class argument. This is passed to the `Df_Subset` that then in turn passes
the information forward to the batches themself. As this is cascading through
the objects you must wrap the argument in multiple `Df_Tbl` for it to work, here
is a basic example:

```lua
my_data:create_subsets{
	class_args = Df_Tbl({
		batch_args = Df_Tbl({
			data = function(row) image_loader(row.filename) end,
			label = Df_Array("Gender")
		})
	})
}
```

The metadata is stored under `self.subsets.*`.

_Note_: This function must be called prior to load_batch as it needs the
information for loading correct rows.

_Return value_: self

@ARGT

]],
  {name='self', type='Dataframe'},
	{name='class_args', type='Df_Tbl', opt=true,
	 doc='Arguments to be passed to the class initializer'},
	call=function(self, class_args)
	-- Add default subsets
	local subsets = Df_Dict({['train'] = 0.7, ['validate'] = 0.2, ['test'] = 0.1})

	if (class_args) then
		return self:create_subsets(subsets, class_args)
	else
		return self:create_subsets(subsets)
	end
end}

Dataframe.create_subsets = argcheck{
	doc = [[

@ARGT

]],
	overload=Dataframe.create_subsets,
  {name='self', type='Dataframe'},
	{name='subsets', type='Df_Dict',
	 doc="The default data subsets"},
	{name='class_args', type='Df_Tbl', doc='Arguments to be passed to the class initializer', opt=true},
	call=function(self, subsets, class_args)
	subsets = subsets.data

	-- Add default samplers
	local samplers = {}
	if (subsets['train'] ~= nil) then
		samplers.train = 'permutation'
	end

	for _,type in ipairs({'validate', 'test'}) do
		if (subsets[type] ~= nil) then
			samplers[type] = 'linear'
		end
	end

	for type,_ in pairs(subsets) do
		if (samplers[type] == nil) then
			samplers[type] = 'permutation'
		end
	end

	if (class_args) then
		return self:create_subsets{
			subsets = Df_Dict(subsets),
			samplers = Df_Dict(samplers),
			class_args = class_args}
	else
		return self:create_subsets(Df_Dict(subsets), Df_Dict(samplers))
	end
end}

Dataframe.create_subsets = argcheck{
	doc = [[

@ARGT

]],
	overload=Dataframe.create_subsets,
  {name='self', type='Dataframe'},
	{name='subsets', type='Df_Dict',
	 doc="The default data subsets"},
	{name='sampler', type='string',
	 doc="The sampler to use together with all subsets."},
	{name='label_column', type='string',
	 doc="The label based samplers need a column with labels",
	 default = false},
	{name='sampler_args', type="Df_Tbl",
	 doc=[[Arguments needed for some of the samplers - currently only used by
	 the label-distribution sampler that needs the distribution. Note that
	 you need to have a somewhat complex table:
	 `Df_Tbl({train = Df_Dict({distribution = Df_Dict({A = 2, B=10})})})`.]],
	 default=false},
	{name='class_args', type='Df_Tbl', doc='Arguments to be passed to the class initializer', opt=true},
	call=function(self, subsets, sampler, label_column, sampler_args, class_args)
	subsets = subsets.data
	-- Set to nil so that we can easily rely on argcheck passing when label and args are missing
	if (not label_column) then
		label_column = nil
	end
	if (not sampler_args) then
		sampler_args = nil
	end

	-- Create a table with the same sampler for all elements
	local samplers = {}
	for key,_ in pairs(subsets) do
		samplers[key] = sampler
	end

	if (class_args) then
		return self:create_subsets{
			subsets = Df_Dict(subsets),
			samplers = Df_Dict(samplers),
			label_column = label_column,
			sampler_args = sampler_args,
			class_args = class_args}
	else
		return self:create_subsets{
			subsets = Df_Dict(subsets),
			samplers = Df_Dict(samplers),
			label_column = label_column,
			sampler_args = sampler_args}
	end
end}

Dataframe.create_subsets = argcheck{
	doc = [[

@ARGT

]],
	overload=Dataframe.create_subsets,
  {name='self', type='Dataframe'},
	{name='subsets', type='Df_Dict',
	 doc="The default data subsets"},
	{name='samplers', type='Df_Dict',
	 doc="The samplers to use together with the subsets."},
	{name='label_column', type='string', opt=true,
	 doc="The label based samplers need a column with labels"},
	{name='sampler_args', type="Df_Tbl", opt=true,
	 doc=[[Arguments needed for some of the samplers - currently only used by
	 the label-distribution sampler that needs the distribution. Note that
	 you need to have a somewhat complex table:
	 `Df_Tbl({train = Df_Dict({distribution = Df_Dict({A = 2, B=10})})})`.]]},
	{name='class_args', type='Df_Tbl', opt=true,
	 doc='Arguments to be passed to the class initializer'},
	call=function(self, subsets, samplers, label_column, sampler_args, class_args)
	subsets = subsets.data
	samplers = samplers.data
	-- Set to nil or empty table so that we can easily rely on argcheck passing
	if (not label_column) then
		label_column = nil
	end
	if (not sampler_args) then
		sampler_args = {}
	else
		sampler_args = sampler_args.data
	end

	-- Check data_type for inconcistencies
	local total = 0
	for v,p in pairs(subsets) do
		assert(type(v) == 'string', "The data types keys should be strings")
		assert(type(p) == 'number', "The data types values should be numbers")
		total = total + p
	end

	-- Normalize the data to proportions
	if (math.abs(total - 1) > 1e-4) then
		print("Warning: You have provided a total ~= 1 (".. total .. ")")
		for v,p in pairs(subsets) do
			subsets[v] = subsets[v]/total
		end
	end

	-- Add samplers that are missing in the sampler input
	for type,_ in pairs(subsets) do
		if (samplers[type] == nil) then
			if (type == 'validate' or
			    type == 'test') then
				samplers[type] = 'linear'
			else
				samplers[type] = 'permutation'
			end
		end
	end

	if (class_args) then
		class_args = class_args.data
		assert(not class_args[1], "All class arguments for subsets have to be named")
	else
		class_args = {}
	end

	self.subsets = {
		subset_splits = subsets,
		samplers = samplers,
		label_column = label_column,
		sampler_args = sampler_args,
		class_args = class_args
	}

	return self:reset_subsets()
end}

Dataframe.reset_subsets = argcheck{
	doc = [[
<a name="Dataframe.reset_subsets">
### Dataframe.reset_subsets(@ARGP)

Clears the previous subsets and creates new ones according to saved information
in the `self.subsets.subset_splits` and `subsets.subsets.samplers` created by
the `create_subsets` function.

@ARGT

_Return value_: self
]],
  {name='self', type='Dataframe'},
	call=function(self)
	assert(self.subsets ~= nil and
	       self.subsets.subset_splits ~= nil and
	       self.subsets.samplers ~= nil and
	       self.subsets.class_args ~= nil,
	       [[ You haven't initiated your subsets correctly. Please call
	       create_subsets() before the reset_subsets()]])

	local n_subsets = table.exact_length(self.subsets.subset_splits)
	local permuations = torch.randperm(self:size(1))
	if (n_subsets == 1) then
		-- If only one subset then it's a special case and for some of the tests it's
		-- beneficial if the sampling is done in a linear order
		permuations = torch.linspace(1, self:size(1), self:size(1))
	end

	local offset = 0
	local i = 0
	local subset_permutations

	local label_column = self.subsets.label_column
	if (label_column) then
		self:assert_has_column(label_column)
		label_column = self:get_column(label_column)
	end

	self.subsets.sub_objs = {}
	for name, proportion in pairs(self.subsets.subset_splits) do
		i = i + 1
		-- Prepare label column for subset

		if (i == n_subsets) then
		-- Use the remainder (should be correct as the create_subsets takes care of normalizing)
			subset_permutations = permuations[{{offset + 1, self:size(1)}}]

			offset = self:size(1)
		else
			local no_to_select = self.subsets.subset_splits[name] * self:size(1)
			-- Clean the number just to make sure we have a valid number
			-- and that the number is an integer
			no_to_select = math.max(1, math.floor(no_to_select))
			subset_permutations = permuations[{{offset + 1, offset + no_to_select}}]
			offset = offset + no_to_select
		end

		-- The arguments forthe subsets
		local subset_args = clone(self.subsets.class_args)
		subset_args.sampler = self.subsets.samplers[name]
		subset_args.sampler_args = self.subsets.sampler_args[name]
		subset_args.parent = self

		-- If the label_column exists then each entry is index + label
		subset_args.indexes = Df_Array(subset_permutations)
		if (label_column) then
			-- A little hacky but it should speed up and cheking tensor data makes no sense
			local labels = Df_Array()
			subset_permutations:apply(function(key)
				labels.data[#labels.data + 1] = label_column[key]
			end)
			subset_args.labels = labels
		end

		self.subsets.sub_objs[name] =
			Df_Subset.new(subset_args)
	end

	return self
end}

Dataframe.has_subset = argcheck{
	doc = [[
<a name="Dataframe.has_subset">
### Dataframe.has_subset(@ARGP)

Checks if subset used in batch loading is available

@ARGT

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name='subset', type='string', doc='Type of subset to check for'},
	call = function(self, subset)
	return(self.subsets ~= nil and
	       self.subsets.sub_objs ~= nil and
	       self.subsets.sub_objs[subset] ~= nil)
end}

Dataframe.get_subset = argcheck{
	doc = [[
<a name="Dataframe.get_subset">
### Dataframe.get_subset(@ARGP)

Returns the entire subset as either a Df_Subset, Dataframe or Batchframe

@ARGT

_Return value_: Df_Subset, Dataframe or Batchframe
]],
	{name="self", type="Dataframe"},
	{name='subset', type='string', doc='Type of data to load'},
	{name='frame_type', type='string',
	 doc=[[Choose the type of return object that you're interested in.
	 Return a Batchframe with a different `to_tensor` functionality that allows
	 loading data, label tensors simultaneously]], default="Df_Subset"},
	{name='class_args', type='Df_Tbl', opt=true,
	 doc=[[
	 Arguments to be passed to the class initializer - overrides the arguments within the
	 self.subsets that is stored after the `create_subsets` call.
	 ]]},
	call = function(self, subset, frame_type, class_args)
	assert(self:has_subset(subset),
	       ("There is no subset named '%s' among the subsets: %s"):
	       format(subset, table.get_key_string(self.subsets.sub_objs)))

	local sub_obj = self.subsets.sub_objs[subset]
	if (frame_type == "Df_Subset") then
		return sub_obj
	end

	local create_args = {
		index_items = Df_Array(sub_obj:get_column('indexes')),
		frame_type = frame_type
	}

	if (class_args) then
		create_args.class_args = Df_Tbl(class_args.data)
	elseif(self.subsets.class_args) then
		create_args.class_args = Df_Tbl(self.subsets.class_args)
	end

	return self:
		_create_subset(create_args)
end}
