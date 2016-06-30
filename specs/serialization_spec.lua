require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Serialization", function()
	-- Do not use advanced_short since it has nan that are 0/0 ~= 0/0 == true
	local df = Dataframe()

	it("Deserializes a simple Dataframe object",function()
		df:load_csv{path = "./data/simple_short.csv", verbose = false}

		b = torch.serialize(df)
		c = torch.deserialize(b)

		assert.is.equal(torch.typename(c), "Dataframe")

		--tester:eq(df, c)
	end)

	it("Saves then load a Dataframe object",function()
		torch.save("test.t7", df)
		c = torch.load("test.t7")

		os.remove("test.t7")

		assert.is.equal(torch.typename(c), "Dataframe")

		--tester:eq(df, c)
	end)

	it("Saves with init",function()
		local a = Dataframe("./data/realistic_29_row_data.csv")

		a:create_subsets()
		a:fill_all_na()

		torch.save("test.t7", a)
		c = torch.load("test.t7")

		os.remove("test.t7")

		assert.is.equal(torch.typename(c), "Dataframe")

		--tester:eq(a, c)
	end)
end)
