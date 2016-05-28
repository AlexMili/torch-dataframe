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

describe("Indexing the dataframe", function()

	describe("Retrieving index",function()
		local df = Dataframe("./data/simple_short.csv")
		assert.are.same(df["$Col A"], df:get_column('Col A'))
		assert.are.same(df["$Col C"], df:get_column('Col C'))
	end)

	describe("Retrieving index",function()
		local df = Dataframe("./data/simple_short.csv")
		-- Wait until https://github.com/torch/torch7/issues/693 is resolved
		it("Retrieves a single row",function()
			local subset = df[1]
			table._dump(subset)
			assert.is.truthy(subset, "Fails to subset row")
			assert.are.same(subset["Col A"], 1)
			assert.are.same(subset["Col C"], 1000)
		end)

		it("Retrieves a several rows",function()
			local subset = df[Df_Array(1, 3)]
			assert.is.truthy(subset, "Fails to subset rows")
			assert.are.same(subset:size(1), 2)
			assert.are.same(subset:size(2), df:size(2))
		end)

		it("Retrieves a continuous set of rows",function()
			local subset = df["1:4"]
			assert.is.truthy(subset, "Fails to subset rows with continuous syntax")
			assert.are.same(subset:size(1), 4)
			assert.are.same(subset:size(2), df:size(2))
		end)
	end)

	describe("Set row via the newindex",function()
		local df = Dataframe()

		it("Set a single row",function()
		end)

		it("Set multiple rows",function()
		end)
	end)

	describe("Create a copy of the table",function()
		local df = Dataframe()

		it("Set a single row",function()
		end)

		it("Set multiple rows",function()
		end)
	end)

	it("Returns the size of the Dataframe",function()
		local a = Dataframe(Df_Dict({test = {1,nil,3, 4}, test2 = {5, 9, 99, 88}}))

		assert.is_true(torch.all(torch.eq(a:size(), torch.IntTensor({4, 2}))))
		assert.are.same(a:size(1), 4)
		assert.are.same(a:size(2), 2)
	end)

	describe("Gets the version number",function()
		local df = Dataframe()

		it("The torch.version goes to version()",function()
			assert.are.same(torch.version(df), df:version())
		end)

	end)

end)
