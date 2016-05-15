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

describe("Dataframe class", function()

	it("Counts missing values", function()
		local a = Dataframe("./data/full.csv")

		assert.are.same(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1, ["Col D"]=1})
	end)

	it("Fills missing value(s) for a given column(s)",function()
		local a = Dataframe("./data/advanced_short.csv")

		assert.has.error(function() a:fill_na("Random column") end)

		a:fill_na("Col A", 1)
		assert.are.same(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1})

		a:fill_na("Col C", 1)
		assert.are.same(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})
		
		assert.are.same(a:get_column("Col C"), {8, 1, 9})
	end)

	it("Fills all Dataframe's missing values", function()
		local a = Dataframe("./data/advanced_short.csv")

		a.dataset['Col A'][3] = nil
		
		assert.are.same(a:count_na(), {["Col A"]= 1, ["Col B"]= 0, ["Col C"]=1})
		
		a:fill_all_na(-1)

		assert.are.same(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})
		assert.are.same(a:get_column('Col A'), {1,2,-1})
	end)
end)