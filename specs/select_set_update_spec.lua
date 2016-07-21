require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Data manipulationf incl. where, update etc.", function()

	it("Retrieves a value in a column #where",function()
		local a = Dataframe("./data/simple_short.csv")

		local ret_val = a:where('Col A', 2)
		assert.are.same(ret_val:get_column("Col A"), {2})
		assert.are.same(ret_val:get_column("Col C"), {.1})
		assert.is.equal(torch.type(ret_val), "Dataframe")
		assert.are.same(ret_val:shape(), {rows = 1, cols = 3})

		local ret_val = a:where('Col A', 222222222)
		assert.are.same(ret_val:shape(), {rows = 0, cols = 0})

		a:__init()
		a:load_csv{path = "./data/advanced_short.csv",
		verbose = false}
		ret_val = a:where('Col B', 'B')
		assert.are.same(ret_val:shape(), {rows = 2, cols = 3})
		col_c = ret_val:get_column('Col C')
		assert.is_true(isnan(col_c[1]))
		assert.is.equal(col_c[2], 9)
		assert.are.same(ret_val:get_column('Col A'), {2, 3})
	end)

	it("Updates multiple rows according to a custom condition", function()
		local a = Dataframe("./data/simple_short.csv")

		local start_val = a:get_column('Col B')
		start_val[1] = start_val[1] * 2

		a:update(
			function(s_row) return s_row['Col A'] == 1 end,
			function(upd_row) upd_row['Col B'] = upd_row['Col B'] * 2 return upd_row end
		)
		assert.are.same(a:get_column('Col B'), start_val)

		-- Check a double match
		local b = Dataframe("./data/advanced_short.csv")

		start_val = b:get_column('Col A')
		start_val[2] = start_val[2] * 2
		start_val[3] = start_val[3] * 2
		b:update(
			function(s_row) return s_row['Col B'] == 1 end,
			function(upd_row) upd_row['Col A'] = upd_row['Col A'] * 2 return upd_row end
		)

		assert.are.same(b:get_column('Col A'), start_val)
	end)

	it("Updates a single cell given a column name and an value #set",function()
		local a = Dataframe("./data/simple_short.csv")

		a:set(1000, 'Col C', Df_Dict({['Col A']=99}))
		assert.is.equal(a:get_column('Col A')[1], 99)
	end)

	it("Updates all matching cells when using #set",function()
		local a = Dataframe(Df_Dict{a = {1,2,3}, b = {1,1,2}})

		a:set(1, 'b', Df_Dict({['a']=4}))
		assert.are.same(a:get_column('a'), {4,4,3})
	end)

	it("Updates a single cell given a an index",function()
		local a = Dataframe("./data/simple_short.csv")

		a:set(2, Df_Dict({['Col A']=99}))
		assert.is.equal(a:get_column('Col A')[2], 99)
	end)

	it("Updates a unique row given an index",function()
		local a = Dataframe("./data/simple_short.csv")

		new = {
		['Col A']=4,
		['Col B']=4,
		['Col C']=4
		}
		a:_update_single_row(1, Df_Tbl(new), Df_Tbl(a:get_row(1)))
		assert.are.same(a:get_row(1), new)
	end)

	describe("Check #wide2long", function()
		local df = Dataframe(Df_Dict({a = {1,2,3}, b={4,nil,5}, c={[3] = 6}}))
		a = df:wide2long(Df_Array("c", "b"), "id", "value")

		it("Check that the number of rows are correct", function()
			assert.are.same(a:where('a', 1):size(1), 1)
			assert.are.same(a:where('a', 2):size(1), 1)
			assert.are.same(a:where('a', 3):size(1), 2)
		end)

		it("Check that the value is correct when having one value", function()
			local row = a:where('a', 1):get_row(1)
			assert.are.same(row['id'], 'b')
			assert.are.same(row['value'], 4)
		end)


		it("Check that the value is correct when having no value", function()
			local row = a:where('a', 2):get_row(1)
			assert.is_true(isnan(row['id']))
			assert.is_true(isnan(row['value']))
		end)

		it("Check that the order is correct when having multiple values", function()
			local row = a:where('a', 3):
				where('id', 'b'):
				get_row(1)
			assert.are.same(row['id'], 'b')
			assert.are.same(row['value'], 5)

			local row = a:where('a', 3):
				where('id', 'c'):
				get_row(1)
			assert.are.same(row['id'], 'c')
			assert.are.same(row['value'], 6)
		end)

		local df = Dataframe(Df_Dict({a = {1,2,3}, b={4,nil,5}, c={[3] = 6}}))
		b = df:wide2long("[bc]", "id", "value")
		it("Check that this works the same with regulare expressions", function()
			assert.are.same(b:where('a', 1):size(1), 1)
			assert.are.same(b:where('a', 2):size(1), 1)
			assert.are.same(b:where('a', 3):size(1), 2)

			local row = b:where('a', 3):
				where('id', 'b'):
				get_row(1)
			assert.are.same(row['id'], 'b')
			assert.are.same(row['value'], 5)

			local row = b:where('a', 3):
				where('id', 'c'):
				get_row(1)
			assert.are.same(row['id'], 'c')
			assert.are.same(row['value'], 6)
		end)

		c = df:wide2long("c", "id", "value")
		it("Check that different columnt result in different result", function()
			assert.is_false(a == c)
		end)
	end)
end)
