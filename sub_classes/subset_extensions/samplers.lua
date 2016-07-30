-- The current functions are a subset of the functions available in the torch-dataset
--  We have removed the multifile samplers and adapted to torch-dataframe
--  you can find the original code here: https://github.com/twitter/torch-dataset/blob/master/lua/Sampler.lua

local params = {...}
local Df_Subset = params[1]

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

Df_Subset.get_sampler = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler">
### Df_Subset.get_sampler(@ARGP)

Retrieves a sampler function used in `get_batch`. Depending on the chosed sampler
some will return `nil` as you have reached the end, usually 1 epoch. In order to
restart the sampler you will then have to call the reset function. The samplers
with reset functions are:

- linear
- permutation

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function
]],
	{name="self", type="Df_Subset"},
	{name="sampler", type="string", doc="The sampler function name. Hyphens are replaced with underscore"},
	{name="args", type="Df_Dict", doc="Arguments that should be passed to function", default=false},
	call=function(self, sampler, args)
	-- Fix the name
	local sampler_cleaned = sampler:lower()
	if (not sampler_cleaned:match("^get_sampler_")) then
		sampler_cleaned = ("get_sampler_%s"):format(sampler:gsub("[- ]", "_"))
	end

	assert(type(self[sampler_cleaned]) == "function",
		("The sampler that you requested '%s' isn't available"):format(sampler_cleaned))

	if (args) then
		args = args.data
		local ret = Df_Subset[sampler_cleaned](self, args)
		return ret
	else
		return self[sampler_cleaned](self)
	end
end}


Df_Subset.get_sampler_linear = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler_linear">
### Sampler: linear - Df_Subset.get_sampler_linear(@ARGP)

A linear sampler, i.e. walk the records from start to end, after the end the
function returns nil until the reset is called that loops back to the start.
*Note*: Due to the permutation in `create_subsets` the samples will appear permuted
when walking through them unless you've only created a single subset with all the
data (a special case that does not permute the order).

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function
]],
	{name="self", type="Df_Subset"},
	call=function(self)

	local idx = 0
	local n = self:size(1)

	return function()
		idx = idx + 1
		if idx < n then
			return self:get_column('indexes')[idx]
		elseif (idx == n) then
			return self:get_column('indexes')[idx], true
		end
	end, function()
		idx = 0
	end
end}

Df_Subset.get_sampler_ordered = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler_ordered">
### Sampler: ordered - Df_Subset.get_sampler_ordered(@ARGP)

A sampler that orders all the samples before walking the records from start to end.
After the end the function returns nil until the reset is called that loops back to the start.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function
]],
	{name="self", type="Df_Subset"},
	call=function(self)

	local idx = 0
	local indexes,_ = torch.sort(self:get_column{column_name="indexes", as_tensor = true})
	_ = nil
	local n = self:size(1)

	return function()
		idx = idx + 1
		if idx < n then
			return indexes[idx]
		elseif (idx == n) then
			return indexes[idx], true
		end
	end, function()
		idx = 0
	end
end}

Df_Subset.get_sampler_uniform = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler_uniform">
### Sampler: uniform - Df_Subset.get_sampler_uniform(@ARGP)

A uniform neverending sampling.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Df_Subset"},
	call=function(self)

	return function()
		local idx = torch.random(1, self:size(1))
		return self:get_column('indexes')[idx]
	end, function()
		-- nothing to do on reset
	end
end}

-- Internal permutation helper
Df_Subset._get_new_permutation = argcheck{
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

Df_Subset.get_sampler_permutation = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler_permutation">
### Sampler: permutation - Df_Subset.get_sampler_permutation(@ARGP)

Permutations with shuffling after each epoch. Needs reset or the function only returns nil after 1 epoch

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function
]],
	{name="self", type="Df_Subset"},
	call=function(self)

	local n = self:size(1)
	local p = self._get_new_permutation(n, p)
	local idx = 0
	return function()
		idx = idx + 1
		if idx < n then
			return self:get_column('indexes')[p[idx]]
		elseif (idx == n) then
			return self:get_column('indexes')[p[idx]], true
		end
	end, function()
		p = self._get_new_permutation(n, p)
		idx = 0
	end
end}

-- Internal helper function
Df_Subset._get_lab_and_idx = argcheck{
	{name="df", type="Df_Subset"},
	call=function(df)
	local labels =
		df:unique{column_name = 'labels'}

	local label_idxs = {}
	for i=1,#labels do
		label_idxs[labels[i]] =
			df:which{column_name = 'labels',
			         value = labels[i]}
	end

	return labels, label_idxs
end}

Df_Subset.get_sampler_label_uniform = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler_label_uniform">
### Sampler: label-uniform - Df_Subset.get_sampler_label_uniform(@ARGP)

Uniform sampling from each label.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Df_Subset"},
	call=function(self)
	self:assert_has_column('labels',
	       "When using label-uniform you must set the labels")

	local labels, label_idxs
	labels, label_idxs =
		self:_get_lab_and_idx()

	return function()
		local label = labels[torch.random(1, #labels)]
		local idxs = label_idxs[label]
		local idx = idxs[torch.random(1, #idxs)]
		return self:get_column('indexes')[idx]
	end, function()
		-- nothing to do on reset
	end
end}

Df_Subset.get_sampler_label_distribution = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler_label_distribution">
### Sampler: label-distribution - Df_Subset.get_sampler_label_distribution(@ARGP)

Sample according to a distribution for each label. If a label is missing and `distribution.autoFill`
is set then the weights are assigned either `distribution.defaultWeight` or 1 is missing.

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Df_Subset"},
	{name='distribution', type='Df_Dict', doc='The distribution for the labels from which to sample'},
	call=function(self, distribution)
	self:assert_has_column('labels',
	       "When using label-distribution you must set the labels")

	distribution = distribution.data

	local weights = {}
	-- if autoFill, set missing class weights to 1.
	local autoFill
	if distribution.autoFill then
		autoFill = distribution.autoFill
		distribution.autoFill = nil
	end

	local labels, label_idxs
	labels, label_idxs =
		self:_get_lab_and_idx()

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
		local idx = label_idxs[label][torch.random(1, #label_idxs[label])]
		return self:get_column('indexes')[idx]
	end, function()
		-- nothing to do on reset
	end
end}

Df_Subset.get_sampler_label_permutation = argcheck{
	doc =  [[
<a name="Df_Subset.get_sampler_label_permutation">
### Sampler: label-permutation - Df_Subset.get_sampler_label_permutation(@ARGP)

Sample according to per label permutation. Once a labels permutations have been passed
it's reinitialized with a new permutation. The function permutes each class and then
also permutes the cases within each group.

Note that one epoch may be multiple passes for a class with few cases while the
larger classes will not have passed through the examples even once. All samples will
have passed at iteration: `no_cases_in_larges_class * no_classes`

@ARGT

_Return value_: (1) a sampler function (2) a reset sampler function (inactive)
]],
	{name="self", type="Df_Subset"},
	call=function(self)
	self:assert_has_column('labels',
	       "When using label-permutation you must set the labels")

	local labels, label_idxs
	labels, label_idxs =
		self:_get_lab_and_idx()

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

		local idx = label_idxs[label][fidx]
		return self:get_column('indexes')[idx]
	end, function()
		-- nothing to do on reset?
	end
end}
