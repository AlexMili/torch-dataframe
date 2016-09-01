require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Loading batch data", function()
	before_each(function()
		fake_loader_vec = function(row) return torch.Tensor({1, 2}) end
		fake_loader_mtrx = function(row) return torch.Tensor({
			{1, 2, 3, 4},
			{5, 6, 7, 8},
			{9, 10, 11, 12}
		}) end
		a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()
	end)

	describe("Batch with #load_data_fn", function()
		it("Basic test", function()
			local batch = a["/train"]:get_batch(5)

			local data, label =
				batch:to_tensor(fake_loader_vec)

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 2, "The data has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels have invalid size")
		end)

		it("Check with categorical and using the retriever named argument", function()
			a:as_categorical('Gender')
			local batch = a["/train"]:get_batch(5)


		local data, label, names =
			batch:to_tensor{retriever = fake_loader_vec}

			assert.are.equal(data:size(1), 5, "The data with gender has invalid rows")
			assert.are.equal(data:size(2), 2, "The data with gender has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels with gender have invalid size")
			assert.are.same(names, {'Gender', 'Weight'}, "Invalid names returned")
		end)
	end)

	describe("Batch with #load_label_fn", function()
		it("Basic test", function()
			local batch = a["/train"]:get_batch(5)

			local data, label =
				batch:to_tensor{
					data_columns = Df_Array(batch:get_numerical_colnames()),
					load_label_fn = fake_loader_vec}

			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels has invalid columns")
			assert.are.equal(data:size(1), 5, "The data have invalid size")
		end)

		it("Check with categorical", function()
			a:as_categorical('Gender')
			local batch = a["/train"]:get_batch(5)

			local data, label, names =
				batch:to_tensor{
					data_columns = Df_Array(batch:get_numerical_colnames()),
					load_label_fn = fake_loader_vec}

			assert.are.equal(label:size(1), 5, "The labels with gender has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels with gender has invalid columns")
			assert.are.equal(data:size(1), 5, "The data with gender have invalid size")
			assert.is_true(names == nil)
		end)
	end)

	describe("Batch with #load_label_and_data_fn", function()
		it("Basic test", function()
			local batch = a["/train"]:get_batch(5)

			local data, label =
				batch:to_tensor{load_data_fn = fake_loader_vec,
				                load_label_fn = fake_loader_mtrx}

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 2, "The data has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 3, "The labels has invalid columns")
			assert.are.equal(label:size(3), 4, "The labels has invalid 3rd dimension")
		end)

		it("Check with categorical", function()
			a:as_categorical('Gender')
			local batch = a["/train"]:get_batch(5)

			local data, label, names =
				batch:to_tensor{load_data_fn = fake_loader_vec,
												load_label_fn = fake_loader_mtrx}

			assert.are.equal(data:size(1), 5, "The data with gender has invalid rows")
			assert.are.equal(data:size(2), 2, "The data with gender has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels with gender has invalid rows")
			assert.are.equal(label:size(2), 3, "The labels with gender has invalid columns")
			assert.are.equal(label:size(3), 4, "The labels with gender has invalid 3rd dimension")
			assert.is_true(names == nil)
		end)
	end)

	describe("Batch with #no_loader_fn", function()
		it("Basic test", function()
			local batch = a["/train"]:get_batch(5)

			local data, label =
				batch:to_tensor(Df_Array(batch:get_numerical_colnames()),
				                Df_Array(batch:get_numerical_colnames()))

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 1, "The data has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 1, "The labels has invalid columns")
		end)

		it("Check with categorical", function()
			a:as_categorical('Gender')
			local batch = a["/train"]:get_batch(5)

			local data, label, names =
				batch:to_tensor(Df_Array(batch:get_numerical_colnames()),
				                Df_Array(batch:get_numerical_colnames()))

			assert.are.equal(data:size(1), 5, "The data with gender has invalid rows")
			assert.are.equal(data:size(2), 2, "The data with gender has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels with gender has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels with gender has invalid columns")
			assert.are.same(names, {"Gender", "Weight"})
		end)

		it("Check with different columns", function()
			a:as_categorical("Gender")
			local batch = a["/train"]:get_batch(5)
			local data, label =
				batch:to_tensor(Df_Array("Gender"),
				                Df_Array("Weight"))

			assert.are.not_same(data, label)
		end)
	end)

	describe("Test with default Batchframe #retrievers", function()
		it("Setting both data and retriever through the functions", function()
			local batch = a["/train"]:get_batch(5)
			batch:set_data_retriever(fake_loader_vec)
			batch:set_label_retriever(fake_loader_mtrx)

			local data, label =
				batch:to_tensor()

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 2, "The data has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 3, "The labels has invalid columns")
			assert.are.equal(label:size(3), 4, "The labels has invalid 3rd dimension")
		end)

		it("Setting only data function", function()
			local batch = a["/train"]:get_batch(5)
			batch:set_data_retriever(fake_loader_mtrx)

			local data, label =
				batch:to_tensor{retriever = fake_loader_vec}

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 3, "The data has invalid columns")
			assert.are.equal(data:size(3), 4, "The data has invalid 3rd dimension")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels has invalid columns")
		end)

		it("Setting only label function", function()
			local batch = a["/train"]:get_batch(5)
			batch:set_label_retriever(fake_loader_vec)

			local data, label =
				batch:to_tensor{retriever = fake_loader_mtrx}

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 3, "The data has invalid columns")
			assert.are.equal(data:size(3), 4, "The data has invalid 3rd dimension")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels has invalid columns")
		end)
	end)
