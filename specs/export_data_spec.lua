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

describe("Exporting data process", function()

	describe("for CSV files",function()
		it("Exports the Dataframe to a CSV file",function()
			local a = Dataframe("./data/full.csv")

			a:to_csv{path = "./data/copy_of_full.csv", verbose = false}
			local b = Dataframe()
			b:load_csv{path = "./data/copy_of_full.csv", verbose = false}

			for k,v in pairs(a.dataset) do
				assert.are.same(a:get_column(k), b:get_column(k))
			end

			os.remove("./data/copy_of_full.csv")
		end)
	end)

	describe("for torch tensors",function()

		it("Exports the Dataframe to a tensor",function()
			local a = Dataframe("./data/advanced_short.csv")

			tnsr = a:to_tensor()
			assert.is.equal(tnsr:size(1),a:shape()["rows"])
			assert.is.equal(tnsr:size(2),a:shape()["cols"]-1)
			sum = 0
			col_no = a:get_column_no('Col A')

			for i=1,tnsr:size(1) do
				sum = math.abs(tnsr[i][col_no] - a:get_column('Col A')[i])
			end
			
			assert.is_true(sum < 10^-5)
		end)
	end)
end)