-- The tests are a subset of the functions available in the torch-dataset
--  We have removed the multifile samplers and adapted to torch-dataframe
--  you can find the original code here: https://github.com/twitter/torch-dataset/blob/master/test/test_Sampler.lua

require 'lfs'

-- Ensure the test is launched within the specs/ folder
assert(string.match(lfs.currentdir(), "specs")~=nil, "You must run this test in specs folder")

local initial_dir = lfs.currentdir()

-- Go to specs folder
while (not string.match(lfs.currentdir(), "/specs$")) do
  lfs.chdir("..")
end

local specs_dir = lfs.currentdir()
lfs.chdir("..")-- one more directory and it is lib root

-- Include Dataframe lib
dofile("init.lua")

-- Go back into initial dir
lfs.chdir(initial_dir)

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

local function dataLoader(num, skip_wide)
	skip_wide = skip_wide or false
	num = num or ''
	local fn = ('./data/sampler_csv_files/index%s.csv'):format(tostring(num))
	local df = Dataframe(fn)
	if (skip_wide) then
		return df
	end
	return df:wide2long("label[0-9]+", "id", "label")
end


describe([[The #linear sampler should call each element in a linear fashion and
	after finishing the epoch it requires a reset in order to allow new sampling]],
	function()
	local df = dataLoader():
		where{column_name = 'label',
		      item_to_find = 'B'}
	it("Check order and reset", function()
		df:create_subsets(Df_Dict({core = 1}),
		                  Df_Dict({core = 'linear'}))
		local sampler = df["/core"].sampler
		local resetSampler = df["/core"].reset
		for j = 1,3 do

			for i = 1,df:size(1) do
				local s = sampler()
					assert.are.same(s, i, 'must sample in index order')
			end

			local idx = sampler()
			assert.is_true(idx == nil, 'going past the end must return nil, you got ' .. tostring(idx))

			resetSampler()
		end
	end)
end)


describe([[The #ordered sampler should call each element in a linear fashion and
	after finishing the epoch it requires a reset in order to allow new sampling]],
	function()
	local df = dataLoader():
	where{column_name = 'label',
	      item_to_find = 'B'}
	df:create_subsets(Df_Dict{train = .5, test = .5},
	                  Df_Dict{train = 'linear', test = "ordered"})
	local testSampler = df["/test"].sampler
	local testResetSampler = df["/test"].reset
	local trainSampler = df["/train"].sampler
	local trainResetSampler = df["/train"].reset

	-- The train linear sampler shouldn't have any order as the indexes have been
	--  created from a parmuted subset
	it("Check permuted linear", function()
		local prev_idx = trainSampler()
		local s = trainSampler()
		local diff = 0
		while s do
			diff = diff + (s - prev_idx - 1)
			prev_idx = s
			s = trainSampler()
		end
		assert.is_not(diff, 0, "The subsetting should create a set of random indexes not a predictable 1,2,3,4...")
	end)


	-- The ordered sampler should always return indexes that are increasing
	it("Check permuted order", function()
		local prev_idx = -1
		local diff = 0
		local prev_idx = testSampler()
		local s = testSampler()
		local diff = 0
		while s do
			assert.is_true(s > prev_idx, 'must sample in index order')
			diff = diff + (s - prev_idx - 1)
			prev_idx = s
			s = testSampler()
		end

		assert.is_true(diff >= 0,
			("The permuted indexes should increase (can be 0 if permutations happened to be in order) - %d"):format(diff))
	end)

	it("Check linear reset", function()
		local idx = trainSampler()
		assert.is_true(idx == nil, 'going past the end must return nil, you got ' .. tostring(idx))

		trainResetSampler()
		local idx = trainSampler()
		assert.is_true(idx ~= nil, 'resetting the sampler should result in new cases')
	end)

	it("Check ordered reset", function()
		local idx = testSampler()
		assert.is_true(idx == nil, 'going past the end must return nil, you got ' .. tostring(idx))

		testResetSampler()
		local idx = testSampler()
		assert.is_true(idx ~= nil, 'resetting the sampler should result in new cases')
	end)
end)

