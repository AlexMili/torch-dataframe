require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

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
		local df = Dataframe("./data/simple_short.csv")

		it("Set a single row",function()
			df[1]= {["Col A"] = 3231}
			assert.are.same(df[1]["Col A"], 3231)
		end)
	end)

	describe("Create a copy of the table",function()
		local df = Dataframe(Df_Dict({a={1,2,3}}))

		it("Check that it's a true copy and not a reference",function()
			local new_df = df:copy()
			new_df[1] = {a=2}
			assert.are.same(new_df:size(1), df:size(1))
			assert.are.same(new_df:size(2), df:size(2))
			assert.is_false(new_df[1].a == df[1].a)

			-- Check that htis matches also the shape
			assert.are.same(new_df:shape(), df:shape())
		end)
	end)

	it("Returns the size of the Dataframe",function()
		local a = Dataframe(Df_Dict({test = {1,nil,3, 4}, test2 = {5, 9, 99, 88}}))

		assert.are.same(a:size(1), 4)
		assert.are.same(a:size(2), 2)
	end)

	describe("Gets the version number",function()
		local df = Dataframe()

		it("The torch.version goes to version()",function()
			assert.are.same(torch.version(df), df:version())
		end)
	end)

	describe("Check the __len__",function()
		local df = Dataframe(Df_Dict{a={1,2,3,4,5}})

		it("__len__ should return the n_rows",function()
			assert.are.same(df:__len__(), df.n_rows)
		end)

		it("# should return the n_rows #skip_version_LUA51",function()
			assert.are.same(#df, df.n_rows)
		end)
	end)

	describe("Check the __eq__",function()
		it("Should be equal",function()
			local a = Dataframe(Df_Dict{a={1,2,3,4,5}})
			local b = Dataframe(Df_Dict{a={1,2,3,4,5}})

			assert.is_true(a == b)
			assert.is_false(a ~= b)

			a:set(2, Df_Dict{a=0/0})
			b:set(2, Df_Dict{a=0/0})
			assert.is_true(a == b, "Fails with nan values")
			assert.is_false(a ~= b, "Fails with nan values")
		end)

		it("Should not be equal",function()
			local a = Dataframe(Df_Dict{a={1,2,3,4,5}})
			local b = Dataframe(Df_Dict{a={1,3,4,5}})
			local c = Dataframe(Df_Dict{a={1,2,3,4,6}})
			local d = Dataframe(Df_Dict{a={1,2,3,0/0,6}})
			local e = Dataframe(Df_Dict{b={1,2,3,4,5}})
			local f = Dataframe(Df_Dict{a={1,2,3,4,5},
			                            b={1,2,3,4,5}})

			assert.is_true(a ~= b, "Fail to differ row length")
			assert.is_true(a ~= c, "Fail to differ values")
			assert.is_true(a ~= d, "Fail to differ nan")
			assert.is_true(a ~= e, "Fail to differ column names")
			assert.is_true(a ~= f, "Fail to differ number of columns")
		end)
	end)

end)
