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
		assert.near(a["/train"]:size(1),
		            math.floor(a:size(1) * .7),
                2)

		assert.near(a["/validate"]:size(1),
		            math.floor(a:size(1) * .2),
                2)

		assert.near(a["/test"]:size(1),
		            math.floor(a:size(1) * .1),
                2)
	end)

	it("Check that the initialized subset is correct for a #single_subset",
		function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets(Df_Dict({core = 1}))

		assert.are.equal(a["/core"]:size(1), a:size(1), "Number of cases don't match")
		assert.are.equal(a["/core"]:size(2), a:size(2), "Number of columns don't match")
		assert.are.same(a["/core"]:shape(), a:shape(), "Shapes don't match")
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

		assert.are.equal(a["/test"]:size(1), a["/test"]:size())

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

describe("Test if we can get a batch with data and labels.",function()
	describe("Basic batch retrieving and resetting", function()
		local fake_loader = function(row) return torch.Tensor({1, 2}) end
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()

		it("Check that we get reasonable formatted data back #12",function()
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
	end)

	describe("Some of the samplers should give a reset indicator even if we haven't drawn n+1 examples.",
	function()
		a = Dataframe(Df_Dict{idx = {1,2,3,4}})
		it("linear", function()
			a:create_subsets{
				subsets = Df_Dict{core=1},
				sampler = "linear"
			}
			local batch, reset  = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_true(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.same(batch, nil)
			assert.is_true(reset)
		end)

		it("permutation", function()
			a:create_subsets{
				subsets = Df_Dict{core=1},
				sampler = "permutation"
			}
			local batch, reset  = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_true(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.same(batch, nil)
			assert.is_true(reset)
		end)

		it("ordered", function()
			a:create_subsets{
				subsets = Df_Dict{core=1},
				sampler = "ordered"
			}
			local batch, reset  = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_true(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.same(batch, nil)
			assert.is_true(reset)
		end)
	end)

	describe("Some of the samplers should never indicate that a reset is needed",
	function()
		a = Dataframe(Df_Dict{
				idx = {1, 2, 3, 4},
				label = {"A", "A", "B", "B"}
		})

		it("uniform", function()
			a:create_subsets{
				subsets = Df_Dict{core=1},
				sampler = "uniform"
			}
			local batch, reset  = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)
		end)

		it("label-uniform", function()
			a:create_subsets{
				subsets = Df_Dict{core=1},
				sampler = "label-uniform",
				label_column = "label"
			}
			local batch, reset  = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)
		end)

		it("label-distribution", function()
			a:create_subsets{
				subsets = Df_Dict{core=1},
				sampler = "label-distribution",
				label_column = "label",
				sampler_args = Df_Tbl{
					core =
					Df_Dict{
						distribution = Df_Dict{
							A=.5,
							B=.5
						}
					}
				}
			}
			local batch, reset  = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)
		end)

		it("label-permutation", function()
			a:create_subsets{
				subsets = Df_Dict{core=1},
				sampler = "label-permutation",
				label_column = "label"
			}

			local batch, reset  = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)

			batch, reset = a["/core"]:get_batch(2)
			assert.is_falsy(reset)
			assert.same(batch:size(1), 2)
		end)
	end)

	describe("Test the alternative get_subset formats",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()

		it("Should be a Dataframe #11", function()
			local subset = a:get_subset("train", "Dataframe")
			assert.are.same(torch.type(subset), "Dataframe")
		end)

		it("Should be a Batchframe", function()
			local subset = a:get_subset("train", "Batchframe")
			assert.are.same(torch.type(subset), "Batchframe")
		end)
	end)


	describe("Investigate #labels",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets{
			subsets = Df_Dict{a = .5, b = .5},
			samplers = Df_Dict{
				["linear"] = "a",
				["label permutation"] = "b"
			},
			label_column = "Gender"
		}

		it("Check that the labels in the subset match the original",
			function()
				for i=1,a["/a"]:size() do
					local subset_row = a["/a"]:get_row(i)
					local org_row = a:get_row(subset_row.indexes)
					assert.are.same(
					subset_row.labels,
					org_row.Gender,
					"Failed matching row:\n " .. tostring(subset_row.labels) ..
					"\n to the original:\n " .. tostring(org_row.Gender)
					)
				end
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

	describe("The create_subsets should work wit #data_retriever and #label_retriever just as for class_args",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets{
			data_retriever = Df_Array("Weight"),
			label_retriever = Df_Array("Gender")
		}
		local subset = a:get_subset('train')
		local batch = subset:get_batch(5)

		it("The class arguments should be stored within the subset property", function()
			assert.are.same(
				a.subsets.class_args.batch_args.data.data.data,
				{"Weight"}
			)
		end)

		it("The batch arguments should be present in the subset object", function()
			assert.are.same(
				subset.batch_args.label.data,
				{"Gender"}
			)
			assert.are.same(
				subset.batch_args.data.data,
				{"Weight"}
			)
		end)

		it("The batch should have the correct functions", function()
			assert.are.same(
				batch:get_label_retriever().data,
				{"Gender"}
			)
			assert.are.same(
				batch:get_data_retriever().data,
				{"Weight"}
			)
		end)
	end)

	describe("The set #custom_retrievers for subsets",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets{
			data_retriever = Df_Array("Weight"),
			label_retriever = Df_Array("Gender")
		}
		local subset = a:get_subset('train')
		subset:set_data_retriever(Df_Array("Gender"))
		subset:set_label_retriever(Df_Array("Weight"))

		local batch = subset:get_batch(5)

		it("The class arguments should be stored within the subset property", function()
			assert.are.same(
				a.subsets.class_args.batch_args.data.data.data,
				{"Gender"}
			)
		end)

		it("The batch arguments should be present in the subset object", function()
			assert.are.same(
				subset.batch_args.label.data,
				{"Weight"}
			)
			assert.are.same(
				subset.batch_args.data.data,
				{"Gender"}
			)
		end)

		it("The batch should have the correct retrievers", function()
			assert.are.same(
				batch:get_label_retriever().data,
				{"Weight"}
			)
			assert.are.same(
				batch:get_data_retriever().data,
				{"Gender"}
			)
		end)
	end)

	-- TODO: Add tests for custom subset splits and samplers
end)

describe()
