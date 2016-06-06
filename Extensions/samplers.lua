-- The current functions are a subset of the functions available in the torch-dataset
--  We have removed the multifile samplers and adapted to torch-dataframe
--  you can find the original code here: https://github.com/twitter/torch-dataset/blob/master/lua/Sampler.lua

local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Sampler functions

The sampler functions come from the [torch-dataset](https://github.com/twitter/torch-dataset/blob/master/lua/Sampler.lua)
and have been adapted for the torch-dataframe package. In the original samplers
you had the option of sampling one label at the time. As this may be confusing together
with the data split subsets you should in this package start with subsetting the data first
using the `where` function for attaining the same functionality.

]]

Dataframe.get_sampler = argcheck{
	doc =  [[
<a name="Dataframe.get_sampler">
### Dataframe.get_sampler(@ARGP)

Retrieves a sampler function used in `get_batch`. Depending on the chosed sampler
some will return `nil` as you have reached the end, usually 1 epoch. In order to
restart the sampler you will then have to call the reset function. The samplers
with reset functions are:

- linear
- permutation

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function
]],
	{name="self", type="Dataframe"},
	{name="sampler", type="string", doc="The sampler function name. Hyphens are replaced with underscore"},
	{name="args", type="Df_Dict", doc="Arguments that should be passed to function", default=false},
	call=function(self, sampler, args)
	local sampler_cleaned = sampler:lower()
	if (not sampler_cleaned:match("^get_sampler_")) then
		sampler_cleaned = ("get_sampler_%s"):format(sampler:gsub("-", "_"))
	end

	assert(type(self[sampler_cleaned]) == "function",
		("The sampler that you requested '%s' isn't available"):format(sampler_cleaned))

	if (args) then
		args = args.data
		local ret = Dataframe[sampler_cleaned](self, args)
		return ret
	else
		return self[sampler_cleaned](self)
	end
end}

Dataframe.get_sampler = argcheck{
	doc =  [[

@ARGT

]],
	overload=Dataframe.get_sampler,
	{name="self", type="Dataframe"},
	{name="sampler", type="string", doc="The sampler function name. Hyphens are replaced with underscore"},
	{name="args", type="Df_Dict", doc="Arguments that should be passed to function", default=false},
	{name="subset", type="string", doc=[[
	The data split subset that you want to use the sampler on. If you provide none
	then the entire dataset will be used.
	]]},
	call=function(self, sampler, args, subset)
	assert(self:has_subset(subset), ("The subset %s doesn't seem to exist"):format(subset))

	-- Add get_sampler_ if not present
	local sampler_cleaned = sampler:lower()
	if (not sampler_cleaned:match("^get_sampler_")) then
		local sampler_cleaned = ("get_sampler_%s"):format(sampler:gsub("-", "_"))
	end

	assert(type(self[sampler_cleaned]) == "function",
		("The sampler that you requested '%s' isn't available"):format(sampler_cleaned))

	if (args) then
		args.data.subset = subset
		return self[sampler_cleaned](self, args.data)
	else
		return self[sampler_cleaned](self, subset)
	end
end}


Dataframe.get_sampler_linear = argcheck{
	doc =  [[
<a name="Dataframe.get_sampler_linear">
### Dataframe.get_sampler_linear(@ARGP)

A linear sampler, i.e. walk the records from start to end, after the end the
function returns nil until the reset is called that loops back to the start.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function
]],
	{name="self", type="Dataframe"},
	call=function(self)

	local i = 0
	local n = self:size(1)

	return function()
		i = i + 1
		if i <= n then
			return i
		end
	end, function()
		i = 0
	end
end}

Dataframe.get_sampler_linear = argcheck{
	doc =  [[
Add a subset name if you only want to walk through a particular subset

@ARGT

]],
	overload=Dataframe.get_sampler_linear,
	{name="self", type="Dataframe"},
	{name="subset", type="string", doc=[[
	The data split subset that you want to use the sampler on. If you provide none
	then the entire dataset will be used.
	]]},
	call=function(self, subset)
	assert(self:has_subset(subset), ("The subset %s doesn't seem to exist"):format(subset))

	local i = 0
	local n = self:subset_size(subset)
	return function()
		i = i + 1
		if i <= n then
			return self:subset_idx_2_real(i, subset)
		end
	end, function()
		i = 0
	end
end}

