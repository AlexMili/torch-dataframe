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

describe("Loading batch process", function()
	local fake_loader = function(row) return torch.Tensor({1, 2}) end
	a = Dataframe("./data/realistic_29_row_data.csv")
	a:create_subsets()

	it("Raises an error if create_subsets hasn't be called",function()
		assert.has.error(function() a:reset_subsets() end)
	end)

	it("Initializes with random order for training and linear for the other",
		function()
		torch.manualSeed(0)
		a:reset_subsets()
		local order = 0

		assert.are.equal(a["/train"].subsets.samper, 'permutation')
		assert.are.equal(a["/test"].subsets.samper, 'linear')
		assert.are.equal(a["/validate"].subsets.samper, 'linear')
	end)

	describe("In action",function()
		a:create_subsets()

		it("Loads batches",function()
			local data, label =
				a["/train"]:
				get_batch{no_lines = 5}:
				to_tensor{
					load_data_fn = fake_loader
				}

			assert.is.equal(data:size(1), 5)-- "The data has invalid rows"
			assert.is.equal(data:size(2), 2)-- "The data has invalid columns"
			assert.is.equal(label:size(1), 5)--"The labels have invalid size"
		end)

		it("Doesn't load all cases",function()
			local batch_size = 6
			local count = 0
			local batch, reset
			for i=1,(math.ceil(a["/train"]:size(1)/batch_size) + 1) do
				batch, reset =
					a["/train"]:get_batch{no_lines = batch_size}
				if (batch == nil) then
					break
				end
				count = count + batch:size(1)
			end

			assert.are.equal(count, a["/train"]:size(1))
			assert.is_true(reset)

			a["/train"]:reset_sampler()
			batch, reset =
				a["/train"]:get_batch{no_lines = -1}

			assert.are.equal(batch:size(1), a["/train"]:size(1))
			assert.is_true(reset)
		end)

		-- TODO: Add tests for custom subset splits and samplers
	end)
end)
