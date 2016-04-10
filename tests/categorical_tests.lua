require "../Dataframe"
local cat_tests = torch.TestSuite()
local tester = torch.Tester()

function cat_tests.as_categorical()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:assertError(function() a:as_categorical('Col A') end,
                     "Numeric columns should not be able to convert to categorical")
  a:as_categorical('Col B')
  tester:eq(a:get_catkeys('Col B'), {A=1, B=2})
end

function cat_tests.to_categorical()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:eq(a:to_categorical(1, 'Col B'), 'A')
  tester:eq(a:to_categorical(2, 'Col B'), 'B')
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
  tester:eq(a:from_categorical('A', 'Col B'), 1)
  tester:eq(a:from_categorical('B', 'Col B'), 2)
  tester:eq(a:from_categorical({'A', 'B'}, 'Col B'),
            {1, 2},
            "Can't handle table input")
  tester:eq(a:from_categorical{data = {'A', 'B'},
                               column = 'Col B',
                               as_tensor = true},
            torch.Tensor({1, 2}),
            "Can't handle tensor output")
  tester:assertError(function() a:from_categorical('C', 'Col B') end,
                     "Can't convert a string not defined in the schema")
  tester:assertError(function() a:from_categorical('A', 'Col A') end,
                     "The column isn't a categorical")
end

function cat_tests.insert()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  local new_data = {["Col A"] = 1,
                    ["Col B"] = "C",
                    ["Col C"] = 10}
  a:as_categorical('Col B')
  a:insert(new_data)
  tester:eq(a:get_catkeys('Col B'), {A=1, B=2, C=3})
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
  tester:eq(a:get_catkeys('Col B'), {A=1, B=2, C=3})

  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:update(function(row) return row['Col B'] == 'B' end,
           function(row)
             row['Col B'] = 'A'
             return row
           end)
  tester:eq(a:get_catkeys('Col B'), {A=1})
end

function cat_tests.set()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  a:set(3, 'Col B', {['Col B'] = 'C'})
  tester:eq(a:get_catkeys('Col B'), {A=1, B=2, C=3})

  a:set(3, 'Col B', {['Col B'] = 'B'})
  tester:eq(a:get_catkeys('Col B'), {A=1, B=2})

  a:set(1, 'Col B', {['Col B'] = 'B'})
  tester:eq(a:get_catkeys('Col B'), {B=2})
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
  tester:eq(a.categorical['Col B'] ~= nil)
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

function cat_tests.get_column()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:eq(a:get_column('Col B'), {'A', 'B', 'B'})
  tester:eq(a:get_column{column = 'Col B',
                         categorical_as_string = false},
            {1, 2, 2},
            "Failed to return numbers instead of strings for categorical column")
  tester:eq(a:get_column{column = 'Col B',
                         as_tensor = true},
            torch.Tensor({1, 2, 2}),
            "Failed to return a tensor from categorical column")

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

function cat_tests.unique()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  tester:assert(a:unique('Col B'), {'A', 'B'})
  tester:assert(a:unique{'Col B', categorical_as_string = false},
                {1, 2})
  tester:assert(a:unique{'Col B',
                         as_keys = true,
                         categorical_as_string = false},
                {['A'] = 1, ['B'] = 2})
end

function cat_tests.where()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a:as_categorical('Col B')
  local ret_val = a:where('Col B', 'B')
  tester:eq(ret_val:shape(), {rows = 2, cols = 3})

  ret_val = a:where('Col B', 'A')
  tester:eq(ret_val:shape(), {rows = 1, cols = 3})
end

tester:add(cat_tests)
tester:run()
