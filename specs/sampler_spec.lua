-- The tests are a subset of the functions available in the torch-dataset
--  We have removed the multifile samplers and adapted to torch-dataframe
--  you can find the original code here: https://github.com/twitter/torch-dataset/blob/master/test/test_Sampler.lua

require 'lfs'
require 'torch'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
	lfs.chdir("..")
end

-- Include Dataframe lib
paths.dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Permutation Sampler", function()
	local index = IndexCSV('./data/sampler_csv_files/index.csv')
	local sampler,resetSampler = Sampler('permutation', index)
	local seen = { }
	local labelCounts = { }
	local prev
	for i = 1,75 do
		local s,label = sampler()
		table.insert(seen, s)
		if labelCounts[label] == nil then
			labelCounts[label] = 1
		else
			labelCounts[label] = labelCounts[label] + 1
		end
		if i % 25 == 0 then
			assert.is_true(sampler() == nil, 'going past the end must return nil')
			resetSampler()
			if prev ~= nil then
				assert.are.same(#seen, #prev, 'need to see the same amount sampled each loop')
				assert.are_not.same(seen, prev, 'the lists must have different orders')
				local sortedSeen = TestUtils.listCopy(seen)
				table.sort(sortedSeen)
				local sortedPrev = TestUtils.listCopy(prev)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')
				for _,label in ipairs(index.labels) do
					local x = index.itemCount(label)
					local y = labelCounts[label]
					assert.are.same(x, y, 'must have the same distribution of '..label..' saw '..y..' expected '..x)
				end
			end
			prev = seen
			seen = { }
			labelCounts = { }
		end
	end
end)

describe("Label Permutation Sampler", function()
	local index = IndexCSV('./data/sampler_csv_files/index.csv')
	local sampler = Sampler('label-permutation', index)
	local seen = { }
	local seenClasses = { }
	local labelCounts = { }
	local labelCountsClasses = {}
	local prev, prevClasses
	local fullLoop = 135

	for i = 1,3*fullLoop do
		local s,label = sampler()
		table.insert(seen, s)
		table.insert(seenClasses, label)
		labelCounts[label] = labelCounts[label] or 0
		labelCounts[label] = labelCounts[label] + 1
		labelCountsClasses[label] = labelCountsClasses[label] or 0
		labelCountsClasses[label] = labelCountsClasses[label] + 1

		if i % 3 == 0 then
			if prevClasses ~= nil then
				assert.are.same(#seenClasses, #prevClasses, 'need to see the same amount sampled each loop')
				assert.are_not.same(seenClasses, prevClasses, 'the lists must have different orders')
				local sortedSeen = TestUtils.listCopy(seenClasses)
				table.sort(sortedSeen)
				local sortedPrev = TestUtils.listCopy(prevClasses)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')

				for _,label in ipairs(index.labels) do
					local x = 1
					local y = labelCountsClasses[label]
					assert.are.same(x, y, 'wrong distribution saw '..y..' expected '..x)
				end
			end
			prevClasses = seenClasses
			seenClasses = { }
			labelCountsClasses = { }
		end

		if i % fullLoop == 0 then
			if prev ~= nil then
				assert.are.same(#seen, #prev, 'need to see the same amount sampled each loop')
				assert.are_not.same(seen, prev, 'the lists must have different orders')
				local sortedSeen = TestUtils.listCopy(seen)
				table.sort(sortedSeen)
				local sortedPrev = TestUtils.listCopy(prev)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')
				for _,label in ipairs(index.labels) do
					local x = fullLoop / #index.labels
					local y = labelCounts[label]
					assert.are.same(x, y, 'must have the same distribution of '..label..' saw '..y..' expected '..x)
				end
			end
			prev = seen
			seen = { }
			labelCounts = { }
		end
	end
end)

describe("Permutation Sampler With Label", function()
	local index = IndexCSV('./data/sampler_csv_files/index.csv')
	local sampler,resetSampler = Sampler('permutation', index, 'B')
	local seen = { }
	local prev
	for i = 1,27 do
		local s,label = sampler()
		assert.are.same(label, 'B', 'label must always be B')
		table.insert(seen, s)
		if i % 9 == 0 then
			assert.are.same(sampler(), nil, 'going past the end must return nil')
			resetSampler()
			if prev ~= nil then
				assert.are.same(#seen, #prev, 'need to see the same amount sampled each loop')
				assert.is_true(TestUtils.noDupes(seen) == true, 'should not see any dupes')
				assert.are_not.same(seen, prev, 'the lists must have different orders')
				local sortedSeen = TestUtils.listCopy(seen)
				table.sort(sortedSeen)
				local sortedPrev = TestUtils.listCopy(prev)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')
			end
			prev = seen
			seen = { }
		end
	end
end)

describe("Linear Sampler", function()
	local index = IndexCSV('./data/sampler_csv_files/index.csv')
	local sampler,resetSampler = Sampler('linear', index, 'B')
	for j = 1,3 do
		for i = 1,index.itemCount('B') do
			local s,label = sampler()
			assert.are.same(label, 'B', 'label must always be B')
			assert.are.same(s, index.itemAt(i, 'B'), 'must sample in index order')
		end
		assert.is_true(sampler() == nil, 'going past the end must return nil')
		resetSampler()
	end
end)

describe("Label Uniform Sampler", function()
	local index = IndexCSV('./data/sampler_csv_files/index.csv')
	local sample = Sampler('label-uniform', index)
	local hist = {}
	for i = 1,1e6 do
		local s,label = sample()
		hist[label] = (hist[label] or 0) + 1
	end
	local ratioA = math.abs((3 / (1e6/hist.A)) - 1)
	assert.is_true(ratioA < .1, 'ratios of labels A must be 1/3')
	local ratioB = math.abs((3 / (1e6/hist.A)) - 1)
	assert.is_true(ratioB < .1, 'ratios of labels B must be 1/3')
end)

describe("Uniform Sampler", function()
	local index = IndexCSV('./data/sampler_csv_files/index3.csv')
	local sample = Sampler('uniform', index)
	local hist = {}
	for i = 1,1e6 do
		local s,label = sample()
		hist[tonumber(s)] = (hist[tonumber(s)] or 0) + 1
	end
	hist = torch.Tensor(hist):div(1e6/index.itemCount()):add(-1):abs()
	local err = hist:max()
	assert.is_true(err < .1, 'ratios of samples must be uniform')
end)
