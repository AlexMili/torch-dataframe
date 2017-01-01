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
