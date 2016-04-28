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

describe("Usual statistics functions", function()
	local dfs = Dataframe("./data/simple_short.csv")
	local df = Dataframe("./data/advanced_short.csv")

	describe("Value counting",function()

		it("Counts integer occurrences",function()
			assert.are.same(df:value_counts('Col A'),
				{[1] = 1, [2] = 1, [3] = 1})
		end)

		it("Counts string occurrences",function()
			assert.are.same(df:value_counts('Col B'), {A=1, B=2})
		end)

		it("Doesn't count missing values",function()
			assert.are.same(df:value_counts('Col C'), {[8]=1, [9]=1})
		end)

		it("Count missing values when specified",function()
			assert.are.same(df:value_counts{column_name='Col C',dropna=false},
				{[8]=1, [9]=1, ["_missing_"] = 1})
		end)

		it("Count integer frequencies when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col A',normalize = true},
				{[1] = 1/3, [2] = 1/3, [3] = 1/3})
		end)

		it("Count string frequencies when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col B',normalize = true},
				{A = 1/3, B = 2/3})
		end)

		it("Count frequencies avoiding missing values when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col C',normalize = true},
				{[8]=0.5, [9]=0.5})
		end)

		it("Count frequencies with missing values when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col C',normalize = true,dropna=false},
				{[8]=1/3, [9]=1/3, ["_missing_"] = 1/3})
		end)

		it("Count all columns values",function()
			assert.are.same(df:value_counts(),{['Col C'] = {[8]=1, [9]=1},
		         ['Col A'] = {[1] = 1, [2] = 1, [3] = 1}})
		end)

		it("Count all colmns values with missing values",function()
			assert.are.same(df:value_counts{dropna=false},
		         {['Col C'] = {[8]=1, [9]=1, ["_missing_"] = 1},
		         ['Col A'] = {[1] = 1, [2] = 1, [3] = 1, ["_missing_"] = 0}})
		end)
	end)


	describe("Mode functionality",function()
		local df = Dataframe("./data/advanced_short.csv")

		it("Get the mode for a specific column",function()
			assert.are.same(df:get_mode{column_name ='Col A', normalize = false},
		                   {[1] = 1, [2] = 1, [3] = 1})
		end)

		it("Get the mode for a specific column with 'normalize' option",function()
			assert.are.same(df:get_mode{column_name ='Col A', normalize = true},
			                   {[1] = 1/3, [2] = 1/3, [3] = 1/3})
			assert.are.same(df:get_mode{column_name ='Col B', normalize = true},
			                   {B = 2/3})
		end)

		it("Get mode for multiple columns",function()
			df:load_table{data={['A']={3,3,2},['B']={10,11,12}}}
			assert.are.same(df:get_mode{normalize = true},
			                  {A ={[3] = 2/3},
			                   B ={[10] = 1/3, [11] = 1/3, [12] = 1/3}})
		end)
	end)

	describe("Max value",function()
		it("Retrieves the max value of all numerical columns",function()
			df = Dataframe("./data/advanced_short.csv")

			assert.are.same(df:get_max_value(), {3, 9})
			assert.are.same(dfs:get_max_value(), {4, .5, 9999999999})

			df:as_categorical('Col B')
			assert.are.same(df:get_max_value(), {3, 2, 9})

			df:as_categorical('Col C')
			assert.are.same(df:get_max_value(), {3, 2, 2})
		end)

		it("Retrieves the max value of a specific column",function()
			assert.is.equal(df:get_max_value('Col A'), 3)
			assert.is.equal(df:get_max_value('Col B'), 2)
			assert.is.equal(df:get_max_value('Col C'), 2)

			assert.is.equal(dfs:get_max_value('Col C'), 9999999999)
		end)
	end)

	describe("Min value",function()
		it("Retrieves the min value of all numerical columns",function()
			df = Dataframe("./data/advanced_short.csv")

			assert.are.same(df:get_min_value(), {1, 8})
			assert.are.same(dfs:get_min_value(), {1, .2, -222})

			df:as_categorical('Col B')
			assert.are.same(df:get_min_value(), {1, 1, 8})

			df:as_categorical('Col C')
			assert.are.same(df:get_min_value(), {1, 1, 1})
		end)

		it("Retrieves the min value of a specific column",function()
			assert.is.equal(df:get_min_value('Col A'), 1)
			assert.is.equal(df:get_min_value('Col B'), 1)
			assert.is.equal(df:get_min_value('Col C'), 1)

			df:fill_all_na()
			assert.is.equal(df:get_min_value('Col C'), 0)
		end)
		-- tester:eq(a:to_tensor()[{2,3}], 0)
	end)
end)