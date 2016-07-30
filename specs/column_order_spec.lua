require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Column order functionality", function()

	it("Keeps the right order when loading a CSV",function()
		local a = Dataframe("./data/simple_short.csv")
		assert.are.same(a.column_order,
			{[1] = "Col A",
			[2] = "Col B",
			[3] = "Col C"})
	end)

	it("Keeps the right order when loading a table",function()
		local a = Dataframe()
		local first  = {1,2,3}
		local second = {"2","1","3"}
		local third  = {"2","a","3"}
		local column_order = {[1] = 'firstColumn',
							  [2] = 'secondColumn',
							  [3] = 'thirdColumn'}
		local data = {['firstColumn']=first,
					  ['secondColumn']=second,
					  ['thirdColumn']=third}

		a:load_table{data=Df_Dict(data), column_order = Df_Array(column_order)}

		assert.are.same(a.column_order, column_order)

		column_order[2] = nil
		assert.is.error(function() a:load_table{data=Df_Dict(data), column_order = column_order} end)
	end)

	it("Keeps the right order when saving to CSV",function()
		local a = Dataframe()
		local first = {1,2,3}
		local second = {"Wow it's tricky","1,2","323."}
		local third = {"\"","a\"a","3"}

		local data = {['firstColumn']=first,
					  ['secondColumn']=second,
					  ['thirdColumn']=third}

		c_order = {[1] = "firstColumn",
				   [4] = "secondColumn",
				   [3] = "thirdColumn"}

		assert.is.error(function() a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)} end)

		c_order = {[1] = "firstColumn",
				   [3] = "thirdColumn"}

		assert.is.error(function() a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)} end)

		c_order = {[1] = "firstColumn",
				   [2] = "secondColumn",
				   [3] = "thirdColumn"}

		a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)}
		a:to_csv{path = "tricky_csv.csv"}
		a:load_csv{path = "tricky_csv.csv", verbose = false}

		assert.are.same(a.dataset, data)
		assert.are.same(a.column_order, c_order)

		os.remove("tricky_csv.csv")
	end)

	it("Keeps the right order when saving to Tensor",function()
		local a = Dataframe()
		local first = {1,2,3}
		local second = {"A","B","323."}
		local third = 2.2

		data = {['1st']=first,
				['2nd']=second,
				['3rd']=third}

		c_order = {[1] = "1st",
				   [2] = "2nd",
				   [3] = "3rd"}

		a:load_table{data=Df_Dict(data), column_order=Df_Array(c_order)}
		tnsr = a:to_tensor()

		assert.is.equal(tnsr:size(1),a:shape()["rows"])
		assert.is.equal(tnsr:size(2),a:shape()["cols"] - 1)

		sum = 0
		col_no = a:get_column_order{column_name='1st', as_tensor = true}

		for i=1,tnsr:size(1) do
			sum = math.abs(tnsr[i][col_no] - a:get_column('1st')[i])
		end

		assert.is_true(sum < 10^-5)

		sum = 0
		col_no = a:get_column_order{column_name='3rd', as_tensor = true}

		for i=1,tnsr:size(1) do
			sum = math.abs(tnsr[i][col_no] - a:get_column('3rd')[i])
		end

		assert.is_true(sum < 10^-5)

		assert.is.equal(a:get_column_order{column_name = '2nd', as_tensor = true}, nil)
	end)


	it("Check that orders can be swapped",function()
		local a = Dataframe("./data/simple_short.csv")
		a:swap_column_order("Col A", "Col B")
		assert.are.same(a.column_order,
			{[1] = "Col B",
			[2] = "Col A",
			[3] = "Col C"})
	end)

	it("Check that orders can set using pos_column_order",function()
		local a = Dataframe("./data/simple_short.csv")
		a:pos_column_order("Col B", 2)
		assert.are.same(a.column_order,
			{[1] = "Col A",
			[2] = "Col B",
			[3] = "Col C"})

		a:pos_column_order("Col B", 1)
		assert.are.same(a.column_order,
				{[1] = "Col B",
				[2] = "Col A",
				[3] = "Col C"})

		a:pos_column_order("Col C", 1)
		assert.are.same(a.column_order,
				{[1] = "Col C",
				[2] = "Col B",
				[3] = "Col A"})


		a:pos_column_order("Col C", -1)
		assert.are.same(a.column_order,
				{[1] = "Col C",
				[2] = "Col B",
				[3] = "Col A"})

		a:pos_column_order("Col C", 100)
		assert.are.same(a.column_order,
				{[1] = "Col B",
				[2] = "Col A",
				[3] = "Col C"})
	end)
end)
