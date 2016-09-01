local paths = require 'paths'
local dataframe_dir = string.gsub(paths.thisfile(), "[^/]+$", "")

-- Custom argument checks
local argcheck_file = dataframe_dir .. "argcheck.lua"
assert(loadfile(argcheck_file))()
-- Custom busted assertions, only needed for running tests
local assert_file = dataframe_dir .. "custom_assertions.lua"
if (paths.filep(assert_file)) then
  assert(loadfile(assert_file))()
end

-- Get the loader funciton and start by making utils available to all
local loader_file = dataframe_dir .. "utils/loader.lua"
assert(loadfile(loader_file))()
load_dir_files(dataframe_dir .. "utils/")

-- Load all helper classes
load_dir_files(dataframe_dir .. "helper_classes/")

-- Load all extensions, i.e. .lua files in extensions directory
load_dir_files(dataframe_dir .. "dataframe/", {Dataframe})

load_dir_files(dataframe_dir .. "dataseries/", {Dataframe})

-- Load all sub classes
load_dir_files(dataframe_dir .. "sub_classes/", {Dataframe})

return Dataframe
