require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Loading dataframe and creaing adequate subsets", function()
	it("Raises an error if create_subsets hasn't be called",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")

		assert.has.error(function() a:reset_subsets() end)
	end)


	it("Initializes with random order for training and linear for the other",
		function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()

		assert.are.equal(a.subsets.samplers["train"], 'permutation', "Train init failed")
		assert.are.equal(a.subsets.samplers["validate"], 'linear', "Validate init failed")
		assert.are.equal(a.subsets.samplers["test"], 'linear', "Test init failed")
	end)

	it("Check that the initialized subset sizes are correct for default subsets",
		function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()

		assert.are.equal(a["/test"]:size(1) +
		                 a["/train"]:size(1) +
		                 a["/validate"]:size(1), a:size(1), "Number of cases don't match")
		-- as the full dataset must be used per definition one of the elements may not
		-- exactly be of expected length. We therefore have to look for sizes that
		-- are within no_of_subset - 1 from eachother
		assert.is_true(
			math.abs(a["/train"]:size(1) -
		          math.floor(a:size(1) * .7)) <= 2,
		          ("Train size fail - %d is not within 2 from expected %d"):
		          format(a["/train"]:size(1), math.floor(a:size(1) * .7)))
		assert.is_true(
			math.abs(a["/validate"]:size(1) -
		          math.floor(a:size(1) * .2)) <= 2,
		          ("Validate size fail - %d is not within 2 from expected %d"):
		          format(a["/validate"]:size(1), math.floor(a:size(1) * .2)))
		assert.is_true(
			math.abs(a["/test"]:size(1) -
		          math.floor(a:size(1) * .1)) <= 2,
		          ("Test size fail - %d is not within 2 from expected %d"):
		          format(a["/test"]:size(1), math.floor(a:size(1) * .1)))
	end)

	it("Check that the initialized subset is correct for a #single_subset",
		function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets(Df_Dict({core = 1}))

		assert.are.equal(a["/core"]:size(1), a:size(1), "Number of cases don't match")
		assert.are.equal(a.subsets.samplers["core"], 'permutation')
	end)

	it("Check selecting if #selecting_sampler works without label requirement",
		function()
		local a = Dataframe("./data/realistic_29_row_data.csv")

		a:create_subsets(Df_Dict({core = 1}), "uniform")
		assert.are.equal(a.subsets.samplers["core"], 'uniform')

		a:create_subsets(Df_Dict({a = .5, b = .5}), "uniform")
		assert.are.equal(a.subsets.samplers["a"], 'uniform')
		assert.are.equal(a.subsets.samplers["b"], 'uniform')

		a:create_subsets(Df_Dict({a = .5, b = .5}), Df_Dict({a = "uniform"}))
		assert.are.equal(a.subsets.samplers["a"], 'uniform')
		assert.are.equal(a.subsets.samplers["b"], 'permutation', "Not correcct for b")
	end)

	it("Check selecting if #selecting_sampler works with label requirement",
		function()
		local a = Dataframe("./data/realistic_29_row_data.csv")

		assert.has.error(function() a:create_subsets(Df_Dict({core = 1}), "label-uniform") end)

		a:create_subsets(Df_Dict({core = 1}),
		                 "label-uniform", "Gender")
		assert.are.equal(a.subsets.samplers["core"], 'label-uniform')

		a:create_subsets(Df_Dict({core = 1}),
		                 "label-distribution", "Gender",
		                 Df_Tbl({core = Df_Dict({distribution = Df_Dict({Male = 10, Female = 20})})}))
		assert.are.equal(a.subsets.samplers["core"], 'label-distribution')

	end)

	it("Check that the initialized subset sizes are correct for multiple #custom_subsets provided",
		function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()

		assert.are.equal(a["/test"]:size(1), #a["/test"])

		assert.are.equal(a["/test"]:size(1) +
		                 a["/train"]:size(1) +
		                 a["/validate"]:size(1), a:size(1), "Number of cases don't match")
		-- as the full dataset must be used per definition one of the elements may not
		-- exactly be of expected length. We therefore have to look for sizes that
		-- are within no_of_subset - 1 from eachother
		assert.is_true(
			math.abs(a["/train"]:size(1) -
		          math.floor(a:size(1) * .7)) <= 2,
		          ("Train size fail - %d is not within 2 from expected %d"):
		          format(a["/train"]:size(1), math.floor(a:size(1) * .7)))
		assert.is_true(
			math.abs(a["/validate"]:size(1) -
		          math.floor(a:size(1) * .2)) <= 2,
		          ("Validate size fail - %d is not within 2 from expected %d"):
		          format(a["/validate"]:size(1), math.floor(a:size(1) * .2)))
		assert.is_true(
			math.abs(a["/test"]:size(1) -
		          math.floor(a:size(1) * .1)) <= 2,
		          ("Test size fail - %d is not within 2 from expected %d"):
		          format(a["/test"]:size(1), math.floor(a:size(1) * .1)))
	end)
end)

