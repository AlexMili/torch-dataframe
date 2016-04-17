-- Make sure that directory structure is always the same
require 'lfs'
if (string.match(lfs.currentdir(), "/tests$")) then
  lfs.chdir("..")
end
paths.dofile('init.lua')

-- Go into tests so that the loading of CSV:s is the same as always
lfs.chdir("tests")


local serialization_tests = torch.TestSuite()
local tester = torch.Tester()

function serialization_tests.simple_serialize()
  local a = Dataframe()
  -- Do not use advanced_short since it has nan that are 0/0 ~= 0/0 == true
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  b = torch.serialize(a)
  c = torch.deserialize(b)
  tester:eq(torch.typename(c), "Dataframe")
  tester:eq(a, c)
end

tester:add(serialization_tests)
tester:run()
