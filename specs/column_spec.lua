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
			a:add_column('Col D', d_col)
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

		it("Should fail if the default value provided is a table with a different number of rows",function()
			assert.has.error(function() a:add_column('Col G', {0,1,2,3,5}) end)
		end)

	end)

	it("Returns a column",function()
		local a = Dataframe("./data/simple_short.csv")

		assert.has.error(function() a:get_column('Col D') end)
		assert.is_not.equal(a:get_column('Col A'), nil)-- "Col A should be present"
		assert.is_not.equal(a:get_column('Col B'), nil)-- "Col B should be present"
		assert.is_not.equal(a:get_column('Col C'), nil)-- "Col C should be present"
	end)

	it("Resets a column",function()
		local a = Dataframe("./data/simple_short.csv")

		a:reset_column('Col C', 555)
		assert.are.same(a:shape(), {rows=4, cols=3})-- "The simple_short.csv is 4x3"
		assert.are.same(a:get_column('Col C'), {555, 555, 555, 555})

		a:reset_column({'Col A', 'Col B'}, 555)
		assert.are.same(a:get_column('Col A'), {555, 555, 555, 555})
		assert.are.same(a:get_column('Col B'), {555, 555, 555, 555})
	end)

	it("Renames a column", function()
		local a = Dataframe("./data/simple_short.csv")

		a:rename_column("Col A", "Col D")
		assert.is_true(a:has_column("Col D"))
		assert.is_true(not a:has_column("Col A"))
	end)

	it("Returns all numerical columns names", function()
		local a = Dataframe("./data/advanced_short.csv")

		assert.are.same(a:get_numerical_colnames(), {'Col A', 'Col C'})
	end)
end)