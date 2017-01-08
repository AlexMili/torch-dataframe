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

describe("Loading data process", function()

	describe("for #CSV files",function()
		local df = Dataframe(specs_dir.."/data/full.csv")

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

		it("Loads a CSV without header",function()
			local df_iris = Dataframe()
			df_iris:load_csv{path=specs_dir.."/data/iris-no-header.csv",header=false}
			assert.are.same(df_iris:shape(),{rows=150,cols=5})
			assert.are.same(df_iris.column_order,
				{[1] = "Column no. 1",
				 [2] = "Column no. 2",
				 [3] = "Column no. 3",
				 [4] = "Column no. 4",
				 [5] = "Column no. 5"})
		end)

		it("Loads in bulk mode",function()
			local csv_file = specs_dir.."/data/iris-label.csv"
			local df_bulk = Dataframe():bulk_load_csv{path=csv_file,nthreads=4}
			local df_classic = Dataframe():load_csv{path=csv_file}
			assert.is_true(df_bulk == df_classic)
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
