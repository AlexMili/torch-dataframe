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

describe("Main Dataframe functions", function()

	describe("Initialization",function()
		
		it("Sets all class variables to default values",function()
			local df = Dataframe()

			assert.are.same(df.dataset,{})
			assert.are.same(df.columns,{})
			assert.are.same(df.column_order,{})
			assert.are.same(df.categorical,{})
			assert.are.same(df.print,{no_rows = 10, max_col_width = 20})
			assert.are.same(df.schema,{})
			assert.is.equal(df.n_rows,0)
		end)

		it("Loads a CSV file if passed in argument",function()
			local df = Dataframe("./data/simple_short.csv")
			assert.are.same(df:shape(),{rows=4, cols=3})
		end)

		it("Loads a table if passed in argument",function()
			local df = Dataframe({
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
			})

			assert.are.same(df:get_column("first_column"), {3,4,5})
			assert.are.same(df:get_column("second_column"), {10,11,12})
		end)

		-- it("Deletes previous references in default variables",function()
		-- 	local df = Dataframe()
		-- 	df:load_table(['first_column']={2,3,4})
		-- 	df = :_clean()

		-- 	assert.are.same(df.dataset,{})
		-- 	assert.are.same(df.columns,{})
		-- 	assert.are.same(df.column_order,{})
		-- 	assert.are.same(df.categorical,{})
		-- 	assert.are.same(df.print,{no_rows = 10, max_col_width = 20})
		-- 	assert.are.same(df.schema,{})
		-- 	assert.is.equal(df.n_rows,0)
		-- end)

	end)
end)