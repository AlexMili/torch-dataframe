require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Dataframe class", function()

	it("Counts missing values", function()
		local a = Dataframe("./data/full.csv")

		assert.are.same(a:count_na{as_dataframe = false}, {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1, ["Col D"]=1})
	end)

	it("Fills missing value(s) for a given column(s)",function()
		local a = Dataframe("./data/advanced_short.csv")

		assert.has.error(function() a:fill_na("Random column") end)

		a:fill_na("Col A", 1)
		assert.are.same(a:count_na{as_dataframe = false}, {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1})

		a:fill_na("Col C", 1)
		assert.are.same(a:count_na{as_dataframe = false}, {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})

		assert.are.same(a:get_column("Col C"), {8, 1, 9})
	end)

	it("Fills all Dataframe's missing values", function()
		local a = Dataframe("./data/advanced_short.csv")

		a.dataset['Col A'][3] = nil

		local cnt, tot = a:count_na{as_dataframe = false}
		assert.are.same(cnt, {["Col A"]= 1, ["Col B"]= 0, ["Col C"]=1})
		assert.are.same(tot, 2)


		a:fill_all_na(-1)

		assert.are.same(a:count_na{as_dataframe = false}, {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})
		assert.are.same(a:get_column('Col A'), {1,2,-1})
	end)

	it("The count_na should #1 return a Dataframe by default", function()
		local a = Dataframe("./data/advanced_short.csv")

		local ret = a:count_na()

		assert.are.same(torch.type(ret), "Dataframe")

		assert.are.same(ret:size(), 3, "3 columns should render 3 rows")
	end)

end)
