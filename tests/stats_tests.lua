-- Make sure that directory structure is always the same
require 'lfs'
if (string.match(lfs.currentdir(), "/tests$")) then
  lfs.chdir("..")
end
paths.dofile('init.lua')

-- Go into tests so that the loading of CSV:s is the same as always
lfs.chdir("tests")

local stat_tests = torch.TestSuite()
local tester = torch.Tester()

function stat_tests.get_max_value()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:eq(a:get_max_value(), {3, 9})
  a:as_categorical('Col B')
  tester:eq(a:get_max_value(), {3, 2, 9})

  a:as_categorical('Col C')
  tester:eq(a:get_max_value(), {3, 2, 2})

  tester:eq(a:get_max_value('Col A'), 3)
  tester:eq(a:get_max_value('Col B'), 2)
  tester:eq(a:get_max_value('Col C'), 2)

  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:eq(a:get_max_value(), {4, .5, 9999999999})
  tester:eq(a:get_max_value('Col C'), 9999999999)
end

function stat_tests.get_min_value()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:eq(a:get_min_value(), {1, 8}, "Could not identify two numerical min values")
  a:as_categorical('Col B')
  tester:eq(a:get_min_value(), {1, 1, 8}, "Failed to detect min with categorical")

  a:as_categorical('Col C')
  tester:eq(a:get_min_value(), {1, 1, 1}, "Failed to convert numerical to categorical min")

  for _,k in pairs(a.columns) do
    tester:eq(a:get_min_value(k), 1, "The column " .. k .. " should have a min value of 1" ..
                                     " and not " .. a:get_min_value(k))
  end
  a:fill_all_na()
  tester:eq(a:get_min_value('Col C'), 0)
  tester:eq(a:to_tensor()[{2,3}], 0)

  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:eq(a:get_min_value(), {1, .2, -222})
end


tester:add(stat_tests)
tester:run()
