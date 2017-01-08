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

describe("#Core Dataseries functions", function()
	describe("#Init", function()
		it("create boolean Dataseries", function()
			local ds = Dataseries{data = Df_Array(true, true, false)}
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), true)
			assert.are.same(ds:get(2), true)
			assert.are.same(ds:get(3), false)
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("create integer Dataseries", function()
			local ds = Dataseries{data = Df_Array(1,3)}
			assert.are.same(ds:size(), 2)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 3)
			assert.are.same(ds:type(), "torch.IntTensor")
		end)

		it("create double Dataseries", function()
			local ds = Dataseries{data = Df_Array(1,3.2)}
			assert.are.same(ds:size(), 2)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 3.2)
			assert.are.same(ds:type(), "torch.DoubleTensor")
		end)

		it("create a Dataseries from a tensor", function()
			local ds = Dataseries{data = torch.DoubleTensor({1,3.2})}
			assert.are.same(ds:size(), 2)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 3.2)
			assert.are.same(ds:type(), "torch.DoubleTensor")
		end)

		it("create string Dataseries", function()
			local ds = Dataseries{data = Df_Array("test","3.2a")}
			assert.are.same(ds:size(), 2)
			assert.are.same(ds:get(1), "test")
			assert.are.same(ds:get(2), "3.2a")
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("create empty Dataseries", function()
			local ds = Dataseries("string")
			assert.are.same(ds:size(), 0)
		end)

		it("load a tensor without checking", function()
			local tensor = torch.IntTensor({1,2,3,4,5})
			local ds = Dataseries():load(tensor)
			assert.are.same(ds:size(), 5)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(5), 5)
			assert.are.same(ds:type(), "torch.IntTensor")
		end)

		it("load a tds.Vec without checking", function()
			local tensor = tds.Vec({"some","thing","else"})
			local ds = Dataseries():load(tensor)
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), "some")
			assert.are.same(ds:get(3), "else")
			assert.are.same(ds:type(), "tds.Vec")
		end)
	end)

	describe("#missing", function()
		it("nil should become missing", function()
			local ds = Dataseries{data = Df_Array(true, 0/0, false)}
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), true)
			assert.is.nan(ds:get(2))
			assert.are.same(ds:get(3), false)
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("empty string should not become missing", function()
			local ds = Dataseries{data = Df_Array(true, "", false)}
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), true)
			assert.is.not_nan(ds:get(2))
			assert.are.same(ds:get(3), false)
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("missing can be replaced with a real value", function()
			local ds = Dataseries{data = Df_Array(1, 0/0, 2)}
			ds:set(2, 111)
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 111)
			assert.are.same(ds:get(3), 2)
			assert.are.same(ds:type(), "torch.IntTensor")
		end)

		it("shrinking a series should clear the missing", function()
			local ds = Dataseries{data = Df_Array(true, 0/0, false)}
			ds:resize(1)
			ds:append(2)
			assert.are.same(ds:size(), 2)
			assert.are.same(ds:get(1), true)
			assert.is.not_nan(ds:get(2))
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("expanding a series should fill with missing", function()
			local ds = Dataseries{data = Df_Array(1,2)}
			ds:resize(3)
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 2)
			assert.is.nan(ds:get(3))
			ds:set(3, 45)
			assert.are.same(ds:get(3), 45)
			assert.are.same(ds:type(), "torch.IntTensor")
		end)
	end)

	describe("manipulation of elements", function()
		it("remove elements for tds.Vec", function()
			local ds = Dataseries{data = Df_Array(1,0/0,3,4,"5a")}
			assert.are.same(ds:type(), "tds.Vec")
			ds:remove(2)
			assert.are.same(ds:size(), 4)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 3)
			assert.are.same(ds:get(3), 4)
			assert.are.same(ds:get(4), "5a")

			ds:remove(1)
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), 3)

			ds:remove(ds:size())
			assert.are.same(ds:size(), 2)
			assert.are.same(ds:get(2), 4)
		end)

		it("mutate all elements", function()
			local ds = Dataseries{data = Df_Array(1,2,3,4)}
			ds:mutate(function(var)
				return var * 2
			end)
			assert.are.same(ds:size(), 4)
			assert.are.same(ds:get(1), 2)
			assert.are.same(ds:get(2), 4)
			assert.are.same(ds:get(3), 6)
			assert.are.same(ds:get(4), 8)

			ds:mutate(function(var)
				return tostring(var)
			end, "string")
			assert.are.same(ds:size(), 4)
			assert.are.same(ds:get(1), "2")
			assert.are.same(ds:get(2), "4")
			assert.are.same(ds:get(3), "6")
			assert.are.same(ds:get(4), "8")
		end)

		it("remove elements for tds.IntTensor", function()
			local ds = Dataseries{data = Df_Array(1,2,0/0,4,5)}
			assert.are.same(ds:type(), "torch.IntTensor")
			ds:remove(3)
			assert.are.same(ds:size(), 4)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 2)
			assert.are.same(ds:get(3), 4)
			assert.are.same(ds:get(4), 5)

			ds:remove(1)
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), 2)

			ds:remove(ds:size())
			assert.are.same(ds:size(), 2)
			assert.are.same(ds:get(2), 4)
		end)

		it("retain missing positions when removing elements", function()
			local ds = Dataseries{data = Df_Array(0/0,1,0/0,2,0/0)}
			assert.are.same(ds:type(), "torch.IntTensor")

			ds:remove(3)
			assert.are.same(ds:size(), 4)
			assert.is.nan(ds:get(1))
			assert.is.nan(ds:get(ds:size()))
			assert.are.same(ds:get(2), 1)
			assert.are.same(ds:get(3), 2)

			ds:remove(1)
			assert.are.same(ds:size(), 3)
			assert.is.nan(ds:get(ds:size()))
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 2)

			ds:insert(2, 0/0)
			assert.is.nan(ds:get(2))
			assert.are.same(ds:get(3), 2)

			ds:remove(1)
			assert.are.same(ds:size(), 3)
			assert.is.nan(ds:get(1))
			assert.are.same(ds:get(2), 2)
			assert.is.nan(ds:get(ds:size()))
		end)

		it("insert elements for tds.Vec", function()
			local ds = Dataseries{data = Df_Array(1,2,"3a",4,5)}
			assert.are.same(ds:type(), "tds.Vec")

			ds:insert(3, "test")
			assert.are.same(ds:size(), 6)
			assert.are.same(ds:get(2), 2)
			assert.are.same(ds:get(3), "test")
			assert.are.same(ds:get(4), "3a")

			ds:insert(1, 0)
			assert.are.same(ds:size(), 7)
			assert.are.same(ds:get(1), 0)
			assert.are.same(ds:get(2), 1)

			ds:insert(ds:size(), 9999)
			assert.are.same(ds:size(), 8)
			assert.are.same(ds:get(ds:size()), 5)
			assert.are.same(ds:get(ds:size() - 1), 9999)
		end)

		it("insert elements for tds.DoubleTensor", function()
			local ds = Dataseries{data = Df_Array(1,2,3.1,4,5)}
			assert.are.same(ds:type(), "torch.DoubleTensor")

			ds:insert(3, 333)
			assert.are.same(ds:size(), 6)
			assert.are.same(ds:get(2), 2)
			assert.are.same(ds:get(3), 333)
			assert.are.same(ds:get(4), 3.1)

			ds:insert(1, 0)
			assert.are.same(ds:size(), 7)
			assert.are.same(ds:get(1), 0)
			assert.are.same(ds:get(2), 1)

			ds:insert(ds:size(), 9999)
			assert.are.same(ds:size(), 8)
			assert.are.same(ds:get(ds:size()), 5)
			assert.are.same(ds:get(ds:size() - 1), 9999)
		end)

		it("insert elements and retain the missing position", function()
			local ds = Dataseries{data = Df_Array(0/0,1,0/0,2,0/0)}

			ds:insert(3, 333)
			assert.are.same(ds:get(2), 1)
			assert.are.same(ds:get(3), 333)
			assert.is.nan(ds:get(4))

			ds:insert(1, 0)
			assert.are.same(ds:size(), 7)
			assert.is.nan(ds:get(2))
			assert.are.same(ds:get(1), 0)

			ds:insert(ds:size(), 9999)
			assert.are.same(ds:size(), 8)
			assert.is.nan(ds:get(ds:size()))
			assert.are.same(ds:get(ds:size() - 1), 9999)
		end)
	end)
