require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Loading data process", function()

	describe("for #CSV files",function()
		local df = Dataframe("./data/full.csv")

		it("Loads the shape of the file",function()
			assert.are.same(df:shape(),{rows=4, cols=4})
		end)

		it("Loads integer-only columns in integer column",function()
			for idx, val in ipairs({1, 2, 3, 4}) do
				assert.are.same(df:get_column('Col A'):get(idx), val)
			end
		end)

		it("Loads float-only columns in float column",function()
			for idx, val in ipairs({.2,.3,.4,.5}) do
				assert.are.same(df:get_column('Col B'):get(idx), val)
			end
		end)

		it("Loads string-only columns in string column",function()
			assert.are.same(df:get_column('Col D'), {'A','B',0/0,'D'})
		end)

		it("Loads mixed numerical columns in mixed column",function()
			assert.is.equal(df:get_column('Col C')[1], 0.1)
			assert.is.nan(df:get_column('Col C')[2])
			assert.is.equal(df:get_column('Col C')[3], 9999999999)
			assert.is.equal(df:get_column('Col C')[4], -222)
		end)

		it("Updates the columns names and escapes blank spaces",function()
			assert.are.same(df.column_order,{'Col A','Col B','Col C','Col D'})
			assert.has.no_error(function() df:get_column('Col A') end)
			assert.has.no_error(function() df:get_column('Col B') end)
			assert.has.no_error(function() df:get_column('Col C') end)
			assert.has.no_error(function() df:get_column('Col D') end)
		end)

		it("Updates the number of rows",function()
			assert.is.equal(df:size(1),4)
		end)

		it("Fills numerical missing values with NaN values",function()
			local _,tot_na = df:count_na()
			assert.is.equal(tot_na,2,"There are two missing vales in full.csv")
		end)

		it("Infers data schema",function()
			assert.are.same(df:get_schema(),
				{['Col A']='integer',
				['Col B']='double',
				['Col C']='double',
				['Col D']='string'})
		end)

		it("Keeps the original column order",function()
			assert.are.same(df.column_order,
				{[1] = "Col A",
				 [2] = "Col B",
				 [3] = "Col C",
				 [4] = "Col D"})
		end)
	end)

	describe("for lua tables",function()
		local df = Dataframe()

		it("Loads a simple table",function()
			df:load_table{data=Df_Dict({
				['first_column']={3,4,5},
				['second_column']={10,11,12}
			})}

			for idx,val in ipairs({3,4,5}) do
				assert.are.same(df:get_column("first_column")[idx], val)
			end
			for idx,val in ipairs({10,11,12}) do
				assert.are.same(df:get_column("second_column")[idx], val)
			end
		end)

		it("Generate an error if the column inserted are not the same size",function()
			assert.has.error(function()
				df:load_table{data=Df_Dict({
					['first_column']={3,5},
					['second_column']={10,11,12}
				})}
			end)
		end)

		it("Duplicate to all rows the only value given for a column",function()
			df:load_table{data=Df_Dict({
				['first_column']=3,
				['second_column']={10,11,12}
			})}

			assert.are.same(df:get_column("first_column"), {3,3,3})
			assert.are.same(df:get_column("second_column"), {10,11,12})
		end)

		it("Updates the columns names and escapes blank spaces",function()
			df:load_table{data=Df_Dict({
				['        first_column']={3,5,8},
				['second_column       ']={10,11,12}
			}),column_order=Df_Array('first_column     ','      second_column')}

			assert.are.same(df.column_order,{'first_column','second_column'})
			assert.has.no_error(function() df:get_column('first_column') end)
			assert.has.no_error(function() df:get_column('second_column') end)
		end)

		it("Updates the number of rows",function()
			df:load_table{data=Df_Dict({
				['first_column']={3,5,8},
				['second_column']={10,11,12}
			})}

			assert.is.equal(df:size(1),3)
		end)

		it("Fills numerical missing values with NaN values",function()
			df:load_table{data=Df_Dict{
				['first_column']={3,nil,8},
				['second_column']={10,11,12}
			}}

			local _, tot_na = df:count_na()
			assert.is.equal(tot_na, 1)
			assert.is.nan(df["$first_column"][2])
		end)

		it("Infers data schema",function()
			df:load_table{data=Df_Dict({
				['first_column']={3,9,8},
				['second_column']={10,11,12},
				['third_column']={'first','second','third'}
			})}
			assert.are.same(df:get_schema(),
				{['first_column']='integer',
				 ['second_column']='integer',
				 ['third_column']='string'})
		end)

		it("Keeps the provided column order",function()
			local a = Dataframe()

			local column_order = {
					[1] = 'firstColumn',
					[2] = 'secondColumn',
					[3] = 'thirdColumn'
			}

			local data = {
					['firstColumn']={1,2,3},
					['secondColumn']={"2","1","3"},
					['thirdColumn']={"2","a","3"}
			}

			a:load_table{data=Df_Dict(data), column_order = Df_Array(column_order)}

			assert.are.same(a.column_order, column_order)

			column_order[2] = nil
			assert.has.error(function() a:load_table{data=data, column_order = column_order} end)
		end)
	end)
end)
