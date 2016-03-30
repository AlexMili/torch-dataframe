require "../Dataframe"
local df_tests = torch.TestSuite()
local tester = torch.Tester()

table.reduce = function (list, fn)
    local acc
    for k, v in ipairs(list) do
        if 1 == k then
            acc = v
        else
            acc = fn(acc, v)
        end
    end
    return acc
end

function df_tests.csv_test_correct_size()
   local a = Dataframe()
   a:load_csv{path = "simple_short.csv",
              verbose = false}
   tester:eq(a:shape(), {rows=4, cols=3},
     "The simple_short.csv is 4x3")
end

function df_tests.csv_test_integer_column()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:eq(a:get_column('Col A'), {1, 2, 3, 4},
    "The simple_short.csv first column a linspan")
end

function df_tests.csv_test_float_column()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:eq(a:get_column('Col B'), {.2,.3,.4,.5},
    "The simple_short.csv is are a span of floats")
end

function df_tests.csv_test_mixed_column()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:eq(a:get_column('Col C')[1], 1000)
  tester:eq(a:get_column('Col C')[2], 0.1)
  tester:eq(a:get_column('Col C')[3], 9999999999)
  tester:eq(a:get_column('Col C')[4], -222)
end

function df_tests.table_schema()
  local a = Dataframe()
  local first = {1,2,3}
  local second = {"2","1","3"}
  local third = {"2","a","3"}
  a:load_table{data={['firstColumn']=first,
                     ['secondColumn']=second,
                     ['thirdColumn']=third}}
  tester:eq(a.schema["firstColumn"], 'number')
  tester:eq(a.schema["secondColumn"], 'number')
  tester:eq(a.schema["thirdColumn"], 'string')
end


function df_tests.table_test_two_columns()
  local a = Dataframe()
  local first = {1,2,3}
  local second = {"a","b","c"}
  a:load_table{data={['firstColumn']=first,
                     ['secondColumn']=second}}
  tester:eq(a:get_column('firstColumn'), first)
  tester:eq(a:get_column('secondColumn'), second)
end

function df_tests.table_test_trimming()
  local a = Dataframe()
  local first = {1,2,3}
  local second = {"a","b","c"}
  a:load_table{data={['firstColumn   ']=first,
                     ['  secondColumn']=second}}
  tester:eq(a:get_column('firstColumn'), first)
  tester:eq(a:get_column('secondColumn'), second)
end

function df_tests.drop()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  a:drop('Col A')
  tester:assert(not a:has_column('Col A'))
  tester:assert(a:has_column('Col B'))
  tester:assert(a:has_column('Col C'))
  tester:eq(a:shape(), {rows=4, cols=2},
    "The simple_short.csv is 4x3 after drop should be 4x2")
  -- Should cause an error
  --tester:assertError(a:drop('Col A'))

    -- Drop second column
    a:drop('Col B')
    tester:assert(not a:has_column('Col A'))
    tester:assert(not a:has_column('Col B'))
    tester:assert(a:has_column('Col C'))
    tester:eq(a:shape(), {rows=4, cols=1},
      "The simple_short.csv is 4x3 after drop should be 4x1")

    -- All are dropped
    a:drop('Col C')
    tester:eq(a.dataset, {},
      "All columns are dropped")
end

function df_tests.add_column()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  d_col = {0,1,2,3,}
  a:add_column('Col D', d_col)
  tester:ne(a:get_column('Col A'), nil, "Col A should be present")
  tester:ne(a:get_column('Col B'), nil, "Col B should be present")
  tester:ne(a:get_column('Col C'), nil, "Col C should be present")
  tester:eq(a:get_column('Col D'), d_col, "Col D isn't the expected value")
  tester:eq(a:shape(), {rows=4, cols=4},
    "The simple_short.csv is 4x3 after add should be 4x4")

  tester:assertError(a:add_column('Col D'))
end

function df_tests.get_column()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:eq(a:get_column('Col D'), nil)
  tester:ne(a:get_column('Col C'), nil)
end

function df_tests.insert()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  a:insert({['Col A']={15},['Col B']={25},['Col C']={35}})
  tester:eq(a:shape(), {rows=5, cols=3},
    "The simple_short.csv is 4x3 after insert should be 5x3")
end

tester:add(df_tests)
tester:run()
