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
	local a = Dataframe("./data/realistic_29_row_data.csv")

	it("Raises an error if init_batch hasn't be called",function()
		assert.has.error(function() a:load_batch{no_lines = 10,
		                                         load_row_fn = fake_loader} end)
	end)

	it("Initializes",function()
		torch.manualSeed(0)
		a:init_batch()
		local order = 0

		for i = 2,#a.batch.datasets["train"] do
			order = order + a.batch.datasets["train"][i] - a.batch.datasets["train"][i - 1] - 1
		end

		assert.is.not_equal(order, 0)

		a:init_batch{shuffle = false}
		order = 0

		for i = 2,#a.batch.datasets["train"] do
			order = order + a.batch.datasets["train"][i] - a.batch.datasets["train"][i - 1] - 1
		end

		assert.is.equal(order, 0)

		assert.is_true(a:has_subset("train"))
		assert.is_true(a:get_batch("train"):size(1) > 0)
		assert.is_true(a:get_batch("train"):size(1) < a:size(1))
		assert.are.same(a:get_batch("train"):size(2), a:size(2))
	end)

	describe("In action",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:init_batch()

		it("Fails if the number of lines isn't correct",function()
			--assert.has.error(a:load_batch(0))
		end)


		it("Loads batches",function()
			a:init_batch()
			local data, label =
				a:load_batch{no_lines = 5,
				             load_row_fn = fake_loader,
				             type = 'train'}
			assert.is.equal(data:size(1), 5)-- "The data has invalid rows"
			assert.is.equal(data:size(2), 2)-- "The data has invalid columns"
			assert.is.equal(label:size(1), 5)--"The labels have invalid size"
		end)

		it("Loads categorical columns",function()
			a:as_categorical('Gender')
			local data, label, names =
				a:load_batch{no_lines = 5,
				             load_row_fn = fake_loader,
				             type = 'train',
				             offset = 0}
			assert.is.equal(data:size(1), 5)-- "The data with gender has invalid rows"
			assert.is.equal(data:size(2), 2)-- "The data with gender has invalid columns"
			assert.is.equal(label:size(1), 5)-- "The labels with gender have invalid size"
			assert.are.same(names, {'Gender', 'Weight'})-- "Invalid names returned"

			data, label, names =
				a:load_batch{no_lines = 5,
				             load_row_fn = fake_loader,
				             type = 'train',
				             offset = 0}

			assert.is.equal(data:size(1), 5)-- "The data with gender has invalid rows"
			assert.is.equal(data:size(2), 2)-- "The data with gender has invalid columns"
			assert.is.equal(label:size(1), 5)-- "The labels with gender have invalid size"
		end)

		it("Doesn't load all cases",function()
			local batch_size = 6
			for i=1,10 do
				local data, label, names =
					a:load_batch{no_lines = batch_size,
					             load_row_fn = fake_loader,
					             type = 'train',
					             offset = (i - 1)*batch_size}
				assert.is.equal(label:size(1), batch_size)-- "The labels have invalid size at iteration " .. i
				assert.is.equal(data:size(1), batch_size)-- "The data has invalid size at iteration " .. i
			end

			local data, label =
				a:load_batch{no_lines = -1,
				            load_row_fn = fake_loader,
				            offset = 0,
				            type = 'train'}
			assert.are.same(data:size(1), a:batch_size('train'))-- "Doesn't load all train cases"
			data, label =
				a:load_batch{no_lines = -1,
				            load_row_fn = fake_loader,
				            offset = 0,
				            type = 'validate'}
			assert.are.same(data:size(1), a:batch_size('validate'))-- "Doesn't load all validation cases"
			data, label =
				a:load_batch{no_lines = -1,
				            load_row_fn = fake_loader,
				            offset = 0,
				            type = 'test'}
			assert.are.same(data:size(1), a:batch_size('test'))-- "Doesn't load all test cases"

			data, label =
				a:load_batch{no_lines = a:batch_size('train'),
				            load_row_fn = fake_loader,
				            offset = 0,
				            type = 'train'}
			assert.are.same(data:size(1), a:batch_size('train'))-- "Doesn't load all train cases when max number specified"
			data, label =
				a:load_batch{no_lines = a:batch_size('validate'),
				            load_row_fn = fake_loader,
				            offset = 0,
				            type = 'validate'}
			assert.are.same(data:size(1), a:batch_size('validate'))-- "Doesn't load all validation cases when max number specified"
			data, label =
				a:load_batch{no_lines = a:batch_size('test'),
				            load_row_fn = fake_loader,
				            offset = 0,
				            type = 'test'}
			assert.are.same(data:size(1), a:batch_size('test'))-- "Doesn't load all test cases when max number specified"
		end)
	end)
end)
