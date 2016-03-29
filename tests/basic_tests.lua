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

function df_tests.count_na()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  for k, v in pairs(a:count_na()) do
    tester:eq(v, 0, "Not expecting missing data in col. " .. k)
  end
  local b = Dataframe()
  b:load_csv{path = "advanced_short.csv",
             verbose = false}
  local no_missing = 0
  for k, v in pairs(b:count_na()) do
    no_missing = no_missing + v
  end
  tester:eq(no_missing, 1, "Expecting 1 missing in the advanced_short")
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

tester:add(df_tests)
tester:run()
