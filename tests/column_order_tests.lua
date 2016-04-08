require "../Dataframe"
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
  local first = {1,2,3}
  local second = {"2","1","3"}
  local third = {"2","a","3"}
  local column_order = {[1] = 'firstColumn',
                        [2] = 'secondColumn',
                        [3] = 'thirdColumn'}
  a:load_table{data={['firstColumn']=first,
                     ['secondColumn']=second,
                     ['thirdColumn']=third},
               column_order = column_order}
  tester:eq(a.column_order, column_order)

  column_order[2] = nil
  tester:assertError(a:load_table{data={['firstColumn']=first,
                                       ['secondColumn']=second,
                                       ['thirdColumn']=third},
                                  column_order = column_order} )
end

tester:add(co_tests)
tester:run()
