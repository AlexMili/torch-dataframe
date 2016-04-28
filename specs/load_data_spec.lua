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

describe("Loading data process", function()

	describe("Simple CSV data loading",function()
		local df = Dataframe()
		df:load_csv{path = "./data/simple_short.csv", verbose = false}

		it("Has 4 rows and 3 columns",function()
			assert.are.same(df:shape(),{rows=4, cols=3})
		end)

		it("Loads integer-only columns in integer-table",function()
			assert.are.same(df:get_column('Col A'), {1, 2, 3, 4})
		end)

		it("Loads float-only columns in float-table",function()
			assert.are.same(df:get_column('Col B'), {.2,.3,.4,.5})
		end)

		it("Loads mixed numerical columns in mixed-table",function()
			assert.is.equal(df:get_column('Col C')[1], 1000)
			assert.is.equal(df:get_column('Col C')[2], 0.1)
			assert.is.equal(df:get_column('Col C')[3], 9999999999)
			assert.is.equal(df:get_column('Col C')[4], -222)
		end)
	end)

	describe("Table data loading",function()
		local df = Dataframe()

		it("Loads the table according to its types and length",function()
			df:load_table{data={
				['first_column']={
					3,
					4,
					5
				},
				['second_column']={
					10,
					11,
					12
				}
			}}

			assert.are.same(df:get_column("first_column"), {3,4,5})
			assert.are.same(df:get_column("second_column"), {10,11,12})
		end)

		it("Generate an error if the column inserted are not the same size",function()
			assert.has.error(function()
				df:load_table{data={
					['first_column']={
						3,
						4,
						5
					},
					['second_column']={
						10,
						11
					}
				}}
			end)
		end)

		it("Duplicate to all rows the only value given for a column",function()
			df:load_table{data={
				['first_column']=3,
				['second_column']={
					10,
					11,
					12
				}
			}}

			assert.are.same(df:get_column("first_column"), {3,3,3})
			assert.are.same(df:get_column("second_column"), {10,11,12})
		end)
	end)
end)