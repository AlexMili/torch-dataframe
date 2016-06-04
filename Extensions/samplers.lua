-- The current functions are a subset of the functions available in the torch-dataset
--  We have removed the multifile samplers and adapted to torch-dataframe
--  you can find the original code here: https://github.com/twitter/torch-dataset/blob/master/lua/Sampler.lua

local function LinearSampler(index, label)
	assert(index.indexType ~= 'SlowFS', "LinearSampler is not supported for SlowFS. Use PartLinearSampler (part-linear).")

	local i = 0
	local n = index.itemCount(label)
	return function()
		i = i + 1
		if i <= n then
			return index.itemAt(i, label)
		end
	end, function()
		i = 0
	end
end

local function tableCopy(t)
	local r = { }
	for _,p in ipairs(t) do
		 table.insert(r, p)
	end
	return r
end

local function UniformSampler(index, label)
	assert(index.indexType ~= 'SlowFS', "UniformSampler is not supported for SlowFS.")

	return function()
		local id = torch.random(1, index.itemCount(label))
		return index.itemAt(id, label)
	end, function()
		-- nothing to do on reset
	end
end

local function getNewPerm(size, oldPerm, depth)
	if not oldPerm then
		return torch.randperm(size)
	end

	depth = (depth and math.max(2, math.min(depth, size))) or 2

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
end

local function PermutationSampler(index, label)
	assert(index.indexType ~= 'SlowFS', "PermutationSampler is not supported for SlowFS.")

	local n = index.itemCount(label)
	local p = getNewPerm(n, p)
	local i = 0
	return function()
		i = i + 1
		if i <= n then
			return index.itemAt(p[i], label)
		end
	end, function()
		p = getNewPerm(n, p)
		i = 0
	end
end

local function LabelUniformSampler(index)
	assert(index.indexType ~= 'SlowFS', "LabelUniformSampler is not supported for SlowFS.")
	return function()
		local label = index.labels[torch.random(1, #index.labels)]
		return index.itemAt(torch.random(1, index.itemCount(label)), label)
	end, function()
		-- nothing to do on reset
	end
end

local function LabelDistributionSampler(index, distribution)
	assert(index.indexType ~= 'SlowFS', "LabelDistributionSampler is not supported for SlowFS.")
	local weights = {}
	-- if autoFill, set missing class weights to 1.
	local autoFill
	if distribution.autoFill then
		autoFill = distribution.autoFill
		distribution.autoFill = nil
	end
	for i,class in ipairs(index.labels) do
		local weight = distribution[class]
		if autoFill then
			weight = weight or distribution.defaultWeight or 1
		else
			assert(weight, 'LabelUniformSampler: 2nd arg must be a table [class]=weight')
		end
		weights[i] = weight
	end
	local weights = torch.Tensor(weights)
	local getClass = function()
		return torch.multinomial(weights, 1)[1]
	end
	return function()
		local label = index.labels[getClass()]
		return index.itemAt(torch.random(1, index.itemCount(label)), label)
	end, function()
		-- nothing to do on reset
	end
end

local function LabelPermutationSampler(index)
	assert(index.indexType ~= 'SlowFS', "LabelPermutationSampler is not supported for SlowFS.")
	local filePermTable = {}
	local nClasses = #index.labels
	local classPerm
	local i = 0
	local fidxt = torch.IntTensor(nClasses):fill(0)

	return function()
		i = i % nClasses
		if i == 0 then
			classPerm = getNewPerm(nClasses, classPerm)
		end

		i = i + 1
		local cidx = classPerm[i]
		local label = index.labels[cidx]
		local n = index.itemCount(label)
		fidxt[cidx] = fidxt[cidx]%n

		if fidxt[cidx] == 0 then
			filePermTable[cidx] = getNewPerm(n, filePermTable[cidx])
		end

		fidxt[cidx] = fidxt[cidx] + 1
		local fidx = filePermTable[cidx][fidxt[cidx]]

		return index.itemAt(fidx, label)
	end, function()
		-- nothing to do on reset?
	end
end
