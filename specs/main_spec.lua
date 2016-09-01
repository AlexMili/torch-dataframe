require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Dataframe class", function()

	describe("On initialization",function()

		it("Sets all class variables to default values",function()
			local df = Dataframe()

			assert.are.same(df.dataset,{})
			assert.are.same(df.column_order,{})
			assert.are.same(df.tostring_defaults,
			               {no_rows = 10,
			                min_col_width = 7,
			                max_table_width = 80})
			assert.is.equal(df.n_rows,0)
		end)

		it("Loads a CSV file if passed in argument",function()
			local df = Dataframe("./data/simple_short.csv")
			assert.are.same(df:shape(),{rows=4, cols=3})
		end)

		it("Loads a #table if passed in argument",function()
			local df = Dataframe(Df_Dict({
				['first_column']={3,4,5},
				['second_column']={10,11,12}
			}))

			assert.are.same(df:get_column("first_column"), {3,4,5})
			assert.are.same(df:get_column("second_column"), {10,11,12})
		end)

		it("Loads a table if passed in argument with column_order",function()
			local df = Dataframe{
				data =Df_Dict{
					['first']={3,4,5},
					['second']={10,11,12}
				},
				column_order = Df_Array("second", "first")
			}

			assert.are.same(df.column_order, {"second", "first"})
		end)
	end)

	describe("When using internal functions",function()

		it("Resets all class-variables to default values ",function()
			local df = Dataframe()
			df:load_table(Df_Dict({
				['first_column']={3,4,5},
				['second_column']={10,11,12}
			}))

			df:_clean()

			assert.are.same(df.dataset,{})
			assert.are.same(df.column_order,{})
			assert.are.same(df.tostring_defaults,
			               {no_rows = 10,
			                min_col_width = 7,
			                max_table_width = 80})
			assert.is.equal(df.n_rows,0)
		end)

		it("Copy all meta variables to a new Dataframe object",function()
			local df = Dataframe("./data/simple_short.csv")
			local df2 = Dataframe()

			df:_copy_meta(df2)

			assert.are.same(df2.dataset,{})
			assert.is.equal(df2.n_rows,0)

			assert.are.same(df.column_order,df2.column_order)
			assert.are.same(df.tostring_defaults,df2.tostring_defaults)
		end)
	end)

	it("Update the schema",function()
		local a = Dataframe()
		local first = {1,2,3}
		local second = {"2","1","3"}
		local third = {"2","a","3"}

		data = {['firstColumn']=first,
				['secondColumn']=second,
				['thirdColumn']=third}

		a:load_table{data=Df_Dict(data)}

		assert.is.equal(a["$firstColumn"]:get_variable_type(), 'integer')
		assert.is.equal(a["$secondColumn"]:get_variable_type(), 'integer')
		assert.is.equal(a["$thirdColumn"]:get_variable_type(), 'string')
	end)

	it("Returns the shape of the Dataframe",function()
		local a = Dataframe("./data/simple_short.csv")

		assert.are.same(a:shape(), {rows = 4, cols = 3})

		a:load_csv{path = "./data/advanced_short.csv",
		verbose = false}
		assert.are.same(a:shape(), {rows = 3, cols = 3})

		a:load_table{data = Df_Dict({test = {1,nil,3}})}
		assert.are.same(a:shape(), {rows = 3, cols = 1})

		assert.are.same(a:size(1), 3)
		assert.are.same(a:size(2), 1)
	end)

	it("Returns first elements of the dataframe",function()
		local a = Dataframe("./data/simple_short.csv")

		head = a:head(2)
		assert.is.equal(head.n_rows, 2)-- "Self the n_rows isn't updated, is " .. head.n_rows .. " instead of expected 2"
		-- do a manual count
		local no_elmnts = 0
		for k,v in pairs(head.dataset) do
			local l = #v

			if (l > no_elmnts) then
				no_elmnts = l
			end
		end

		assert.is.equal(no_elmnts, 2)-- "Expecting 2 elements got " .. no_elmnts .. " elements when counting manually"

		-- Only 4 rows and thus all should be included
		head = a:head(20)
		assert.is.equal(head.n_rows, a.n_rows)-- "The elements should be identical to the original " .. a.n_rows .. " got instead " .. head.n_rows .. " elements"

		head = a:head()
		assert.is.equal(head.n_rows, a.n_rows)-- "The elements should be identical to the original " .. a.n_rows .. " as the default is < original elements. Got instead " .. head.n_rows .. " elements"
	end)

	it("Returns last elements of the dataframe",function()
		local a = Dataframe("./data/simple_short.csv")

		tail = a:tail(2)
		assert.is.equal(tail.n_rows, 2)-- "Self the n_rows isn't updated, is " .. tail.n_rows .. " instead of expected 2"
		-- Do a manual count
		local no_elmnts = 0
		for k,v in pairs(tail.dataset) do
			local l = #v
			if (l > no_elmnts) then
				no_elmnts = l
			end
		end
		assert.is.equal(no_elmnts, 2)-- "Should have selected 2 last elements but got " .. no_elmnts .. " when doin a manual count"

		-- Only 4 rows and thus all should be included
		tail = a:tail(20)
		assert.is.equal(tail.n_rows, a.n_rows)-- "Should have selected 20 las elements and returned the original length " .. a.n_rows .. " since there are only 4 rows and not " .. tail.n_rows

		tail = a:tail()
		assert.is.equal(tail.n_rows, a.n_rows)-- "Default selection is bigger than the simple_short, you got " .. tail.n_rows .. " instead of " .. a.n_rows
	end)

	it("Returns all unique #1 values in a column", function()
		local a = Dataframe("./data/advanced_short.csv")

		assert.are.same(a:unique('Col A'), {1,2,3})-- "Failed to match Col A"
		assert.are.same(a:unique('Col B', true), {A=1, B=2})-- "Failed to match Col B"
		assert.are.same(a:unique('Col C', true), {[8]=1, [9]=2})-- "Failed to match Col C"
	end)

	it("Get a single row given an index",function()
		local a = Dataframe("./data/simple_short.csv")

		assert.are.same(a:get_row(1),{
		['Col A']=1,
		['Col B']=.2,
		['Col C']=1000
		})
	end)

	it("A column with boolean values should not be a numerical nor a string column",
	function()
		local a = Dataframe("./data/simple_short.csv")
		a:add_column('bool', true)

		assert.is_false(a:is_numerical('bool'), "A boolean column is not numerical")
		assert.is_false(a:is_string('bool'), "A boolean column is not a string column")
		assert.is_true(a:is_boolean('bool'), "A boolean column should be a boolean column")
	end)
end)
