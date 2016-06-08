paths = require 'paths'

local dataframe_path = paths.thisfile():gsub("init.lua$", "?.lua")

-- Make utils available to all
local utils_file = string.gsub(dataframe_path,"?", "utils")
assert(loadfile(utils_file))()

-- Load all helper classes
help_clss_path = string.gsub(dataframe_path, "[^/]+$", "") .. "helper_classes/"
for extension_file,_ in lfs.dir (help_clss_path) do
  if (string.match(extension_file, "[.]lua$")) then
    local file = help_clss_path .. extension_file
    assert(loadfile(file))(help_clss_path)
  end
end

-- Custom argument checks
local argcheck_file = string.gsub(dataframe_path,"?", "argcheck")
assert(loadfile(argcheck_file))()

local main_file = string.gsub(dataframe_path,"?", "main")
local Dataframe = assert(loadfile(main_file))()

-- Load all extensions, i.e. .lua files in Extensions directory
ext_path = string.gsub(dataframe_path, "[^/]+$", "") .. "Extensions/"
for extension_file,_ in lfs.dir (ext_path) do
  if (string.match(extension_file, "[.]lua$")) then
    local file = ext_path .. extension_file
    assert(loadfile(file))(Dataframe)
  end
end

-- Load all sub classes
sub_clss_path = string.gsub(dataframe_path, "[^/]+$", "") .. "sub_classes/"
for sub_file,_ in lfs.dir (sub_clss_path) do
  if (string.match(sub_file, "[.]lua$")) then
    local file = sub_clss_path .. sub_file
    assert(loadfile(file))(Dataframe, sub_clss_path)
  end
end

return Dataframe
