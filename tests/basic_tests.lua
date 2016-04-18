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

function df_tests.load_table_single_value()
  local a = Dataframe()
  a:load_table{data={['first_column']=3,['second_column']={10,11,12}}}
  tester:assertTableEq(a:get_column("first_column"), {3,3,3})
  tester:assertTableEq(a:get_column("second_column"), {10,11,12})

  a:load_table{data={['first_column']={3,4,5},['second_column']={10,11,12}}}
  tester:assertTableEq(a:get_column("first_column"), {3,4,5})
  tester:assertTableEq(a:get_column("second_column"), {10,11,12})

  tester:assertError(function() a:load_table{data={['first_column']={3,4,5},['second_column']={10,11}}} end)
end

function df_tests.table_schema()
  local a = Dataframe()
  local first = {1,2,3}
  local second = {"2","1","3"}
  local third = {"2","a","3"}
  data = {['firstColumn']=first,
          ['secondColumn']=second,
          ['thirdColumn']=third}
  a:load_table{data=data}
  tester:eq(a.schema["firstColumn"], 'number')
  tester:eq(a.schema["secondColumn"], 'number')
  tester:eq(a.schema["thirdColumn"], 'string')
end

function df_tests.shape()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:eq(a:shape(), {rows = 4, cols = 3})

  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:eq(a:shape(), {rows = 3, cols = 3})

  a:load_table{data = {test = {1,nil,3}}}
  tester:eq(a:shape(), {rows = 3, cols = 1})
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
  d_col = {0,1,2,3}
  a:add_column('Col D', d_col)
  tester:ne(a:get_column('Col A'), nil, "Col A should be present")
  tester:ne(a:get_column('Col B'), nil, "Col B should be present")
  tester:ne(a:get_column('Col C'), nil, "Col C should be present")
  tester:assertTableEq(a:get_column('Col D'), d_col, "Col D isn't the expected value")
  tester:assertTableEq(a:shape(), {rows=4, cols=4},
    "The simple_short.csv is 4x3 after add should be 4x4")

  tester:assertError(a:add_column('Col D'))
  a:add_column('Col E')
  tester:assertTableEq(a:get_column('Col E'), {0,0,0,0})
  a:add_column('Col F', 1)
  tester:assertTableEq(a:get_column('Col F'), {1,1,1,1})
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

function df_tests.reset_column()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  a:reset_column('Col C', 555)
  tester:eq(a:shape(), {rows=4, cols=3},
    "The simple_short.csv is 4x3")
  tester:eq(a:get_column('Col C'), {555, 555, 555, 555})

  a:reset_column({'Col A', 'Col B'}, 555)
  tester:eq(a:get_column('Col A'), {555, 555, 555, 555})
  tester:eq(a:get_column('Col B'), {555, 555, 555, 555})
end

function df_tests.remove_index()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}

  a:remove_index(1)
  tester:eq(a:shape(), {rows=3, cols=3},
    "The simple_short.csv is 4x3")
  tester:eq(a:get_column('Col A'), {2,3,4})

  a:remove_index(1)
  a:remove_index(1)
  a:remove_index(1)
  tester:eq(a:shape(), {rows=0, cols=3})
end

function df_tests.rename_column()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  a:rename_column("Col A", "Col D")
  tester:assert(a:has_column("Col D"))
  tester:assert(not a:has_column("Col A"))
end

function df_tests.count_na_and_fill_na()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:eq(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1})
  a:fill_na("Col A", 1)
  tester:eq(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=1})
  a:fill_na("Col C", 1)
  tester:eq(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})
  tester:eq(a:get_column("Col C"), {8, 1, 9})
end

function df_tests.fill_all_na()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  a.dataset['Col A'][3] = nil
  tester:eq(a:count_na(), {["Col A"]= 1, ["Col B"]= 0, ["Col C"]=1})
  a:fill_all_na(-1)
  tester:eq(a:count_na(), {["Col A"]= 0, ["Col B"]= 0, ["Col C"]=0})
  tester:eq(a:get_column('Col A'), {1,2,-1})
end

function df_tests._get_numerics()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:assert(a:_get_numerics()['Col B'] == nil)
  tester:assert(a:_get_numerics()['Col A'] ~= nil)
  tester:assert(a:_get_numerics()['Col C'] ~= nil)
end

function df_tests.to_tensor()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}

  tnsr = a:to_tensor()
  tester:eq(tnsr:size(1),
            a:shape()["rows"])
  tester:eq(tnsr:size(2),
            a:shape()["cols"])
  sum = 0
  col_no = a:get_column_no('Col A')
  for i=1,tnsr:size(1) do
    sum = math.abs(tnsr[i][col_no] - a:get_column('Col A')[i])
  end
  tester:assert(sum < 10^-5)
end

function df_tests.to_csv()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  a:to_csv{path = "copy_of_short.csv",
           verbose = false}
  local b = Dataframe()
  b:load_csv{path = "copy_of_short.csv",
             verbose = false}
  for k,v in pairs(a.dataset) do
    tester:eq(a:get_column(k),
              b:get_column(k))
  end
  os.remove("copy_of_short.csv")
end

