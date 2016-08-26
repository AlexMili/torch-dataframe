require 'lfs'

-- Make sure that directory structure is always the same
if (string.match(lfs.currentdir(), "/specs$")) then
  lfs.chdir("..")
end

-- Include Dataframe lib
dofile('init.lua')

-- Go into specs so that the loading of CSV:s is the same as always
lfs.chdir("specs")

describe("#Core Datseries functions", function()
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
	end)

	describe("#missing", function()
		it("nil should become missing", function()
			local ds = Dataseries{data = Df_Array(true, 0/0, false)}
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), true)
			assert.is_true(isnan(ds:get(2)))
			assert.are.same(ds:get(3), false)
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("empty string should not become missing", function()
			local ds = Dataseries{data = Df_Array(true, "", false)}
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), true)
			assert.is_false(isnan(ds:get(2)))
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
			assert.is_false(isnan(ds:get(2)))
			assert.are.same(ds:type(), "tds.Vec")
		end)

		it("expanding a series should fill with missing", function()
			local ds = Dataseries{data = Df_Array(1,2)}
			ds:resize(3)
			assert.are.same(ds:size(), 3)
			assert.are.same(ds:get(1), 1)
			assert.are.same(ds:get(2), 2)
			assert.is_true(isnan(ds:get(3)))
			ds:set(3, 45)
			assert.are.same(ds:get(3), 45)
			assert.are.same(ds:type(), "torch.IntTensor")
		end)
	end)
end)

describe("Metatable functions", function()
	describe("The __index__", function()
		it("Basic index retrieval test", function()
			local ds = Dataseries(Df_Array(4,0/0,3))
			assert.are.same(ds[1], 4)
			assert.is_true(isnan(ds[2]))
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
			assert.is_true(isnan(sub[2]))
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
			assert.is_true(isnan(ds[3]))
		end)
	end)

	describe("The __len__ #skip_version_LUA51", function()
		it("Basic # length test", function()
			local ds = Dataseries(Df_Array(4,0/0,3))
			assert.are.same(#ds, 3)
		end)
	end)
end)
