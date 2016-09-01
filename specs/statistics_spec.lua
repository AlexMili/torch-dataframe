require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Usual statistics functions", function()
	local dfs = Dataframe("./data/simple_short.csv")
	local df = Dataframe("./data/advanced_short.csv")

	describe("Value counting",function()

		it("Counts integer occurrences",function()
			assert.are.same(df:value_counts{column_name='Col A', as_dataframe=false},
				{[1] = 1, [2] = 1, [3] = 1})
		end)

		it("Counts string occurrences",function()
			assert.are.same(df:value_counts{column_name='Col B', as_dataframe=false}, {A=1, B=2})
		end)

		it("Doesn't count missing values",function()
			assert.are.same(df:value_counts{column_name='Col C', as_dataframe=false}, {[8]=1, [9]=1})
		end)

		it("Count missing values when specified",function()
			assert.are.same(df:value_counts{column_name='Col C', dropna=false, as_dataframe=false},
				{[8]=1, [9]=1, ["_missing_"] = 1})
		end)

		it("Count integer frequencies when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col A',normalize = true, as_dataframe=false},
				{[1] = 1/3, [2] = 1/3, [3] = 1/3})
		end)

		it("Count string frequencies when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col B',normalize = true, as_dataframe=false},
				{A = 1/3, B = 2/3})
		end)

		it("Count frequencies avoiding missing values when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col C',normalize = true, as_dataframe=false},
				{[8]=0.5, [9]=0.5})
		end)

		it("Count frequencies with missing values when 'normalize' argument is set to true",function()
			assert.are.same(df:value_counts{column_name ='Col C',normalize = true,dropna=false, as_dataframe=false},
				{[8]=1/3, [9]=1/3, ["_missing_"] = 1/3})
		end)

		it("Count all columns values",function()
			assert.are.same(df:value_counts{as_dataframe=false},{['Col C'] = {[8]=1, [9]=1},
		         ['Col A'] = {[1] = 1, [2] = 1, [3] = 1}})
		end)

		it("Count all colmns  values with missing values",function()
			assert.are.same(
				df:value_counts{dropna=false, as_dataframe=false},
				{
					['Col C'] = {[8]=1, [9]=1, ["_missing_"] = 1},
					['Col A'] = {[1] = 1, [2] = 1, [3] = 1, ["_missing_"] = 0}
				})
		end)

		it("The missing value counts shouldn't be affected by categorical status",
			function()
			local df = Dataframe("./data/advanced_short.csv")
			df:as_categorical('Col C')
			assert.are.same(df:value_counts{column_name='Col C', as_dataframe=false},
			                {[8]=1, [9]=1})

			df:as_string('Col C')
			assert.are.same(df:value_counts{column_name='Col C', as_dataframe=false},
			                {[8]=1, [9]=1})

			df:as_categorical('Col C')
			df:fill_na('Col C', 0)
			assert.are.same(df:value_counts{column_name='Col C', as_dataframe=false},
			                {[8]=1, [9]=1, __nan__=1})
		end)
	end)


	describe("Mode functionality",function()

		it("Get the mode for a specific column",function()
			local df = Dataframe("./data/advanced_short.csv")
			assert.are.same(df:get_mode{column_name ='Col A', normalize = false, as_dataframe = false},
		                   {[1] = 1, [2] = 1, [3] = 1})
		end)

		it("Check that mode with dataframe",function()
			local df = Dataframe("./data/advanced_short.csv")
			local mode_df = df:get_mode{column_name ='Col A', normalize = false, as_dataframe = true}
			assert.are.same(mode_df:get_column('key'), {1, 2, 3})
			assert.are.same(mode_df:get_column('value'), {1, 1, 1})
			assert.are.same(df:get_mode():size(1), 3 + 0 + 2, "The mode for Col B shouldn't appear")
		end)

		it("Get the mode for a specific column with 'normalize' option",function()
			local df = Dataframe("./data/advanced_short.csv")
			assert.are.same(df:get_mode{column_name ='Col A', normalize = true, as_dataframe = false},
			                   {[1] = 1/3, [2] = 1/3, [3] = 1/3})
			assert.are.same(df:get_mode{column_name ='Col B', normalize = true, as_dataframe = false},
			                   {B = 2/3})
		end)

		it("Get mode for multiple columns",function()
			local df = Dataframe{
				data=Df_Dict{
					['A']={3,3,2},
					['B']={10,11,12}
				}
			}
			assert.are.same(df:get_mode{normalize = true, as_dataframe = false},
			                {A ={[3] = 2/3},
			                 B ={[10] = 1/3, [11] = 1/3, [12] = 1/3}})
		end)

		it("Get mode for categorical #1 columns",function()
			local df = Dataframe{
				data=Df_Dict{
					['A']={3,3,2},
					['B']={10,11,12},
					['C'] = {"a","a","a"}
				}
			}
			df:as_categorical('C')
			local mode = df:get_mode{normalize = true, as_dataframe = true}
			assert.are.same(mode:shape(), {rows=5, cols=3})
			assert.are.same(mode:where('Column', 'C')["$key"], {"a"})
		end)
	end)

	describe("Max value",function()
		df = Dataframe("./data/advanced_short.csv")
		it("Retrieves the max value of all numerical columns",function()
			assert.are.same(df:get_max_value{as_dataframe = false}, {3, 9})
			assert.are.same(dfs:get_max_value{as_dataframe = false}, {4, .5, 9999999999})

			df:as_categorical('Col B')
			assert.are.same(df:get_max_value{as_dataframe = false}, {3, 2, 9})

			df:as_categorical('Col C')
			assert.are.same(df:get_max_value{as_dataframe = false}, {3, 2, 2})
		end)

		it("Retrieves the max value of a specific column",function()
			assert.is.equal(df:get_max_value('Col A'), 3)
			assert.is.equal(df:get_max_value('Col B'), 2)
			assert.is.equal(df:get_max_value('Col C'), 2)

			assert.is.equal(dfs:get_max_value('Col C'), 9999999999)
		end)
	end)

	describe("Min value",function()
		df = Dataframe("./data/advanced_short.csv")

		it("Retrieves the min value of all numerical columns",function()

			assert.are.same(df:get_min_value{as_dataframe = false}, {1, 8})
			assert.are.same(dfs:get_min_value{as_dataframe = false}, {1, .2, -222})

			df:as_categorical('Col B')
			assert.are.same(df:get_min_value{as_dataframe = false}, {1, 1, 8})

			df:as_categorical('Col C')
			assert.are.same(df:get_min_value{as_dataframe = false}, {1, 1, 1})
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
