-- Make sure that directory structure is always the same
require('lfs')
if (string.match(lfs.currentdir(), "/test$")) then
  lfs.chdir("..")
end
require('init')

-- Go into tests so that the loading of CSV:s is the same as always
lfs.chdir("tests")

local batch_tests = torch.TestSuite()
local tester = torch.Tester()

function batch_tests.csv_check_load_no()
  local a = Dataframe()
  a:load_csv{path = "realistic_29_row_data.csv",
            verbose = false}
  a:load_batch()
end

tester:add(batch_tests)
tester:run()