describe("Test if we can get a batch with data and labels",function()
	local fake_loader = function(row) return torch.Tensor({1, 2}) end
	local a = Dataframe("./data/realistic_29_row_data.csv")
	a:create_subsets()

	it("Checkk that we get reasonable formatted data back",function()
		local data, label =
			a["/train"]:
			get_batch{no_lines = 5}:
			to_tensor{
				retriever = fake_loader
			}

		assert.is.equal(data:size(1), 5)-- "The data has invalid rows"
		assert.is.equal(data:size(2), 2)-- "The data has invalid columns"
		assert.is.equal(label:size(1), 5)--"The labels have invalid size"
	end)

	it("Check that we get all cases when running with the a sampler that requires resetting",
	function()
		a["/train"]:reset_sampler()

		local batch_size = 6
		local count = 0
		local batch, reset
		-- Run for over an epoch
		for i=1,(math.ceil(a["/train"]:size(1)/batch_size) + 1) do
			batch, reset =
				a["/train"]:get_batch{no_lines = batch_size}
			if (batch == nil) then
				break
			end
			count = count + batch:size(1)
		end

		assert.are.equal(count, a["/train"]:size(1))
		assert.is_true(reset, "The reset should be set to true after 1 epoch")

		a["/train"]:reset_sampler()
		batch, reset =
			a["/train"]:get_batch{no_lines = -1}

		assert.are.equal(batch:size(1), a["/train"]:size(1))
		assert.is_true(reset)
	end)

	describe("Test the alternative get_subset formats",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()

		it("Should be a Dataframe", function()
			local subset = a:get_subset("train", "Dataframe")
			assert.are.equal(torch.type(subset), "Dataframe")
		end)

		it("Should be a Batchframe", function()
			local subset = a:get_subset("train", "Batchframe")
			assert.are.equal(torch.type(subset), "Batchframe")
		end)
	end)

	describe("The get_subset should forward the information in #class_args",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		local class_args = Df_Tbl({
			batch_args = Df_Tbl({
				data = Df_Array("Weight"),
				label = Df_Array("Gender")
			})
		})
		a:create_subsets{
			class_args = class_args
		}
		local subset = a:get_subset('train')
		local batch = subset:get_batch(5)

		it("The class arguments should be stored within the subset property", function()
			assert.are.same(
				a.subsets.class_args,
				class_args.data
			)
		end)

		it("The batch arguments should be present in the subset object", function()
			assert.are.same(
				subset.batch_args,
				class_args.data.batch_args.data
			)
		end)

		it("The batch arguments from the subset object should be forwarded to the batch itself", function()
			local passed_args = class_args.data.batch_args.data
			assert.are.same(
				batch:get_data_retriever().data,
				passed_args.data.data
			)

			assert.are.same(
				batch:get_label_retriever().data,
				passed_args.label.data
			)
		end)

	end)
	-- TODO: Add tests for custom subset splits and samplers
end)
