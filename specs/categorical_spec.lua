require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Categorical column", function()
	local a = Dataframe()
	a:load_csv{path = "./data/advanced_short.csv", verbose = false}

	it("Should not be a numerical column",function()
		assert.is_true(not a:is_numerical('Col B'), "Column should not be a numerical")
	end)

	it("Should be convertible to an integer column",function()
		a:as_categorical('Col B')

		assert.are.same(a:get_cat_keys('Col B'), {A=1, B=2})
		assert.is_true(a:is_categorical('Col B'))
		assert.is_true(a:is_numerical('Col B'))
	end)

	it("Should be convertible to an int linspace if it's a numerical column",function()
		a:as_categorical('Col C')

		assert.are.same(a:get_cat_keys('Col C'), {[8] = 1, [9] = 2})
		assert.is_true(a:is_categorical('Col C'))
		assert.is_true(not a:is_categorical('Col A'))
	end)

	it("Check that reversion works",function()
		a:as_string('Col C')

		assert.is_false(a:is_categorical('Col C'))
		assert.are.same(a:get_column{column_name='Col C'}[1], 8)
		assert.is_true(isnan(a:get_column{column_name='Col C'}[2]))
		assert.are.same(a:get_column{column_name='Col C'}[3], 9)
	end)


	describe("Conversion",function()
		local a = Dataframe("./data/advanced_short.csv")
		a:as_categorical('Col B')

		it("Should handle integers and nan input",function()
			assert.is.equal(a:to_categorical{data=1, column_name='Col B'}, 'A')
			assert.is.equal(a:to_categorical(2, 'Col B'), 'B')
			assert.is_true(isnan(a:to_categorical(0/0, 'Col B')))
		end)

		it("Should handle table input",function()
			assert.are.same(a:to_categorical(Df_Array(2, 1), 'Col B'), {'B', 'A'})
		end)

		it("Should handle tensor input",function()
			assert.are.same(a:to_categorical(torch.Tensor({1,2}), 'Col B'), {'A', 'B'})
		end)

		it("Should stay inside the defined range",function()
			assert.has.error(function() a:to_categorical(3, 'Col B') end)
		end)

		it("Should fails at converting a non-categorical value",function()
			assert.has.error(function() a:to_categorical(1, 'Col A') end)
		end)
	end)

	describe("Reverse process",function()

		it("Should handle a string as input",function()
			assert.are.same(a:from_categorical('A', 'Col B'), {1})
			assert.are.same(a:from_categorical('B', 'Col B'), {2})
		end)

		it("Should handle a table as input",function()
			assert.are.same(a:from_categorical(Df_Array('A', 'B'), 'Col B'), {1, 2})
		end)

		it("Should handle a tensor as input",function()
			assert.is.equal(a:from_categorical{data = Df_Array('A', 'B'), column_name = 'Col B', as_tensor = true}[1], torch.Tensor({1, 2})[1])
			assert.is.equal(a:from_categorical{data = Df_Array('A', 'B'), column_name = 'Col B', as_tensor = true}[2], torch.Tensor({1, 2})[2])
			-- tester:eq(a:from_categorical{data = {'A', 'B'}, column_name = 'Col B', as_tensor = true}, torch.Tensor({1, 2}))
		end)

		it("Should handle nan values",function()
			assert.is_true(isnan(a:from_categorical('C', 'Col B')[1]))
		end)

		it("Should fails on non-categorical column",function()
			assert.has.error(function() a:from_categorical('A', 'Col A') end)
		end)
	end)

	it("Get column",function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')
		assert.are.same(a:get_column('Col B'), {'A', 'B', 'B'})-- "Failed to retrieve categorical representations"
		assert.are.same(a:get_column('Col B', true), {1,2,2})-- "Failed to retrieve raw representations"
		assert.are.same(a:get_column{column_name = 'Col B', as_raw = true}, {1, 2, 2})-- "Failed to return numbers instead of strings for categorical column"
		--tester:eq(a:get_column{column_name = 'Col B', as_tensor = true}, torch.Tensor({1, 2, 2}))-- "Failed to return a tensor from categorical column"


		true_vals = {"TRUE", "FALSE", "TRUE"}
		a:load_table{data=Df_Dict({['Col A']=true_vals,['Col B']={10,11,12}})}
		a:as_categorical('Col A')
		assert.are.same(a:get_column('Col A'), true_vals)
	end)

	it("Returns unique values",function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')
		assert.are.same(a:unique('Col B'), {'A', 'B'})-- "Failed to get categorical data"
		assert.are.same(a:unique{column_name = 'Col B', as_raw = true}, {1, 2})-- "Failed to get raw data"
		assert.are.same(a:unique{column_name ='Col B', as_keys = true}, {['A'] = 1, ['B'] = 2})-- "Failed to get data as keys"
		assert.are.same(a:unique{column_name ='Col B', as_keys = true, as_raw = true}, {[1] = 1, [2] = 2})-- "Failed to get raw data as keys"
	end)

	it("Order the categories", function()
		local b = Dataframe(Df_Dict{a={"b", "a", "c"}})
		b:as_categorical('a')

		assert.are.same(b:from_categorical(Df_Array("a", "b", "c"), 'a'),
		                {1,2,3})
	end)

	it("Specify levels in a different order than sorted", function()
		local b = Dataframe(Df_Dict{a={"b", "a", "c"}})
		b:as_categorical{column_name = 'a',
		                 levels = Df_Array("a", "c", "b")}

		assert.are.same(b:from_categorical(Df_Array("a", "b", "c"), 'a'),
		                {1,3,2})

		b:as_string('a')
		b:as_categorical('a', Df_Array("b", "a", "c"))

		assert.are.same(b:from_categorical(Df_Array("a", "b", "c"), 'a'),
		                {2,1,3})
	end)

	it("Specify fewer levels than present", function()
		local b = Dataframe(Df_Dict{a={"b", "a", "c"}})
		b:as_categorical('a', Df_Array("a", "b"))

		assert.are.same(b:get_column('a', true)[1], 2)
		assert.are.same(b:get_column('a', true)[2], 1)
		assert.is_true(isnan(b:get_column('a', true)[3]))
	end)

	it("Specify labels", function()
		local b = Dataframe(Df_Dict{a={"b", "a", "c"}})
		b:as_categorical('a', Df_Array("a", "b"), Df_Array("A", "B"))

		assert.are.same(b:get_column('a')[1], "B")
		assert.are.same(b:get_column('a')[2], "A")
		assert.is_true(isnan(b:get_column('a', true)[3]))
	end)

	it("Specify levels in a different order than sorted", function()
		local b = Dataframe(Df_Dict{a={"b", "a", "c"}})
		b:as_categorical{column_name = 'a',
		                 exclude=Df_Array("a","B")}

		assert.are.same(b:get_column('a')[1], "b")
		assert.are.same(b:get_column('a')[3], "c")
		assert.is_true(isnan(b:get_column('a', true)[2]))
		assert.are.same(b:from_categorical(Df_Array("b", "c"), 'a'),
		                {1,2})
	end)

	it("Insert new columns",function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')
		local new_data = {
			["Col A"] = 1,
			["Col B"] = "C",
			["Col C"] = 10
		}
		a:append(Df_Dict(new_data))
		assert.are.same(a:get_cat_keys('Col B'), {A=1, B=2, C=3})
	end)

	it("Updates rows according to custom function",function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')

		a:update(
			function(row) return row['Col A'] == 3 end,
			function(row) row['Col B'] = 'C' return row end
		)

		assert.are.same(a:get_column('Col B'), {'A', 'B', 'C'})-- "Should be A,B,C"
		assert.are.same(a:get_cat_keys('Col B'), {A=1, B=2, C=3})-- "Expected 3 keys after changing the last key"

		a:load_csv{path = "./data/advanced_short.csv"}
		a:as_categorical('Col B')

		a:update(
			function(row) return row['Col B'] == 'B' end,
			function(row) row['Col B'] = 'A' return row end
		)

		assert.are.same(a:get_column('Col B'), {'A', 'A', 'A'})-- "All should be A's"
		assert.are.same(a:get_cat_keys('Col B'), {A=1, B=2})-- "Keys should not be removed without prompting"

		a:clean_categorical('Col B')
		assert.are.same(a:get_cat_keys('Col B'), {A=1})-- "Keys should be removed after calling clean_categorical"

		a:load_csv{path = "./data/advanced_short.csv"}
		a:as_categorical('Col B')

		a:update(
			function(row) return row['Col B'] == 'B' end,
			function(row) row['Col B'] = 'A' return row end
		)

		a:clean_categorical('Col B', true)
		assert.are.same(a:get_cat_keys('Col B'), {A=1})-- "Keys should be removed after calling clean_categorical with resetting"

		a:load_csv{path = "./data/advanced_short.csv"}
		a:as_categorical('Col B')
		a:as_categorical('Col C')

		a:update(
			function(row) return row['Col A'] == 3 end,
			function(row) row['Col B'] = 0/0 return row end
		)

		assert.is_true(isnan(a:get_column('Col B')[3]))-- "The nan should be saved as such"
		assert.is_true(isnan(a:get_column('Col C')[2]))-- "The nan should be untouched"
	end)

	it("Set a new value given a column name", function()
		local a = Dataframe()
		a:load_csv{path = "./data/advanced_short.csv"}
		a:as_categorical('Col B')
		a:set('A', 'Col B', Df_Dict({['Col B'] = 'C'}))

		assert.are.same(a:get_cat_keys('Col B'), {A=1, B=2, C=3})

		a:set('C', 'Col B', Df_Dict({['Col B'] = 'B'}))
		assert.are.same(a:get_cat_keys('Col B'), {A=1, B=2, C=3})
		a:clean_categorical('Col B')
		assert.are.same(a:get_cat_keys('Col B'), {B=2})

		a:clean_categorical('Col B', true)
		assert.are.same(a:get_cat_keys('Col B'), {B=1})
	end)

	it("Drops ans redresh meta", function()
		local a = Dataframe()
		a:load_csv{path = "./data/advanced_short.csv"}
		a:as_categorical('Col B')
		a:drop('Col B')
		assert.is.equal(a.categorical['Col B'], nil)

		local a = Dataframe()
		a:load_csv{path = "./data/advanced_short.csv"}
		a:as_categorical('Col B')
		a:drop('Col A')
		assert.is_true(a:is_categorical('Col B'))
	end)

	it(" Loads from a CSV or a table",function()
		local a = Dataframe()
		a:load_csv{path = "./data/advanced_short.csv"}
		a:as_categorical('Col B')
		a:load_csv{path = "./data/advanced_short.csv"}
		assert.is_true(not a:is_categorical('Col B'))
		a:as_categorical('Col B')
		assert.is_true(a:is_categorical('Col B'))

		a:load_table{data=Df_Dict({['Col A']="3",['Col B']={10,11,12}})}
		assert.is_true(not a:is_categorical('Col B'))
		a:as_categorical('Col A')
		assert.is_true(a:is_categorical('Col A'))
	end)

	it("Renames column name",function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')
		assert.has.error(function() a:as_categorical(1) end)
		assert.is_true(a:is_categorical('Col B'))
		a:rename_column('Col B', 'Alt col B')
		assert.has.error(function() a:is_categorical('Col B') end)
		assert.is_true(a:is_categorical('Alt col B'))
	end)

	it("Finds rows in column with specific values", function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')
		local ret_val = a:where('Col B', 'A')
		assert.are.same(ret_val:shape(), {rows = 1, cols = 3})
		assert.are.same(ret_val:from_categorical(Df_Array('A', 'B'), 'Col B'),
		{1, 2})-- "The categorical values shouldn't change due to subsetting"

		ret_val = a:where('Col B', 'B')
		assert.are.same(ret_val:shape(), {rows = 2, cols = 3})

		local new_data = {
			["Col A"] = 1,
			["Col B"] = "C",
			["Col C"] = 10
		}

		ret_val:append(Df_Dict(new_data))
		assert.are.same(ret_val:from_categorical(Df_Array('A', 'B', 'C'), 'Col B'),
		{1, 2, 3})-- "The categorical should add the new value as the last number"

		ret_val = a:where('Col B', 'A')
		assert.are.same(ret_val:shape(), {rows = 1, cols = 3})
	end)

	it("Creates a subset", function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')
		local ret_val = a:sub(1,2)
		assert.are.same(ret_val:shape(), {rows = 2, cols = 3})

		a:add_column("Col D", Df_Array({0/0, "B", "C"}))
		ret_val = a:sub(1,2)
		assert.is_true(isnan(ret_val:get_column('Col D')[1]))-- "Should retain nan value"
		assert.is.equal(ret_val:get_column('Col D')[2], 'B')-- "Should retain string value"
	end)

	it("Counts values frequencies", function()
		local a = Dataframe("./data/advanced_short.csv")

		a:as_categorical('Col B')
		local ret = a:value_counts('Col B')
		assert.is.equal(ret:where('values', 'B'):get_column('count')[1], 2)
		assert.is.equal(ret:where('values', 'A'):get_column('count')[1], 1)

		local ret = a:value_counts('Col A')
		assert.are.same(ret:get_column('count'), {1,1,1})
		assert.are.same(ret:get_column('values'), {1,2,3})

		local ret = a:value_counts('Col C')
		assert.are.same(ret:get_column('count'), {1,1})
		local tmp = ret:get_column('values')
		table.sort(tmp)
		assert.are.same(tmp, {8,9})

		a:as_categorical('Col C')
		local ret = a:value_counts('Col C')
		assert.are.same(ret:get_column('count'), {1,1})
		local tmp = ret:get_column('values')
		table.sort(tmp)
		assert.are.same(tmp, {8,9})
	end)

	it(" Exports to tensor",function()
		local a = Dataframe("./data/advanced_short.csv")

		tnsr = a:to_tensor()
		assert.is.equal(tnsr:size(1),
		a:shape()["rows"])-- "Incorrect number of rows, expecting " .. a:shape()["rows"] .. " but got " ..tnsr:size(1)
		assert.is.equal(tnsr:size(2),
		a:shape()["cols"] - 1)-- "Incorrect number of columns, expecting " .. a:shape()["cols"] - 1 .. " but got " .. tnsr:size(2)
		sum = 0
		col_no = a:get_column_order('Col A')

		for i=1,tnsr:size(1) do
			sum = math.abs(tnsr[i][col_no] - a:get_column('Col A')[i])
		end

		assert.is_true(sum < 1e-5)-- "The difference between the columns should be < 10^-5, it is currently " .. sum

		a:as_categorical('Col B')
		tnsr = a:to_tensor()
		assert.is.equal(tnsr:size(1),
		a:shape()["rows"])-- "Incorrect number of rows, expecting " .. a:shape()["rows"] .. " but got " ..tnsr:size(1)
		assert.is.equal(tnsr:size(2),
		a:shape()["cols"])-- "Incorrect number of columns, expecting " .. a:shape()["cols"] - 1 .. " but got " .. tnsr:size(2)
		sum = 0
		col_no = a:get_column_order('Col A')

		for i=1,tnsr:size(1) do
			sum = math.abs(tnsr[i][col_no] - a:get_column('Col A')[i])
		end

		assert.is_true(sum < 1e-5)-- "The difference between the columns should be < 10^-5, it is currently " .. sum
	end)
end)
