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

describe("Column operations", function()

	describe("Drop functionality",function()

		it("Allows to remove an entire column", function()
			local a = Dataframe("./data/simple_short.csv")

			a:drop('Col A')
			assert.is_true(not a:has_column('Col A'))
			assert.is_true(a:has_column('Col B'))
			assert.is_true(a:has_column('Col C'))
			assert.are.same(a:shape(), {rows=4, cols=2})-- "The simple_short.csv is 4x3 after drop should be 4x2"
			-- Should cause an error
			assert.has_error(function() a:drop('Col A') end)
		end)

		it("Allows to remove multiple columns", function()
			local a = Dataframe("./data/simple_short.csv")

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
			local a = Dataframe("./data/simple_short.csv")
			a:drop('Col A')
			a:drop('Col B')
			-- All are dropped
			a:drop('Col C')
			assert.are.same(a.dataset, {})-- "All columns are dropped"
			assert.are.same(a.columns,{})
			assert.are.same(a.column_order,{})
			assert.are.same(a.categorical,{})
			assert.are.same(a.print,{no_rows = 10, max_col_width = 20})
			assert.are.same(a.schema,{})
			assert.is.equal(a.n_rows,0)
		end)
	end)

	describe("Add functionality",function()
		local a = Dataframe("./data/simple_short.csv")

		it("Raises an error if the column is already existing",function()
			assert.has_error(function() a:add_column('Col A') end)
		end)

		it("Allows to use a table as the default value",function()
			d_col = {0,1,2,3}
			a:add_column('Col D', Df_Array(d_col))
			assert.are.same(a:get_column('Col D'), d_col)-- "Col D isn't the expected value"
			assert.are.same(a:shape(), {rows=4, cols=4})-- "The simple_short.csv is 4x3 after add should be 4x4"
		end)

		it("Fills all the column with NaN values if no default value to insert is provided",function()
			a:add_column('Col E')
			col = a:get_column('Col E')

			for _,v in pairs(col) do
				assert.is_true(isnan(v))
			end
		end)

		it("Fills all the column with default value if it is a single value",function()
			a:add_column('Col F', 1)
			assert.are.same(a:get_column('Col F'), {1,1,1,1})
		end)

		it("Fails if the default value provided is a table with a different number of rows",function()
			assert.has.error(function() a:add_column('Col G', {0,1,2,3,5}) end)
		end)

	end)

	describe("Get a column functionality",function()
		local a = Dataframe("./data/full.csv")

		assert.are.same(a:get_column('Col A'), {1,2,3,4})

		it("Fails if the column doesn't exist",function()
			assert.has.error(function() a:get_column('Col H') end)
		end)

		it("Returns a numerical column as a tensor",function()
			a_tnsr = torch.Tensor({1,2,3,4})
			a_col = a:get_column{column_name="Col A",as_tensor=true}

			assert.is_true(torch.all(a_tnsr:eq(a_col)))
		end)

		it("Fails returning a tensor if the column is not numerical",function()
			assert.has_error(function() a:get_column{column_name="Col D",as_tensor=true} end)
		end)
	end)

	describe("Reset column functionality",function()
		local a = Dataframe("./data/simple_short.csv")

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
		local a = Dataframe("./data/simple_short.csv")
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
			for k,v in pairs(a.columns) do
				if v == 'Col V' then
					colfound = true
				end
			end

			assert.is_true(colfound)
			assert.are.same({'Col A','Col B','Col V'},a.column_order)
		end)
	end)

	describe("Other functionalities",function()
			local a = Dataframe("./data/advanced_short.csv")

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

end)
