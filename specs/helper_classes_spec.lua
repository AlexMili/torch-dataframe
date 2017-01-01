require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("Df_Array", function()
	local tableData = {1,2,3,4}

	it("can be init with a table",function()
		local array = Df_Array(tableData)

		assert.are.same(tableData,array.data)
	end)

	it("can be init with a Dataseries",function()
		local series = Dataseries(Df_Array(tableData))
		local array = Df_Array(series)

		assert.are.same(tableData,array.data)
	end)

	it("can be init with a tensor",function()
		local tensor = torch.IntTensor(tableData)
		local array = Df_Array(tensor)

		assert.are.same(tableData,array.data)
	end)

	it("can be init with 'infinite' arguments",function()
		local array = Df_Array(1,2,3,4)

		assert.are.same(tableData,array.data)
	end)

	it("returns asked index with brackets",function()
		local array = Df_Array(tableData)

		assert.are.same(array[3],3)
	end)

	it("returns nil if index does not exists or it is not a number",function()
		local array = Df_Array(tableData)

		assert.are.same(array[42],nil)
	end)

	it("# returns its length",function()
		local array = Df_Array(tableData)

		assert.are.same(#array,4)
	end)
end)

describe("Df_Dict",function()
	local simpleTable = {1,2,3,4}
	local simpleTableData = {["col1"]=1,["col2"]=2,["col3"]=3,["col4"]=4}
	local dimTableData = {["col1"]=1,["col2"]=2,["col3"]=3,["col4"]={4,5,6}}

	it("can be init with a simple table without key",function()
		local dic = Df_Dict(simpleTable)
		assert.are.same(dic.data,simpleTable)
		assert.are.same(dic.keys,simpleTable)
	end)

	it("can be init with a simple table keys",function()
		local dic = Df_Dict(simpleTableData)
		assert.are.same(dic.data,simpleTableData)
	end)

	it("can be init with a multi-dimensional table",function()
		local dic = Df_Dict(dimTableData)
		assert.are.same(dic.data,dimTableData)
	end)

	it("can check if all columns are the same size",function()
		local dic = Df_Dict(simpleTable)
		assert.is_true(dic:check_lengths())

		dic = Df_Dict(simpleTableData)
		assert.is_true(dic:check_lengths())

		dic = Df_Dict(dimTableData)
		assert.is_false(dic:check_lengths())
	end)

	it("returns asked key's value with brackets",function()
		local dic = Df_Dict(simpleTable)
		assert.are.same(dic[3],3)

		dic = Df_Dict(simpleTableData)
		assert.are.same(dic["$col3"],3)

		dic = Df_Dict(dimTableData)
		assert.are.same(dic["$col4"],{4,5,6})
	end)

	it("returns nil if index does not exists or it is not a number",function()
		local dic = Df_Dict(simpleTable)
		assert.are.same(dic[42],nil)
	end)

	it("# returns its length",function()
		local dic = Df_Dict(simpleTable)
		assert.are.same(#dic,4)

		dic = Df_Dict(simpleTableData)
		assert.are.same(#dic,4)

		dic = Df_Dict(dimTableData)
		assert.are.same(#dic,4)
	end)
end)

describe("Df_Tbl",function()
	local simpleTable = {1,2,3,4}

	it("can be init with a table",function()
		local tbl = Df_Tbl(simpleTable)
		assert.are.same(tbl.data,simpleTable)
	end)

	it("# returns its length",function()
		local tbl = Df_Tbl(simpleTable)
		assert.are.same(#tbl,4)
	end)
end)
