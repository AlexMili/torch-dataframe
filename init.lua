require 'lfs'

local file_exists = function(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- If we're in development mode the default path should be the current
local dataframe_path = "./?.lua"
local search_4_file = "Extensions/load_batch"
if (not file_exists(string.gsub(dataframe_path, "?", search_4_file))) then
  -- split all paths according to ;
  for path in string.gmatch(package.path, "[^;]+;") do
    -- remove trailing ;
    path = string.sub(path, 1, string.len(path) - 1)
    if (file_exists(string.gsub(path, "?", "Dataframe/" .. search_4_file))) then
      dataframe_path = string.gsub(path, "?", "Dataframe/?")
      break;
    end
  end
  if (dataframe_path == nil) then
    error("Can't find package files in search path: " .. tostring(package.path))
  end
end

-- Make utils available to all
local utils_file = string.gsub(dataframe_path,"?", "utils")
assert(loadfile(utils_file))()

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

return Dataframe
