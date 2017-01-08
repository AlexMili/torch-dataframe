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

describe("Serialization", function()
	-- Do not use advanced_short since it has nan that are 0/0 ~= 0/0 == true
	local df = Dataframe()

	it("Deserializes a simple Dataframe object",function()
		df:load_csv{path = specs_dir.."/data/simple_short.csv", verbose = false}

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
		local a = Dataframe(specs_dir.."/data/realistic_29_row_data.csv")

		a:create_subsets()
		a:fill_all_na()

		torch.save("test.t7", a)
		c = torch.load("test.t7")

		os.remove("test.t7")

		assert.is.equal(torch.typename(c), "Dataframe")

		--tester:eq(a, c)
	end)
end)
