local paths = require 'paths'
local dataframe_path = paths.thisfile():gsub("init.lua$", "?.lua")

-- Make utils available to all
local utils_file = string.gsub(dataframe_path,"?", "utils")
assert(loadfile(utils_file))()

-- Custom argument checks
local argcheck_file = string.gsub(dataframe_path,"?", "argcheck")
assert(loadfile(argcheck_file))()

-- Load all helper classes
hlpr_clss_path = string.gsub(dataframe_path, "[^/]+$", "") .. "helper_classes/"
local hlpr_files = paths.get_sorted_files(hlpr_clss_path)
for _,hlpr_file in pairs(hlpr_files) do
  local file = hlpr_clss_path .. hlpr_file
  assert(loadfile(file))(hlpr_clss_path)
end

-- Load the main file
local main_file = string.gsub(dataframe_path,"?", "main")
local Dataframe = assert(loadfile(main_file))()

-- Load all extensions, i.e. .lua files in extensions directory
ext_path = string.gsub(dataframe_path, "[^/]+$", "") .. "extensions/"
local ext_files = paths.get_sorted_files(ext_path)
for _, extension_file in pairs(ext_files) do
  local file = ext_path .. extension_file
  assert(loadfile(file))(Dataframe)
end

-- Load all sub classes
sub_clss_path = string.gsub(dataframe_path, "[^/]+$", "") .. "sub_classes/"
local sub_files = paths.get_sorted_files(sub_clss_path)
for _,sub_file in pairs(sub_files) do
  local file = sub_clss_path .. sub_file
  assert(loadfile(file))(Dataframe, sub_clss_path)
end

return Dataframe
