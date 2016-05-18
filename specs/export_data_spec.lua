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

		describe("Column order functionality",function()
			local a = Dataframe()
			local data = {
					['firstColumn']={1,2,3},
					['secondColumn']={"Wow it's tricky","1,2","323."},
					['thirdColumn']={"\"","a\"a","3"}
			}

			it("Raises an error if the provided column order has non-continous indexes",function()
				c_order = {
						[1] = "firstColumn",
						[4] = "secondColumn",
						[3] = "thirdColumn"
				}

				assert.has.error(function() a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)} end)

				c_order = {
						[1] = "firstColumn",
						[3] = "thirdColumn"
				}

				assert.has.error(function() a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)} end)
			end)

			it("Keeps the column order when exporting",function()
				c_order = {
						[1] = "firstColumn",
						[2] = "secondColumn",
						[3] = "thirdColumn"
				}

				a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)}
				a:to_csv("./data/tricky_csv.csv")
				a:load_csv("./data/tricky_csv.csv")

				assert.are.same(a.column_order, c_order)

				os.remove("./data/tricky_csv.csv")
			end)
		end)
	end)

	describe("for torch tensors",function()

		it("Exports the Dataframe to a tensor",function()
			local a = Dataframe("./data/advanced_short.csv")
			-- Avoid NaN comparison (which always false)
			a:fill_all_na(2)
			a:to_tensor{filename="./data/tensor_test.th7"}

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

		it("Keeps the right order when saving to Tensor",function()
			local a = Dataframe()

			data = {
					['1st']={1,2,3},
					['2nd']={"A","B","323."},
					['3rd']=2.2
			}

			c_order = {
					[1] = "1st",
					[2] = "2nd",
					[3] = "3rd"
			}

			a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)}
			tnsr = a:to_tensor()

			assert.is.equal(tnsr:size(1),a:shape()["rows"])
			assert.is.equal(tnsr:size(2),a:shape()["cols"] - 1)

			sum = 0
			col_no = a:get_column_order{column_name='1st', as_tensor = true}
			for i=1,tnsr:size(1) do
				sum = math.abs(tnsr[i][col_no] - a:get_column('1st')[i])
			end

			assert.is_true(sum < 10^-5)

			sum = 0
			col_no = a:get_column_order{column_name='3rd', as_tensor = true}
			for i=1,tnsr:size(1) do
				sum = math.abs(tnsr[i][col_no] - a:get_column('3rd')[i])
			end

			assert.is_true(sum < 10^-5)
		end)
	end)
end)
