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

function batch_tests.load_batch()
  local a = Dataframe()
  a:load_csv{path = "realistic_29_row_data.csv",
            verbose = false}
  tester:assertError(function() a:load_batch() end,
                     "Should force a call to init_batch")
  a:init_batch()
  data, label = a:load_batch(5, 0,
                             function(row) return torch.Tensor({{1, 2}}) end,
                             'train')
  tester:eq(data:size()[1], 5, "The data has invalid rows")
  tester:eq(data:size()[2], 2, "The data has invalid columns")
  tester:eq(label:size()[1], 5, "The labels have invalid size")
  a:as_categorical('Gender')
  data, label = a:load_batch(5, 0,
                             function(row) return torch.Tensor({{1, 2}}) end,
                             'train')
  tester:eq(data:size()[1], 5, "The data with gender has invalid rows")
  tester:eq(data:size()[2], 2, "The data with gender has invalid columns")
  tester:eq(label:size()[1], 5, "The labels with gender have invalid size")
end

function batch_tests.init_batch()
  local a = Dataframe()
  a:load_csv{path = "realistic_29_row_data.csv",
            verbose = false}
  tester:assertError(function() a:load_batch() end,
                     "Should force a call to init_batch")
  torch.manualSeed(0)
  a:init_batch()
  order = 0
  for i = 2,#a.batch.datasets["train"] do
    order = order + a.batch.datasets["train"][i] - a.batch.datasets["train"][i - 1] - 1
  end
  tester:ne(order, 0)

  a:init_batch{shuffle = false}
  order = 0
  for i = 2,#a.batch.datasets["train"] do
    order = order + a.batch.datasets["train"][i] - a.batch.datasets["train"][i - 1] - 1
  end
  tester:eq(order, 0)
end

tester:add(batch_tests)
tester:run()
