require 'torch'

-- Make sure that directory structure is always the same
require 'lfs'
if (string.match(lfs.currentdir(), "/tests$")) then
  lfs.chdir("..")
end
paths.dofile('init.lua')

-- Go into tests so that the loading of CSV:s is the same as always
lfs.chdir("tests")

local cat_tests = torch.TestSuite()
local tester = torch.Tester()

function cat_tests.as_is_categorical()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:assert(not a:is_numerical('Col B'), "Column should not be a numerical")
  a:as_categorical('Col B')
  tester:eq(a:get_cat_keys('Col B'), {A=1, B=2})
  tester:assert(a:is_categorical('Col B'))
  tester:assert(a:is_numerical('Col B'), "Column not converted properly to numerical")

  a:as_categorical('Col C')
  tester:eq(a:get_cat_keys('Col C'), {[8] = 1, [9] = 2},
            "Numerical columns should be translated into a int linspace.")
  tester:assert(a:is_categorical('Col C'))
  tester:assert(not a:is_categorical('Col A'))
end

function cat_tests.to_categorical()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:eq(a:to_categorical{data=1, column_name='Col B'}, 'A')
  tester:eq(a:to_categorical(2, 'Col B'), 'B')
  tester:assert(isnan(a:to_categorical(0/0, 'Col B')))
  tester:eq(a:to_categorical({2, 1}, 'Col B'), {'B', 'A'},
            "Failed to handle table input")
  tester:eq(a:to_categorical(torch.Tensor({1,2}), 'Col B'), {'A', 'B'},
            "Failed to handle Tenso input")
  tester:assertError(function() a:to_categorical(3, 'Col B') end,
                     "Can't convert to a categorical value outside range")
  tester:assertError(function() a:to_categorical(1, 'Col A') end,
                     "Can't convert a non-categorical value")

end

function cat_tests.from_categorical()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:eq(a:from_categorical('A', 'Col B'), {1})
  tester:eq(a:from_categorical('B', 'Col B'), {2})
  tester:eq(a:from_categorical({'A', 'B'}, 'Col B'),
            {1, 2},
            "Can't handle table input")
  tester:eq(a:from_categorical{data = {'A', 'B'},
                               column_name = 'Col B',
                               as_tensor = true},
            torch.Tensor({1, 2}),
            "Can't handle tensor output")
  tester:assert(isnan(a:from_categorical('C', 'Col B')[1]))
  tester:assertError(function() a:from_categorical('A', 'Col A') end,
                     "The column isn't a categorical")
end

function cat_tests.get_column()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:eq(a:get_column('Col B'), {'A', 'B', 'B'}, "Failed to retrieve categorical representations")
  tester:eq(a:get_column('Col B', true), {1,2,2}, "Failed to retrieve raw representations")
  tester:eq(a:get_column{column_name = 'Col B',
                         as_raw = true},
            {1, 2, 2},
            "Failed to return numbers instead of strings for categorical column")
  tester:eq(a:get_column{column_name = 'Col B',
                         as_tensor = true},
            torch.Tensor({1, 2, 2}),
            "Failed to return a tensor from categorical column")


  true_vals = {"TRUE", "FALSE", "TRUE"}
  a:load_table{data={['Col A']=true_vals,['Col B']={10,11,12}}}
  a:as_categorical('Col A')
  tester:eq(a:get_column('Col A'), true_vals)
end

function cat_tests.unique()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:eq(a:unique('Col B'), {'A', 'B'}, "Failed to get categorical data")
  tester:eq(a:unique{column_name = 'Col B',
                     as_raw = true},
            {1, 2},
            "Failed to get raw data")
  tester:eq(a:unique{column_name ='Col B',
                     as_keys = true},
            {['A'] = 1, ['B'] = 2},
            "Failed to get data as keys")
   tester:eq(a:unique{column_name ='Col B',
                      as_keys = true,
                      as_raw = true},
             {[1] = 1, [2] = 2},
             "Failed to get raw data as keys")
end

function cat_tests.insert()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  local new_data = {["Col A"] = 1,
                    ["Col B"] = "C",
                    ["Col C"] = 10}
  a:insert(new_data)
  tester:eq(a:get_cat_keys('Col B'), {A=1, B=2, C=3})
end

function cat_tests.update()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:update(function(row) return row['Col A'] == 3 end,
           function(row)
             row['Col B'] = 'C'
             return row
           end)
  tester:eq(a:get_column('Col B'), {'A', 'B', 'C'},
            "Should be A,B,C")
  tester:eq(a:get_cat_keys('Col B'), {A=1, B=2, C=3},
            "Expected 3 keys after changing the last key")

  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:update(function(row) return row['Col B'] == 'B' end,
           function(row)
             row['Col B'] = 'A'
             return row
           end)
  tester:eq(a:get_column('Col B'), {'A', 'A', 'A'},
            "All should be A's")

  tester:eq(a:get_cat_keys('Col B'), {A=1, B=2},
            "Keys should not be removed without prompting")

  a:clean_categorical('Col B')
  tester:eq(a:get_cat_keys('Col B'), {A=1},
            "Keys should be removed after calling clean_categorical")

  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:update(function(row) return row['Col B'] == 'B' end,
           function(row)
             row['Col B'] = 'A'
             return row
           end)
  a:clean_categorical('Col B', true)
  tester:eq(a:get_cat_keys('Col B'), {A=1},
           "Keys should be removed after calling clean_categorical with resetting")

  a:load_csv{path = "advanced_short.csv",
            verbose = false}
  a:as_categorical('Col B')
  a:as_categorical('Col C')
  a:update(function(row) return row['Col A'] == 3 end,
          function(row)
            row['Col B'] = 0/0
            return row
          end)
  tester:assert(isnan(a:get_column('Col B')[3]),
            "The nan should be saved as such")
  tester:assert(isnan(a:get_column('Col C')[2]),
            "The nan should be untouched")
