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
		fake_loader = function(row) return torch.Tensor({1, 2}) end
		a = Dataframe("./data/realistic_29_row_data.csv")
		a:create_subsets()
	end)

	describe("Batch with #load_data_fn", function()
		it("Basic test", function()
			local batch = a["/train"]:get_batch(5)

			local data, label =
				batch:to_tensor{load_data_fn = fake_loader}

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 2, "The data has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels have invalid size")
		end)

		it("Check with categorical", function()
			a:as_categorical('Gender')
			local batch = a["/train"]:get_batch(5)


		local data, label, names =
			batch:to_tensor{load_data_fn = fake_loader}

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
					load_label_fn = fake_loader}

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
					load_label_fn = fake_loader}

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
				batch:to_tensor{load_data_fn = fake_loader,
				                load_label_fn = fake_loader}

			assert.are.equal(data:size(1), 5, "The data has invalid rows")
			assert.are.equal(data:size(2), 2, "The data has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels has invalid columns")
		end)

		it("Check with categorical", function()
			a:as_categorical('Gender')
			local batch = a["/train"]:get_batch(5)

			local data, label, names =
				batch:to_tensor{load_data_fn = fake_loader,
												load_label_fn = fake_loader}

			assert.are.equal(data:size(1), 5, "The data with gender has invalid rows")
			assert.are.equal(data:size(2), 2, "The data with gender has invalid columns")
			assert.are.equal(label:size(1), 5, "The labels with gender has invalid rows")
			assert.are.equal(label:size(2), 2, "The labels with gender has invalid columns")
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

			assert.is_false(torch.all(torch.eq(data, label)))
		end)
	end)
end)
