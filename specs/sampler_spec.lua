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

function TestNoDupes(t)
   local r = { }
   for _,v in ipairs(t) do
      if r[v] ~= nil then
         return false
      else
         r[v] = true
      end
   end
   return true
end


describe("Linear Sampler", function()
	local df = Dataframe('./data/sampler_csv_files/index.csv'):
		where{column_name = 'label1',
		      item_to_find = 'B'}
	local sampler,resetSampler = df:
		get_sampler('linear')
	for j = 1,3 do
			for i = 1,df:value_counts{column_name = 'label1', as_dataframe = false}['B'] do
				local s = sampler()
				it("Check order", function()
					assert.are.same(df:get_column('label1')[s], 'B', 'label must always be B') -- remnant from torch-dataset
					assert.are.same(s, i, 'must sample in index order')
				end)
			end
		it("Check reset", function()
			assert.is_true(sampler() == nil, 'going past the end must return nil')
		end)
		resetSampler()
	end
end)

describe("Permutation Sampler", function()
	local df = Dataframe('./data/sampler_csv_files/index.csv')
	local sampler,resetSampler = df:get_sampler('permutation')
	local seen = { }
	local labelCounts = { }
	local prev
	for i = 1,75 do
		local s = sampler()
		local label = df:get_column('label1')[s]
		table.insert(seen, s)
		if (s) then
			if labelCounts[label] == nil then
				labelCounts[label] = 1
			else
				labelCounts[label] = labelCounts[label] + 1
			end
		end

		if i % 25 == 0 then
			local idx = ret sampler()
			it("Check reset", function()
				assert.is_true(idx == nil, 'going past the end must return nil')
			end)
			resetSampler()

			if prev ~= nil then
				assert.are.same(#seen, #prev, 'need to see the same amount sampled each loop')
				assert.are_not.same(seen, prev, 'the lists must have different orders')
				local sortedSeen = clone(seen)
				table.sort(sortedSeen)
				local sortedPrev = clone(prev)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')
				for _,label in ipairs(df:unique{column_name = 'label1'}) do
					local x = df:value_counts{column_name = 'label1', as_dataframe = false}[label]
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
	local df = Dataframe('./data/sampler_csv_files/index.csv'):
		wide2long(Df_Array("label1","label2","label3"),
	             "id", "label")

	local sampler = df:get_sampler('label-permutation', Df_Dict({column_name = 'label'}))
	local seen = { }
	local seenClasses = { }
	local labelCounts = { }
	local labelCountsClasses = { }
	local prev, prevClasses
	local fullLoop = 135

	for i = 1,3*fullLoop do
		local s = sampler()
		local label = df:get_column('label')[s]
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
				local sortedSeen = clone(seenClasses)
				table.sort(sortedSeen)
				local sortedPrev = clone(prevClasses)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')

				for _,label in ipairs(df:unique{column_name = 'label'}) do
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
				local sortedSeen = clone(seen)
				table.sort(sortedSeen)
				local sortedPrev = clone(prev)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')
				for _,label in ipairs(df:unique{column_name = 'label'}) do
					local x = fullLoop / #df:unique{column_name = 'label'}
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
if false then
describe("Permutation Sampler With Label", function()
	local df = Dataframe('./data/sampler_csv_files/index.csv')
	local sampler,resetSampler = df:get_sampler('permutation', 'B')
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
				assert.is_true(TestNoDupes(seen) == true, 'should not see any dupes')
				assert.are_not.same(seen, prev, 'the lists must have different orders')
				local sortedSeen = clone(seen)
				table.sort(sortedSeen)
				local sortedPrev = clone(prev)
				table.sort(sortedPrev)
				assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')
			end
			prev = seen
			seen = { }
		end
	end
end)

describe("Label Uniform Sampler", function()
	local df = Dataframe('./data/sampler_csv_files/index.csv')
	local sampler = df:get_sampler('label-uniform', Df_Dict({column_name = 'label1'}))
	local hist = {}
	for i = 1,1e6 do
		local s,label = sampler()
		hist[label] = (hist[label] or 0) + 1
	end
	local ratioA = math.abs((3 / (1e6/hist.A)) - 1)
	assert.is_true(ratioA < .1, 'ratios of labels A must be 1/3')
	local ratioB = math.abs((3 / (1e6/hist.A)) - 1)
	assert.is_true(ratioB < .1, 'ratios of labels B must be 1/3')
end)

describe("Uniform Sampler", function()
	local df = Dataframe('./data/sampler_csv_files/index3.csv')
	local sampler = df:get_sampler('uniform')
	local hist = {}
	for i = 1,1e6 do
		local s,label = sampler()
		hist[tonumber(s)] = (hist[tonumber(s)] or 0) + 1
	end
	hist = torch.Tensor(hist):div(1e6/df:size(1)):add(-1):abs()
	local err = hist:max()
	assert.is_true(err < .1, 'ratios of samples must be uniform')
end)
end
