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

describe("Row functions", function()
  it("Appends new data",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		a:append(Df_Dict({['Col A']={15},['Col B']={25},['Col C']={35}}))
		assert.are.same(a:shape(), {rows=5, cols=3})-- "The simple_short.csv is 4x3 after insert should be 5x3"
	end)

	it("Appends new columns together with new data",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		a:append(Df_Dict({['Col A']={15},['Col D']={25},['Col C']={35}}))
		assert.are.same(a:shape(), {rows=5, cols=4})-- "The simple_short.csv is 4x3 after insert should be 5x3"
	end)

	it("Appends dataframe",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		b = Dataframe()
		b:load_table{data = Df_Dict({['Col A']={15},['Col B']={25},['Col C']={35}}),
		             column_order = Df_Array('Col B', 'Col C', 'Col A')}
		a:append(b)
		assert.are.same(a:shape(), {rows=5, cols=3})-- "The simple_short.csv is 4x3 after insert should be 5x3"
	end)

	it("Appends dataframe to empty dataset should copy the original including specs",
	function()
		local a = Dataframe()

		b = Dataframe()
		b:load_table{data = Df_Dict({['Col A']={15},['Col B']={25},['Col C']={35}}),
		             column_order = Df_Array('Col B', 'Col C', 'Col A')}
		a:append(b)
		assert.are.same(a:shape(), {rows=1, cols=3})-- "The simple_short.csv is 4x3 after insert should be 5x3"
		assert.are.same(a.column_order, b.column_order)
	end)

	it("Check rbind new columns together with new data",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		a:rbind(Df_Dict({['Col A']={15},['Col D']={25},['Col C']={35}}))
		assert.are.same(a:shape(), {rows=5, cols=4})-- "The simple_short.csv is 4x3 after insert should be 5x3"
	end)

	it("Check rbind with dataframe",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		b = Dataframe()
		b:load_table{data = Df_Dict({['Col A']={15},['Col B']={25},['Col C']={35}})}
		a:rbind(b)
		assert.are.same(a:shape(), {rows=5, cols=3})-- "The simple_short.csv is 4x3 after insert should be 5x3"
	end)

	it("Inserts a row", function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		a:insert(2, Df_Dict({['Col A']={15},['Col E']={25},['Col C']={35}}))
		assert.are.same(a:shape(), {rows=5, cols=4})
		assert.are.same(a:get_column('Col A'), {1, 15, 2, 3, 4})
		assert.are.same(a:get_column('Col B'), {0.2, 0/0, 0.3, 0.4, 0.5})
	end)

	it("Inserts three rows", function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")
		a:insert(2, Df_Dict({['Col A']={15, 16, 17}}))
		assert.are.same(a:shape(), {rows=7, cols=3})
		assert.are.same(a:get_column('Col A'), {1, 15, 16, 17, 2, 3, 4})
		assert.are.same(a:get_column('Col B'), {.2, 0/0, 0/0, 0/0, .3, .4, .5})
	end)

	it("Removes a row given an index",function()
		local a = Dataframe(specs_dir.."/data/simple_short.csv")

		a:remove_index(1)
		assert.are.same(a:shape(), {rows=3, cols=3})-- "The simple_short.csv is 4x3"
		assert.are.same(a:get_column('Col A'), {2,3,4})

		a:remove_index(1)
		a:remove_index(1)
		a:remove_index(1)
		assert.are.same(a:shape(), {rows=0, cols=3})
	end)

	it("Check that append calls load_table", function()
		local a =  Dataframe()
		a:append(Df_Dict{b=1, a=2})

		a:assert_has_column('a')
		a:assert_has_column('b')

		assert.are.same(a:get_column('a')[1], 2)
	end)

	it("Check that append calls load_table with column order", function()
		local a =  Dataframe()
		a:append(Df_Dict{b=1, a=2}, Df_Array("b", "a"))

		local b =  Dataframe()
		b:append(Df_Dict{b=1, a=2}, Df_Array("a", "b"))

		assert.are.not_equal(a.column_order, b.column_order)
		assert.are.same(a:get_column('a'), b:get_column('a'))
		assert.are.same(a:get_column('b'), b:get_column('b'))
	end)
end)