end)

describe("#__init functionality", function()
	before_each(function()
		fake_loader_vec = function(row) return torch.Tensor({1, 2}) end
		fake_loader_mtrx = function(row) return torch.Tensor({
			{1, 2, 3, 4},
			{5, 6, 7, 8},
			{9, 10, 11, 12}
		}) end
	end)

	describe([[
		Should be able to load a dataset and using the get_batch with arguments set the
		default loader functions
	]], function()
		it("Both data and label retrievers using named arguments", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets()

			local batch = a["/train"]:get_batch(5, Df_Tbl({
				data = fake_loader_mtrx,
				label = fake_loader_vec
			}))

			local data, label =
				batch:to_tensor()

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 3, "The data has invalid columns")
			assert.are.equal(data:size(3), 4, "The data has invalid 3rd dimension")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels has invalid columns")
		end)

		it("Both data and label retrievers using unnamed arguments", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets()

			local batch = a["/train"]:get_batch(5, Df_Tbl({
				fake_loader_mtrx,
				fake_loader_vec
			}))

			local data, label =
				batch:to_tensor()

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 3, "The data has invalid columns")
			assert.are.equal(data:size(3), 4, "The data has invalid 3rd dimension")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels has invalid columns")
		end)

		it("Only data retriever is set and label is a column name", function()
			a = Dataframe("./data/realistic_29_row_data.csv")
			a:create_subsets()

			local batch = a["/train"]:get_batch(5, Df_Tbl({
				data = fake_loader_mtrx,
			}))

			local data, label =
				batch:to_tensor(Df_Array("Weight"))

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 3, "The data has invalid columns")
			assert.are.equal(data:size(3), 4, "The data has invalid 3rd dimension")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 1, "The labels has invalid columns")
		end)

		it("Only data retriever is set and label is a function #test", function()
			b = Dataframe("./data/realistic_29_row_data.csv")
			b:create_subsets()

			local bbatch = b["/train"]:get_batch(5, Df_Tbl({
				data = fake_loader_mtrx
			}))

			local data, label =
				bbatch:to_tensor(fake_loader_vec)

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 3, "The data has invalid columns")
			assert.are.equal(data:size(3), 4, "The data has invalid 3rd dimension")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels has invalid columns")
		end)
	end)

end)
