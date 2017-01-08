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

describe("Column operations", function()

	describe("Drop functionality",function()

		it("Allows to remove an entire column", function()
			local a = Dataframe(specs_dir.."/data/simple_short.csv")

			a:drop('Col A')
			assert.is_true(not a:has_column('Col A'))
			assert.is_true(a:has_column('Col B'))
			assert.is_true(a:has_column('Col C'))
			assert.are.same(a:shape(), {rows=4, cols=2})-- "The simple_short.csv is 4x3 after drop should be 4x2"
			-- Should cause an error
			assert.has_error(function() a:drop('Col A') end)
		end)

		it("Allows to remove multiple columns", function()
			local a = Dataframe(specs_dir.."/data/simple_short.csv")

			a:drop('Col A')
			assert.is_true(not a:has_column('Col A'))
			assert.is_true(a:has_column('Col B'))
			assert.is_true(a:has_column('Col C'))
			assert.are.same(a:shape(), {rows=4, cols=2})-- "The simple_short.csv is 4x3 after drop should be 4x2"
			-- Should cause an error
			assert.has_error(function() a:drop('Col A') end)

			-- Drop second column
			a:drop('Col B')
			assert.is_true(not a:has_column('Col A'))
			assert.is_true(not a:has_column('Col B'))
			assert.is_true(a:has_column('Col C'))
			assert.are.same(a:shape(), {rows=4, cols=1})-- "The simple_short.csv is 4x3 after drop should be 4x1"
		end)

		it("Resets the Dataframe when all columns are dropped",function()
			local a = Dataframe(specs_dir.."/data/simple_short.csv")
			a:drop('Col A')
			a:drop('Col B')
			-- All are dropped
			a:drop('Col C')
			assert.are.same(a.dataset, {})-- "All columns are dropped"
			assert.are.same(a.column_order,{})
			assert.are.same(a.tostring_defaults,
			                {no_rows = 10,
			                min_col_width = 7,
			                max_table_width = 80})
			assert.is.equal(a:size(1),0)
		end)
	end)

	describe("Add functionality",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		it("Raises an error if the column is already existing",function()
			assert.has_error(function() a:add_column('Col A') end)
		end)

		it("Allows to use a table as the default value",function()
			d_col = {0,1,2,3}
			a:add_column('Col D', Dataseries(Df_Array(d_col)))
			assert.are.same(a:get_column('Col D'), d_col)-- "Col D isn't the expected value"
			assert.are.same(a:shape(), {rows=4, cols=4})-- "The simple_short.csv is 4x3 after add should be 4x4"
		end)

		it("Fills all the column with NaN values if no default value to insert is provided",function()
			a:add_column('Col E')
			col = a:get_column('Col E')

			for i=1,#col do
				assert.is.nan(col[i])
			end
		end)

		it("Fills all the column with default value if it is a single value",function()
			a:add_column('Col F', 1)
			assert.are.same(a:get_column('Col F'), {1,1,1,1})
		end)

		it("Fails if the default value provided is a table with a different number of rows",function()
			assert.has.error(function() a:add_column('Col G', {0,1,2,3,5}) end)
		end)

		it("Add positioning",function()
			a:add_column('Position 1', 1, 1)
			assert.are.same(a:get_column_order('Position 1'), 1)

			a:add_column{
				column_name = 'Position 3',
				pos = 3,
				default_value = 'A' -- Can't do ordered call since 'A' becomes type
			}
			assert.are.same(a:get_column_order('Position 3'), 3)
		end)
	end)

	describe("Get a column functionality",function()
		local a = Dataframe(specs_dir.."/data/full.csv")

		assert.are.same(a:get_column('Col A'), {1,2,3,4})

		it("Fails if the column doesn't exist",function()
			assert.has.error(function() a:get_column('Col H') end)
		end)

		it("Returns a numerical column as a tensor",function()
			a_tnsr = torch.Tensor({1,2,3,4})
			a_col = a:get_column{column_name="Col A", as_tensor=true}
			a_col = a_col:type(a_tnsr:type())
			assert.is_true(torch.all(a_tnsr:eq(a_col)))
		end)

		it("Fails returning a tensor if the column is not numerical",function()
			assert.has_error(function() a:get_column{column_name="Col D",as_tensor=true} end)
		end)
	end)

	describe("Reset column functionality",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		it("Resets single column's values",function()
			a:reset_column('Col C', 555)
			assert.are.same(a:get_column('Col C'), {555, 555, 555, 555})
		end)

		it("Resets multiple columns at once",function()
			a:reset_column(Df_Array('Col A', 'Col B'), 444)
			assert.are.same(a:get_column('Col A'), {444, 444, 444, 444})
			assert.are.same(a:get_column('Col B'), {444, 444, 444, 444})
		end)
	end)

	describe("Rename column functionality",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")
		a:rename_column("Col C","Col V")
		assert.is_true(a:has_column("Col V"))
		assert.is_true(not a:has_column("Col C"))

		it("Fails if the column doesn't exist",function()
			assert.has_error(function() a:rename_column('Col M','Col G') end)
		end)

		it("Fails if the new column already exist",function()
			assert.has_error(function() a:rename_column('Col A','Col B') end)
		end)

		it("Refreshs metadata",function()
			local colfound = false
			for k,v in pairs(a.column_order) do
				if v == 'Col V' then
					colfound = true
				end
			end

			assert.is_true(colfound)
			assert.are.same({'Col A','Col B','Col V'},a.column_order)
		end)
	end)

	describe("Search functionalities",function()
		local a = Dataframe(specs_dir.."/data/advanced_short.csv")
		it("Finds the value in Col B", function()
			assert.are.same(a:which('Col B', 'A'), {1})
			assert.are.same(a:which('Col B', 'B'), {2,3})
		end)

		it("Finds the value in Col A", function()
			assert.are.same(a:which('Col A', 'A'), {})
			assert.are.same(a:which('Col A', 1), {1})
		end)

		it("Finds the value in Col C", function()
			assert.are.same(a:which('Col C', 0/0), {2})
			assert.are.same(a:which('Col C', 9), {3})
		end)

		it("Finds the max value", function()
			local indx, val = a:which_max('Col A')
			assert.are.same(indx, {3})
			assert.are.same(val, 3)
			indx, val = a:which_max('Col C')
			assert.are.same(indx, {3})
			assert.are.same(val, 9)
			assert.has_error(function() a:which_max('Col B') end)
		end)

		it("Finds the min value", function()
			local indx, val = a:which_min('Col A')
			assert.are.same(indx, {1})
			assert.are.same(val, 1)
			indx, val = a:which_min('Col C')
			assert.are.same(indx, {1})
			assert.are.same(val, 8)
			assert.has_error(function() a:which_min('Col B') end)
		end)
	end)

	describe("Other functionalities",function()
		local a = Dataframe(specs_dir.."/data/advanced_short.csv")

		it("Returns all numerical columns names", function()
			assert.are.same(a:get_numerical_colnames(), {'Col A', 'Col C'})
		end)

		it("Checks if a column exist",function()
			assert.is_false(a:has_column("Col H"))
			assert.is_true(a:has_column("Col A"))
		end)

		it("Checks if a column is numerical",function()
			assert.has.error(function() a:is_numerical("Col H") end)
			assert.is_true(a:is_numerical("Col A"))
			assert.is_false(a:is_numerical("Col B"))
		end)
	end)

	describe("Bind columns",function()
		it("Equal correct cbind and dataframe", function()
			local a = Dataframe(specs_dir.."/data/advanced_short.csv")

			local b = Dataframe()
			b:load_table(Df_Dict({Test = {1,2,3}}))
			a:cbind(b)

			assert.are.same(a:get_column('Test'),
			                b:get_column('Test'))
		end)

		it("Equal correct cbind with Df_Dict", function()
			local a = Dataframe(specs_dir.."/data/advanced_short.csv")

			a:cbind(Df_Dict({Test = {1,2,3}}))

			assert.are.same(a:get_column('Test'),
			                {1,2,3})
		end)

		it("Checks input", function()
			local a = Dataframe(specs_dir.."/data/advanced_short.csv")

			local b = Dataframe()
			b:load_table(Df_Dict({Test = {1,2,3,4}}))
			assert.has_error(function() a:cbind(b) end)

			local c = Dataframe()
			c:load_table(Df_Dict({['Col A'] = {1,2,3}}))
			assert.has_error(function() a:cbind(c) end)
		end)
	end)

	describe("Boolean columns", function()
		before_each(function()
			a = Dataframe(Df_Dict{
				nmbr = {1, 2, 3, 4},
				str = {"a", "b", "c", "d"},
				bool = {true, false, true, 0/0}
			})
		end)

		it("Check that column type is boolean", function()
			assert.is_true(a:is_boolean("bool"))
			assert.is_false(a:is_boolean("nmbr"))
			assert.is_false(a:is_boolean("str"))
		end)

		it("Verify that boolean2tensor conversion works", function()
			a:boolean2tensor{
				column_name = "bool",
				false_value = 1,
				true_value = 2
			}

			assert.is_false(a:is_boolean("bool"))
			assert.is_true(a:is_numerical("bool"))
			assert.are.same(a:get_column("bool"), {2,1,2,0/0})
		end)

		it("Verify that boolean2tensor conversion works", function()
			a:boolean2categorical("bool")

			assert.is_false(a:is_boolean("bool"))
			assert.is_true(a:is_numerical("bool"))
			assert.are.same(a:get_column("bool"),
			                {"true","false","true",0/0})
		end)

		it("Verify that boolean2tensor with custom strins work", function()
			a:boolean2categorical("bool", "no", "yes")

			assert.is_false(a:is_boolean("bool"))
			assert.is_true(a:is_numerical("bool"))
			assert.are.same(a:get_column("bool"),
			                {"yes", "no", "yes",0/0})
			a:fill_all_na()
			assert.are.same(a:get_column("bool"),
			                {"yes", "no", "yes","__nan__"})
		end)
	end)
end)