function df_tests.head()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  no_elmnts = 0
  head = a:head(2)
  for k,v in pairs(head) do
    if (#v > no_elmnts) then
      no_elmnts = #v
    end
  end
  tester:eq(no_elmnts, 2)

  -- Only 4 rows and thus all should be included
  no_elmnts = 0
  head = a:head(20)
  for k,v in pairs(head) do
    if (#v > no_elmnts) then
      no_elmnts = #v
    end
  end
  tester:eq(no_elmnts, a:shape()["rows"])

  no_elmnts = 0
  head = a:head()
  for k,v in pairs(head) do
    if (#v > no_elmnts) then
      no_elmnts = #v
    end
  end
  tester:eq(no_elmnts, a:shape()["rows"])
end

function df_tests.tail()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}

  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
            verbose = false}
  no_elmnts = 0
  tail = a:tail(2)
  for k,v in pairs(tail) do
    local l = table.exact_length(v)
    if (l > no_elmnts) then
      no_elmnts = l
    end
  end
  tester:eq(no_elmnts, 2)

  -- Only 4 rows and thus all should be included
  no_elmnts = 0
  tail = a:tail(20)
  for k,v in pairs(tail) do
    local l = table.exact_length(v)
    if (l > no_elmnts) then
      no_elmnts = l
    end
  end
  tester:eq(no_elmnts, a:shape()["rows"])

  no_elmnts = 0
  tail = a:tail()
  for k,v in pairs(tail) do
    local l = table.exact_length(v)
    if (l > no_elmnts) then
      no_elmnts = l
    end
  end
  tester:eq(no_elmnts, a:shape()["rows"])
end

function df_tests.show()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  -- skip test due to inability to redirect output
  -- http://stackoverflow.com/questions/27008723/how-to-redirect-stdout-to-file-in-lua
end

function df_tests.unique()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:assertTableEq(a:unique('Col A'), {1,2,3}, "Failed to match Col A")
  tester:assertTableEq(a:unique('Col B', true), {A=1, B=2}, "Failed to match Col B")
  tester:assertTableEq(a:unique('Col C', true), {[8]=1, [9]=2}, "Failed to match Col C")
end

function df_tests.value_counts()
  local a = Dataframe()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  tester:assertTableEq(a:value_counts('Col A'), {[1] = 1, [2] = 1, [3] = 1}, "Failed to count Col A")
  tester:assertTableEq(a:value_counts('Col B'), {A=1, B=2}, "Failed to count Col B")
  tester:assertTableEq(a:value_counts('Col C'), {[8]=1, [9]=1}, "Failed to count Col C")
end

function df_tests.where()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  local ret_val = a:where('Col A', 2)
  tester:eq(ret_val:get_column("Col A"), {2})
  tester:eq(ret_val:get_column("Col C"), {.1})
  tester:eq(torch.type(ret_val), "Dataframe")
  tester:assertTableEq(ret_val:shape(), {rows = 1, cols = 3})

  local ret_val = a:where('Col A', 222222222)
  tester:assertTableEq(ret_val:shape(), {rows = 0, cols = 0})

  a:__init()
  a:load_csv{path = "advanced_short.csv",
             verbose = false}
  ret_val = a:where('Col B', 'B')
  tester:eq(ret_val:shape(), {rows = 2, cols = 3})
  tester:eq(ret_val:get_column('Col C'), {nil, 9})
  tester:eq(ret_val:get_column('Col A'), {2, 3})
  -- TODO: Should the where B not return two rows or just the first row?
end

function df_tests.update()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  local start_val = a:get_column('Col B')
  start_val[1] = start_val[1] * 2
  a:update(function(s_row)
             return s_row['Col A'] == 1
           end,
           function(upd_row)
             upd_row['Col B'] = upd_row['Col B'] * 2
             return upd_row
           end)
  tester:assertTableEq(a:get_column('Col B'), start_val)

  -- Check a double match
  local b = Dataframe()
  b:load_csv{path = "advanced_short.csv",
             verbose = false}
  start_val = b:get_column('Col A')
  start_val[2] = start_val[2] * 2
  start_val[3] = start_val[3] * 2
  b:update(function(s_row) return s_row['Col B'] == 1 end,
           function(upd_row)
             upd_row['Col A'] = upd_row['Col A'] * 2
             return upd_row
            end)

  tester:assertTableEq(b:get_column('Col A'), start_val)
end

function df_tests.set()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  a:set(1, 'Col A', {['Col A']=99})
  tester:eq(a:get_column('Col A')[1], 99)
end

function df_tests._to_html()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  -- TODO: not sure this is worth the effort
end

function df_tests.get_row()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}
  tester:assertTableEq(a:get_row(1),{
    ['Col A']=1,
    ['Col B']=.2,
    ['Col C']=1000
    })
end

function df_tests._update_single_row()
  local a = Dataframe()
  a:load_csv{path = "simple_short.csv",
             verbose = false}

  new = {
    ['Col A']=4,
    ['Col B']=4,
    ['Col C']=4
  }
	a:_update_single_row(1, new)
  tester:assertTableEq(a:get_row(1), new)
end

tester:add(df_tests)
tester:run()
