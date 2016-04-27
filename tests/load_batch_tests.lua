require 'torch'

-- Make sure that directory structure is always the same
require 'lfs'
if (string.match(lfs.currentdir(), "/tests$")) then
  lfs.chdir("..")
end
paths.dofile('init.lua')

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
                             function(row) return torch.Tensor({1, 2}) end,
                             'train')
  tester:eq(data:size(1), 5, "The data has invalid rows")
  tester:eq(data:size(2), 2, "The data has invalid columns")
  tester:eq(label:size(1), 5, "The labels have invalid size")
  a:as_categorical('Gender')
  data, label, names = a:load_batch(5, 0,
                                    function(row) return torch.Tensor({1, 2}) end,
                                    'train')
  tester:eq(data:size(1), 5, "The data with gender has invalid rows")
  tester:eq(data:size(2), 2, "The data with gender has invalid columns")
  tester:eq(label:size(1), 5, "The labels with gender have invalid size")
  tester:eq(names, {'Gender', 'Weight'}, "Invalid names returned")

  data, label = a:load_batch(5, 0,
                             function(row) return torch.Tensor({1, 2}) end,
                             'train')
  tester:eq(data:size(1), 5, "The data with gender has invalid rows")
  tester:eq(data:size(2), 2, "The data with gender has invalid columns")
  tester:eq(label:size(1), 5, "The labels with gender have invalid size")

  local batch_size = 6
  for i=1,10 do
    data, label = a:load_batch(batch_size, (i - 1)*batch_size,
                               function(row) return torch.Tensor({1, 2}) end,
                               'train')
    tester:eq(label:size(1), batch_size, "The labels have invalid size at iteration " .. i)
    tester:eq(data:size(1), batch_size, "The data has invalid size at iteration " .. i)
  end

  data, label = a:load_batch(-1, 0,
                             function(row) return torch.Tensor({1, 2}) end,
                             'train')
  tester:eq(data:size(1), a:batch_size('train'), "Doesn't load all train cases")
  data, label = a:load_batch(-1, 0,
                             function(row) return torch.Tensor({1, 2}) end,
                             'validate')
  tester:eq(data:size(1), a:batch_size('validate'), "Doesn't load all validation cases")
  data, label = a:load_batch(-1, 0,
                             function(row) return torch.Tensor({1, 2}) end,
                             'test')
  tester:eq(data:size(1), a:batch_size('test'), "Doesn't load all test cases")

  data, label = a:load_batch(a:batch_size('train'), 0,
                             function(row) return torch.Tensor({1, 2}) end,
                             'train')
  tester:eq(data:size(1), a:batch_size('train'), "Doesn't load all train cases when max number specified")
  data, label = a:load_batch(a:batch_size('validate'), 0,
                             function(row) return torch.Tensor({1, 2}) end,
                             'validate')
  tester:eq(data:size(1), a:batch_size('validate'), "Doesn't load all validation cases when max number specified")
  data, label = a:load_batch(a:batch_size('test'), 0,
                             function(row) return torch.Tensor({1, 2}) end,
                             'test')
  tester:eq(data:size(1), a:batch_size('test'), "Doesn't load all test cases when max number specified")
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
