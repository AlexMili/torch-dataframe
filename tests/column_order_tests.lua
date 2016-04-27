require 'torch'

-- Make sure that directory structure is always the same
require 'lfs'
if (string.match(lfs.currentdir(), "/tests$")) then
  lfs.chdir("..")
end
paths.dofile('init.lua')

-- Go into tests so that the loading of CSV:s is the same as always
lfs.chdir("tests")

local co_tests = torch.TestSuite()
local tester = torch.Tester()

function co_tests.csv_check_load_no()
   local a = Dataframe()
   a:load_csv{path = "simple_short.csv",
              verbose = false}
   tester:eq(a.column_order,
            {[1] = "Col A",
             [2] = "Col B",
             [3] = "Col C"},
            "The basic column_order fails to load")
end

function co_tests.table_check_load_no()
  local a = Dataframe()
  local first  = {1,2,3}
  local second = {"2","1","3"}
  local third  = {"2","a","3"}
  local column_order =
    {[1] = 'firstColumn',
                        [2] = 'secondColumn',
                        [3] = 'thirdColumn'}
  local data = {['firstColumn']=first,
                 ['secondColumn']=second,
                 ['thirdColumn']=third}
  a:load_table{data=data,
               column_order = column_order}
  tester:eq(a.column_order, column_order)

  column_order[2] = nil
  tester:assertError(function()
                    a:load_table{data=data,
                                 column_order = column_order}
                    end)
end

function co_tests.sub()
   local a = Dataframe()
   a:load_csv{path = "simple_short.csv",
              verbose = false}

   local org_shape = a:shape()
   tester:eq(a:sub():shape(),
             org_shape)
   org_shape["rows"] = org_shape["rows"] - 1
   tester:eq(a:sub(1, 3):shape(),
             org_shape)
   tester:eq(a:sub(2, 4):shape(),
             org_shape)
   tester:eq(a:sub(2, 4):get_column("Col A")[1], 2)
end

function co_tests.to_csv()
  local a = Dataframe()
  local first = {1,2,3}
  local second = {"Wow this it's tricky","1,2","323."}
  local third = {"\"","a\"a","3"}
  data = {['firstColumn']=first,
          ['secondColumn']=second,
          ['thirdColumn']=third}
  c_order = {[1] = "firstColumn",
             [4] = "secondColumn",
             [3] = "thirdColumn"}
  tester:assertError(function()   a:load_table{data=data, column_order=c_order} end)
  c_order = {[1] = "firstColumn",
             [3] = "thirdColumn"}
  tester:assertError(function()   a:load_table{data=data, column_order=c_order} end)
  c_order = {[1] = "firstColumn",
             [2] = "secondColumn",
             [3] = "thirdColumn"}
  a:load_table{data=data, column_order=c_order}
  a:to_csv{path = "tricky_csv.csv"}
  a:load_csv{path = "tricky_csv.csv", verbose = false}
  tester:assertTableEq(a.dataset, data)
  tester:assertTableEq(a.column_order, c_order)
  os.remove("tricky_csv.csv")
end

function co_tests.to_tensor()
  local a = Dataframe()
  local first = {1,2,3}
  local second = {"A","B","323."}
  local third = 2.2
  data = {['1st']=first,
          ['2nd']=second,
          ['3rd']=third}
  c_order = {[1] = "1st",
             [2] = "2nd",
             [3] = "3rd"}
  a:load_table{data=data, column_order=c_order}
  tnsr = a:to_tensor()
  tester:eq(tnsr:size(1),
            a:shape()["rows"])
  tester:eq(tnsr:size(2),
            a:shape()["cols"] - 1)
  sum = 0
  col_no = a:get_column_no{column_name='1st', as_tensor = true}
  for i=1,tnsr:size(1) do
    sum = math.abs(tnsr[i][col_no] - a:get_column('1st')[i])
  end
  tester:assert(sum < 10^-5)

  sum = 0
  col_no = a:get_column_no{column_name='3rd', as_tensor = true}
  for i=1,tnsr:size(1) do
    sum = math.abs(tnsr[i][col_no] - a:get_column('3rd')[i])
  end
  tester:assert(sum < 10^-5)

  tester:eq(a:get_column_no{'2nd', as_tensor = true}, nil)
end


tester:add(co_tests)
tester:run()