end

function cat_tests.set()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:set('A', 'Col B', {['Col B'] = 'C'})
  tester:eq(a:get_cat_keys('Col B'), {A=1, B=2, C=3})

  a:set('C', 'Col B', {['Col B'] = 'B'})
  tester:eq(a:get_cat_keys('Col B'), {A=1, B=2, C=3})
  a:clean_categorical('Col B')
  tester:eq(a:get_cat_keys('Col B'), {B=2})

  a:clean_categorical('Col B', true)
  tester:eq(a:get_cat_keys('Col B'), {B=1})
end

function cat_tests.drop_and_refresh_meta()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:drop('Col B')
  tester:eq(a.categorical['Col B'], nil)

  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:drop('Col A')
  tester:assert(a:is_categorical('Col B'))
end

function cat_tests.load()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:assert(not a:is_categorical('Col B'))
  a:as_categorical('Col B')
  tester:assert(a:is_categorical('Col B'))

  a:load_table{data={['Col A']="3",['Col B']={10,11,12}}}
  tester:assert(not a:is_categorical('Col B'))
  a:as_categorical('Col A')
  tester:assert(a:is_categorical('Col A'))
end

function cat_tests.rename_column()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:assert(a:is_categorical('Col B'))
  a:rename_column('Col B', 'Alt col B')
  tester:assertError(function() a:is_categorical('Col B') end)
  tester:assert(a:is_categorical('Alt col B'))
end

function cat_tests.where()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  local ret_val = a:where('Col B', 'A')
  tester:eq(ret_val:shape(), {rows = 1, cols = 3})
  tester:eq(ret_val:from_categorical({'A', 'B'}, 'Col B'),
            {1, 2},
            "The categorical values shouldn't change due to subsetting")

  ret_val = a:where('Col B', 'B')
  tester:eq(ret_val:shape(), {rows = 2, cols = 3})

  local new_data = {["Col A"] = 1,
                    ["Col B"] = "C",
                    ["Col C"] = 10}
  ret_val:insert(new_data)
  tester:eq(ret_val:from_categorical({'A', 'B', 'C'}, 'Col B'),
            {1, 2, 3},
            "The categorical should add the new value as the last number")

  ret_val = a:where('Col B', 'A')
  tester:eq(ret_val:shape(), {rows = 1, cols = 3})
end

function cat_tests.sub()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  local ret_val = a:sub(1,2)
  tester:eq(ret_val:shape(), {rows = 2, cols = 3})

  a:add_column("Col D", {0/0, "B", "C"})
  ret_val = a:sub(1,2)
  tester:assert(isnan(ret_val:get_column('Col D')[1]), "Should retain nan value")
  tester:eq(ret_val:get_column('Col D')[2], 'B', "Should retain string value")
end

function cat_tests.value_counts()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  local ret = a:value_counts('Col B')
  tester:eq(ret["B"],2)
  tester:eq(ret["A"],1)
  local ret = a:value_counts('Col A')
  tester:eq(ret, {[1] = 1,
                  [2] = 1,
                  [3] = 1})
  a:as_categorical('Col A')
  local ret = a:value_counts('Col A')
  tester:eq(ret, {[1] = 1,
                  [2] = 1,
                  [3] = 1})
  local ret = a:value_counts('Col C')
  tester:eq(ret, {[8] = 1,
                  [9] = 1})
  a:as_categorical('Col C')
  local ret = a:value_counts('Col C')
  tester:eq(ret, {[8] = 1,
                  [9] = 1})
end

function cat_tests.to_tensor()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}

  tnsr = a:to_tensor()
  tester:eq(tnsr:size(1),
            a:shape()["rows"],
            "Incorrect number of rows, expecting " .. a:shape()["rows"] ..
            " but got " ..tnsr:size(1))
  tester:eq(tnsr:size(2),
            a:shape()["cols"] - 1,
            "Incorrect number of columns, expecting " .. a:shape()["cols"] - 1 ..
            " but got " .. tnsr:size(2))
  sum = 0
  col_no = a:get_column_no('Col A')
  for i=1,tnsr:size(1) do
    sum = math.abs(tnsr[i][col_no] - a:get_column('Col A')[i])
  end
  tester:assert(sum < 1e-5, "The difference between the columns should be < 10^-5, it is currently " .. sum)

  a:as_categorical('Col B')
  tnsr = a:to_tensor()
  tester:eq(tnsr:size(1),
            a:shape()["rows"],
            "Incorrect number of rows, expecting " .. a:shape()["rows"] ..
            " but got " ..tnsr:size(1) )
  tester:eq(tnsr:size(2),
            a:shape()["cols"],
            "Incorrect number of columns, expecting " .. a:shape()["cols"] - 1 ..
            " but got " .. tnsr:size(2))
  sum = 0
  col_no = a:get_column_no('Col A')
  for i=1,tnsr:size(1) do
    sum = math.abs(tnsr[i][col_no] - a:get_column('Col A')[i])
  end
  tester:assert(sum < 1e-5, "The difference between the columns should be < 10^-5, it is currently " .. sum)
end

tester:add(cat_tests)
tester:run()