end)

describe("Metatable functions", function()
	describe("The __index__", function()
		it("Basic index retrieval test", function()
			local ds = Dataseries(Df_Array(4,0/0,3))
			assert.are.same(ds[1], 4)
			assert.is.nan(ds[2])
			assert.are.same(ds[3], 3)
		end)

		it("Get subspace", function()
			local ds = Dataseries(Df_Array(4,0/0,3))
			local sub = ds[Df_Array(1,3)]
			assert.are.same(sub[1], 4)
			assert.are.same(sub[2], 3)
			assert.are.same(sub:size(), 2)
		end)

		it("Get span", function()
			local ds = Dataseries(Df_Array(4,0/0,3))
			local sub = ds[":2"]
			assert.are.same(sub[1], 4)
			assert.is.nan(sub[2])
			assert.are.same(sub:size(), 2)
		end)
	end)

	describe("The __newindex__", function()
		it("Basic set test", function()
			local ds = Dataseries(Df_Array(4,0/0,3))
			ds[1] = 2
			ds[2] = 44
			ds[3] = 0/0
			assert.are.same(ds[1], 2)
			assert.are.same(ds[2], 44)
			assert.is.nan(ds[3])
		end)
	end)

	describe("The __len__ #skip_version_LUA51", function()
		it("Basic # length test", function()
			local ds = Dataseries(Df_Array(4,0/0,3))
			assert.are.same(#ds, 3)
		end)
	end)
end)


describe("Missing data functions", function()
	describe("The fill_na", function()
		local ds = Dataseries(Df_Array(0/0,0/0,0/0))
		it("A dataset with all missing should be of type tds.Vec", function()
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("Fill should replace all values with new", function()
			ds:fill_na(1)
			for i=1,#ds do
				assert.are.same(ds[i], 1)
			end
		end)

		it("A should only replace missing values", function()
			local ds = Dataseries(Df_Array(0/0,2,0/0))
			ds:fill_na(0)
			assert.are.same(ds:type(), "torch.IntTensor")
			assert.are.same(ds:get(1), 0)
			assert.are.same(ds:get(2), 2)
			assert.are.same(ds:get(3), 0)
		end)
	end)
end)

describe("Less important functions", function()
	describe("The fill", function()
		it("Fill a single element Dataseries", function()
			local ds = Dataseries(Df_Array(1))
			ds:fill(2)
			assert.are.same(ds:get(1), 2)
			assert.are.same(ds:size(), 1)
		end)

		it("Fill a multiple element Dataseries", function()
			local ds = Dataseries(Df_Array(1,2,3,4,5))
			ds:fill(99)
			for i=1,ds:size() do
				assert.are.same(ds:get(i), 99)
			end
			assert.are.same(ds:size(), 5)
		end)
	end)
end)