Dataframe.get_sampler_uniform = argcheck{
	doc =  [[
<a name="Dataframe.get_sampler_uniform">
### Dataframe.get_sampler_uniform(@ARGP)

A uniform neverending sampling.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Dataframe"},
	call=function(self)

	return function()
		return torch.random(1, self:size(1))
	end, function()
		-- nothing to do on reset
	end
end}

Dataframe.get_sampler_uniform = argcheck{
	doc =  [[
Add a subset name if you only want to walk through a particular subset

@ARGT

]],
	overload=Dataframe.get_sampler_uniform,
	{name="self", type="Dataframe"},
	{name="subset", type="string", doc=[[
	The data split subset that you want to use the sampler on. If you provide none
	then the entire dataset will be used.
	]]},
	call=function(self, subset)
	assert(self:has_subset(subset), ("The subset %s doesn't seem to exist"):format(subset))

	return function()
		local id = torch.random(1, self:subset_size(subset))
		return self:subset_idx_2_real(id)
	end, function()
		-- nothing to do on reset
	end
end}

-- Internal permutation helper
Dataframe._get_new_permutation = argcheck{
	{name="size", type="number"},
	{name="oldPerm", type="torch.*Tensor", doc="previous permutation", default = false},
	{name="depth", type="number", default=2},
	call=function(size, oldPerm, depth)
	if not oldPerm then
		return torch.randperm(size)
	end

	depth = math.max(2, math.min(depth, size))

	-- Make sure we have a different distribution
	-- when resetting the permutation to make test work.
	local oldval
	if oldPerm then
		oldval = (size >= depth and oldPerm[{{1, depth}}]:clone()) or nil
	end

	local newval
	-- Loop til they are different.
	-- Prob[k identical values | permSize == n] = (n-k)!/n!,
	-- so perfectly fine regarding to memory allocation even for small sizes.
	while not newval or (oldval and torch.add(newval,-1, oldval):abs():sum() == 0) do
		oldPerm = torch.randperm(size)
		newval = (size >= depth and oldPerm[{{1, depth}}]:clone()) or true
	end
	return oldPerm
end}

Dataframe.get_sampler_permutation = argcheck{
	doc =  [[
<a name="Dataframe.get_sampler_permutation">
### Dataframe.get_sampler_permutation(@ARGP)

Permutations with shuffling after each epoch. Needs reset or the function only returns nil after 1 epoch

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function
]],
	{name="self", type="Dataframe"},
	call=function(self)

	local n = self:size(1)
	local p = self._get_new_permutation(n, p)
	local i = 0
	return function()
		i = i + 1
		if i <= n then
			return p[i]
		end
	end, function()
		p = self._get_new_permutation(n, p)
		i = 0
	end
end}

Dataframe.get_sampler_permutation = argcheck{
	doc =  [[
Add a subset name if you only want to walk through a particular subset

@ARGT

]],
	overload=Dataframe.get_sampler_permutation,
	{name="self", type="Dataframe"},
	{name="subset", type="string", doc=[[
	The data split subset that you want to use the sampler on. If you provide none
	then the entire dataset will be used.
	]]},
	call=function(self, subset)
	assert(self:has_subset(subset), ("The subset %s doesn't seem to exist"):format(subset))

	local n = self:subset_size(subset)
	local p = self._get_new_permutation(n)
	local i = 0
	return function()
		i = i + 1
		if i <= n then
			return self:subset_idx_2_real(p[i], subset)
		end
	end, function()
		p = self._get_new_permutation(n, p)
		i = 0
	end
end}

-- Internal helper function
Dataframe._get_lab_and_idx = argcheck{
	{name="df", type="Dataframe"},
	{name="column_name", type="string"},
	call=function(df, column_name)
	local labels =
		df:unique{column_name = column_name}

	local label_idxs = {}
	for i=1,#labels do
		label_idxs[labels[i]] =
			df:which{column_name = column_name,
							 value = labels[i]}
	end

	return labels, label_idxs
end}

Dataframe._get_lab_and_idx = argcheck{
	overload = Dataframe._get_lab_and_idx,
	{name="self", type="Dataframe"},
	{name="column_name", type="string"},
	{name="subset_df", type="Dataframe"},
	call=function(self, subset_df)
	local labels, sub_label_idxs = self._get_lab_and_idx(subset_df, column_name)

	-- Convert indexes from subset to the original dataset
	local label_idxs = {}
	for i=1,#labels do
		local lab  = labels[i]
		label_idxs[lab] = {}
		for ii=1,#sub_label_idxs[lab] do
			table.insert(label_idxs[lab],
									 self:subset_idx_2_real(sub_label_idxs[lab][ii]))
		end
	end

	return labels, label_idxs
end}

Dataframe.get_sampler_label_uniform = argcheck{
	doc =  [[
<a name="Dataframe.get_sampler_label_uniform">
### Dataframe.get_sampler_label_uniform(@ARGP)

Uniform sampling from each label.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column which labels to use'},
	{name="subset", type="string", doc=[[
	The data split subset that you want to use the sampler on. If you provide none
	then the entire dataset will be used.
	]], default = false},
	call=function(self, column_name, subset)
	assert(self:has_column(column_name),
	       "Invalid column name: " .. column_name)

	local labels, label_idxs
	if (subset) then
		assert(self:has_subset(subset), ("The subset %s doesn't seem to exist"):format(subset))

		-- TODO: not really an efficient solution - should probably just get a single column in the subset
		local tmp_subset = self:get_subset(subset)
		labels, label_idxs = self:_get_lab_and_idx(tmp_subset, column_name)
	else
		labels, label_idxs =
			self:_get_lab_and_idx(column_name)
	end

	return function()
		local label = labels[torch.random(1, #labels)]
		local idxs = label_idxs[label]
		return idxs[torch.random(1, #idxs)]
	end, function()
		-- nothing to do on reset
	end
end}

Dataframe.get_sampler_label_distribution = argcheck{
	doc =  [[
<a name="Dataframe.get_sampler_label_distribution">
### Dataframe.get_sampler_label_distribution(@ARGP)

Sample according to a distribution for each label. If a label is missing and `distribution.autoFill`
is set then the weights are assigned either `distribution.defaultWeight` or 1 is missing.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column which labels to use'},
	{name='distribution', type='Df_Dict', doc='The distribution for the labels from which to sample'},
	{name="subset", type="string", doc=[[
	The data split subset that you want to use the sampler on. If you provide none
	then the entire dataset will be used.
	]], default = false},
	call=function(self, column_name, distribution, subset)
	assert(self:has_column(column_name),
	      "Invalid column name: " .. column_name)

	distribution = distribution.data

	local weights = {}
	-- if autoFill, set missing class weights to 1.
	local autoFill
	if distribution.autoFill then
		autoFill = distribution.autoFill
		distribution.autoFill = nil
	end

	local labels, label_idxs
	if (subset) then
		assert(self:has_subset(subset), ("The subset %s doesn't seem to exist"):format(subset))

		-- TODO: not really an efficient solution - should probably just get a single column in the subset
		local tmp_subset = self:get_subset(subset)
		labels, label_idxs = self:_get_lab_and_idx(tmp_subset, column_name)
	else
		labels, label_idxs =
			self:_get_lab_and_idx(column_name)
	end

	for i,class in ipairs(labels) do
		local weight = distribution[class]
		if autoFill then
			weight = weight or distribution.defaultWeight or 1
		else
			assert(weight, 'label-uniform: 2nd arg must be a table [class]=weight')
		end
		weights[i] = weight
	end

	local weights = torch.Tensor(weights)
	local getClass = function()
		return torch.multinomial(weights, 1)[1]
	end

	return function()
		local label = labels[getClass()]
		return label_idxs[label][torch.random(1, #label_idxs[label])]
	end, function()
		-- nothing to do on reset
	end
end}

Dataframe.get_sampler_label_permutation = argcheck{
	doc =  [[
<a name="Dataframe.get_sampler_label_permutation">
### Dataframe.get_sampler_label_permutation(@ARGP)

Sample according to per label permutation. Once a labels permutations have been passed
it's reinitialized with a new permutation. The function permutes each class and then
also permutes the cases within each group.

Note that one epoch may be multiple passes for a class with few cases while the
larger classes will not have passed through the examples even once. All samples will
have passed at iteration: `no_cases_in_larges_class * no_classes`

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Dataframe"},
	{name='column_name', type='string', doc='column which labels to use'},
	{name="subset", type="string", doc=[[
	The data split subset that you want to use the sampler on. If you provide none
	then the entire dataset will be used.
	]], default = false},
	call=function(self, column_name, subset)
	assert(self:has_column(column_name),
	      "Invalid column name: " .. column_name)

	local labels, label_idxs
	if (subset) then
		assert(self:has_subset(subset), ("The subset %s doesn't seem to exist"):format(subset))

		-- TODO: not really an efficient solution - should probably just get a single column in the subset
		local tmp_subset = self:get_subset(subset)
		labels, label_idxs = self:_get_lab_and_idx(tmp_subset, column_name)
	else
		labels, label_idxs =
			self:_get_lab_and_idx(column_name)
	end

	local filePermTable = {}
	local nClasses = #labels
	local classPerm
	local i = 0
	local fidxt = torch.IntTensor(nClasses):fill(0)

	return function()
		i = i % nClasses
		if i == 0 then
			classPerm = self._get_new_permutation(nClasses, classPerm)
		end

		i = i + 1
		local cidx = classPerm[i]
		local label = labels[cidx]
		local n = #label_idxs[label]
		fidxt[cidx] = fidxt[cidx]%n

		if fidxt[cidx] == 0 then
			filePermTable[cidx] = self._get_new_permutation(n, filePermTable[cidx])
		end

		fidxt[cidx] = fidxt[cidx] + 1
		local fidx = filePermTable[cidx][fidxt[cidx]]

		return label_idxs[label][fidx]
	end, function()
		-- nothing to do on reset?
	end
end}
