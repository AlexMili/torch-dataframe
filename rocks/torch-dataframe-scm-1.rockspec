package = "torch-dataframe"
 version = "scm-1"
 source = {
    url = "https://github.com/alexmili/torch-dataframe/archive/master.tar.gz",
    dir = "torch-dataframe-master"
 }
 description = {
    summary = "A Dataframe class for Torch",
    detailed = [[
       Dataframe is a Torch7 class to load and manipulate
       Kaggle-style CSVs inspired from R and pandas Dataframes.
    ]],
    homepage = "https://github.com/alexmili/torch-dataframe",
    license = "MIT/X11",
    maintainer = "AlexMili"
 }
 dependencies = {
    "lua ~> 5.1",
    "torch >= 7.0",
    "luafilesystem >= 1.6.3"
 }
 build = {
  type = 'builtin',
  modules = {
      ["Dataframe.init"] = 'init.lua',
      ["Dataframe.utils"] = 'utils.lua',
      ["Dataframe.main"] = 'main.lua',
      ["Dataframe.Extensions.categorical"] = 'Extensions/categorical.lua',
      ["Dataframe.Extensions.load_batch"] = 'Extensions/load_batch.lua',
      ["Dataframe.Extensions.load_data"] = 'Extensions/load_data.lua',
      ["Dataframe.Extensions.missing_data"] = 'Extensions/missing_data.lua',
      ["Dataframe.Extensions.output"] = 'Extensions/output.lua',
      ["Dataframe.Extensions.save_data"] = 'Extensions/save_data.lua',
      ["Dataframe.Extensions.select_set_update"] = 'Extensions/select_set_update.lua',
      ["Dataframe.Extensions.statistics"] = 'Extensions/statistics.lua'
  }
 }