describe([[The permutation sampler should permute the results but otherwise works
similar to the linear with a requirement of calling the reset at the end of an
epoch.
]],
	function()
	local df = dataLoader(	)
	it([[Permutation sampler with permutation using single label should
return a different permutation every time but the content should be the
same after sorting.
]],
	function()
		df:create_subsets(Df_Dict({core = 1}),
		                  Df_Dict({core = 'permutation'}))
		local sampler = df["/core"].sampler
		local resetSampler = df["/core"].reset

		local seen = { }
		local labelCounts = { }
		local prev
		for i = 1,75 do
			local s = sampler()
			local label = df:get_column('label')[s]
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
				assert.is_true(idx == nil, 'going past the end must return nil')
				resetSampler()

				if prev ~= nil then
						assert.are.same(#seen, #prev, 'need to see the same amount sampled each loop')
						assert.are_not.same(seen, prev, 'the lists must have different orders')
					local sortedSeen = clone(seen)
					table.sort(sortedSeen)
					local sortedPrev = clone(prev)
					table.sort(sortedPrev)
						assert.are.same(sortedSeen, sortedPrev, 'the lists must have the same sorted orders')
					for _,label in ipairs(df:unique{column_name = 'label'}) do
						local x = df:value_counts{column_name = 'label', as_dataframe = false}[label]
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

	describe([[Changing to only use B shouldn't impact anything]],
	function()
		-- This is somewhat of a torch-dataset remnant
		local df = dataLoader():where('label', 'B')
		df:create_subsets(Df_Dict({core = 1}),
		                  Df_Dict({core = 'permutation'}))
		it("Check order and reset", function()
			local sampler = df["/core"].sampler
			local resetSampler = df["/core"].sampler
			local seen = { }
			local prev
			for i = 1,df["/core"]:size(1) do
				local s,label = sampler()
				table.insert(seen, s)
				if i % 9 == 0 then
					local idx = sampler()
					assert.are.same(idx, nil)
					resetSampler()
					if prev ~= nil then
						assert.are.same(no_seen, #prev, 'need to see the same amount sampled each loop')
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
	end)
end)

describe("Sample from a distribution that is permuted by label #label_permutation", function()
	local df = dataLoader()
	df:create_subsets(Df_Dict({core = 1}),
	                  Df_Dict({core = 'label-permutation'}),
	                  "label")
	local sampler = df["/core"].sampler
	local seen = { }
	local seenClasses = { }
	local labelCounts = { }
	local labelCountsClasses = { }
	local prev, prevClasses
	local fullLoop = 135

	it([[The order should be different between each sampling]],
	function()
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
					local no_seen = #seenClasses
					local no_prev = #prevClasses
					assert.are.same(no_seen, no_prev, 'need to see the same amount sampled each loop')
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
end)


describe("Sampler from a #label_uniform distribution", function()
	it("The ratios between the labels should be equally distributed", function()
		local df = dataLoader()
		df:create_subsets(Df_Dict({core = 1}),
		                  Df_Dict({core = 'label-uniform'}),
		                  "label")
		local sampler = df["/core"].sampler
		local hist = {}
		local no_samplers = 1e4
		for i = 1,no_samplers do
			local s = sampler()
			local label = df:get_column('label')[s]
			hist[label] = (hist[label] or 0) + 1
		end
		local ratioA = math.abs((3 / (no_samplers/hist.A)) - 1)
		assert.is_true(ratioA < .1, 'ratios of labels A must be 1/3')
		local ratioB = math.abs((3 / (no_samplers/hist.A)) - 1)
		assert.is_true(ratioB < .1, 'ratios of labels B must be 1/3')
	end)
end)

describe("Sampler from a #uniform distribution", function()
	it("The ratios should be evenly spread out", function()
		local df = dataLoader(3, true)
		df:create_subsets(Df_Dict({core = 1}),
		                  Df_Dict({core = 'uniform'}))
		local sampler = df["/core"].sampler
		local hist = {}
		local no_samplers = 1e4
		for i = 1,no_samplers do
			local s = sampler()
			hist[tonumber(s)] = (hist[tonumber(s)] or 0) + 1
		end
		hist = torch.Tensor(hist):div(no_samplers/df:size(1)):add(-1):abs()
		local err = hist:max()
		assert.is_true(err < .2,
		               ('ratios of samples must be uniform %.2f is bigger than the allowed .2'):
									 format(err))
	end)
end)
