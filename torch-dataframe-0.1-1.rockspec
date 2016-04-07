package = "torch-dataframe"
 version = "0.1-1"
 source = {
    url = "git://github.com/alexmili/torch-dataframe"
 }
 description = {
    summary = "A Dataframe class for Torch",
    detailed = [[
       Dataframe is a Torch7 class to load and manipulate
       Kaggle-style CSVs inspired from R and pandas Dataframes.
    ]],
    homepage = "https://github.com/alexmili/torch-dataframe",
    license = "MIT/X11",
    maintainer = "Alex Mili"
 }
 dependencies = {
    "lua ~> 5.1",
    "torch >= 7.0"
 }
 build = {
  type = 'builtin',
  modules = {
      ["Dataframe"] = 'Dataframe.lua',
  }
 }
