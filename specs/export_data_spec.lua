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

			a:to_csv("./data/copy_of_full.csv")
			local b = Dataframe()
			b:load_csv("./data/copy_of_full.csv")

			for k,v in pairs(a.dataset) do
				-- Avoid errors on NaN values
				a:fill_na(k,8)
				b:fill_na(k,8)

				assert.are.same(a:get_column(k), b:get_column(k))
			end

			os.remove("./data/copy_of_full.csv")
		end)
	end)

	describe("for torch tensors",function()

		it("Exports the Dataframe to a tensor",function()
			local a = Dataframe("./data/advanced_short.csv")
			-- Avoid NaN comparison (which always false)
			a:fill_all_na(2)
			a:to_tensor("./data/tensor_test.th7")

			tnsr = a:to_tensor()
			tnsr2 = torch.load('./data/tensor_test.th7')

			assert.is_true(torch.all(tnsr:eq(tnsr2)))

			assert.is.equal(tnsr:size(1),a:shape()["rows"])
			assert.is.equal(tnsr:size(2),table.exact_length(a:get_numerical_colnames()))

			sum = 0
			col_no = a:get_column_order('Col A')

			for i=1,tnsr:size(1) do
				sum = math.abs(tnsr[i][col_no] - a:get_column('Col A')[i])
			end

			assert.is_true(sum < 10^-5)
			os.remove("./data/tensor_test.th7")
		end)
	end)
end)
