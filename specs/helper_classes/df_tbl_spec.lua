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
