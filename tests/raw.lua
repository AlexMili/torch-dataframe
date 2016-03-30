require "../Dataframe"
local a = Dataframe()
a:load_csv{path = "simple_short.csv",
           verbose = false}
d_col = {0,1,2,3,}
print(a:has_column('Col D'))
print(a:has_column('Col C'))
a:add_column('Col D', d_col)
print(a:head())
