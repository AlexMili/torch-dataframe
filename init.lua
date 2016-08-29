local paths = require 'paths'
local dataframe_path = paths.thisfile():gsub("init.lua$", "?.lua")
local dataframe_dir = string.gsub(dataframe_path, "[^/]+$", "")

-- Custom argument checks
local argcheck_file = string.gsub(dataframe_path,"?", "argcheck")
assert(loadfile(argcheck_file))()
-- Custom busted assertions, only needed for running tests
local assert_file = string.gsub(dataframe_path,"?", "custom_assertions")
if (paths.filep(assert_file)) then
  assert(loadfile(assert_file))()
end

-- Get the loader funciton and start by making utils available to all
local loader_file = string.gsub(dataframe_path,"?", "utils/loader")
assert(loadfile(loader_file))()
load_dir_files(dataframe_dir .. "utils/")

-- Load all helper classes
load_dir_files(dataframe_dir .. "helper_classes/")

-- Load the main file
local main_file = string.gsub(dataframe_path,"?", "main")
local Dataframe = assert(loadfile(main_file))()

-- Load all extensions, i.e. .lua files in extensions directory
load_dir_files(dataframe_dir .. "extensions/", {Dataframe})

load_dir_files(dataframe_dir .. "dataseries/", {Dataframe})

-- Load all sub classes
load_dir_files(dataframe_dir .. "sub_classes/", {Dataframe})

return Dataframe
