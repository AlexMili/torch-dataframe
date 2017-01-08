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

describe("Dataframe class", function()

	it("Counts missing values", function()
		local a = Dataframe(specs_dir.."/data/full.csv")

		assert.are.same(a:count_na{as_dataframe = false}, {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1, ["Col D"]=1})
	end)

	it("Fills missing value(s) for a given column(s)",function()
		local a = Dataframe(specs_dir.."/data/advanced_short.csv")

		assert.has.error(function() a:fill_na("Random column") end)

		a:fill_na("Col A", 1)
		assert.are.same(a:count_na{as_dataframe = false},
    {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1})

		a:fill_na("Col C", 1)
		assert.are.same(a:count_na{as_dataframe = false}, {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})

		assert.are.same(a:get_column("Col C"), {8, 1, 9})
	end)

	it("Fills all Dataframe's missing values", function()
		local a = Dataframe(specs_dir.."/data/advanced_short.csv")

		a.dataset['Col A'][3] = nil

		local cnt, tot = a:count_na{as_dataframe = false}
		assert.are.same(cnt, {["Col A"]= 1, ["Col B"]= 0, ["Col C"]=1})
		assert.are.same(tot, 2)


		a:fill_all_na(-1)

		assert.are.same(a:count_na{as_dataframe = false}, {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})
		assert.are.same(a:get_column('Col A'), {1,2,-1})
	end)

	it("The count_na should #1 return a Dataframe by default", function()
		local a = Dataframe(specs_dir.."/data/advanced_short.csv")

		local ret = a:count_na()

		assert.are.same(torch.type(ret), "Dataframe")

		assert.are.same(ret:size(), 3, "3 columns should render 3 rows")
	end)

end)
