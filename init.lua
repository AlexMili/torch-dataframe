local Dataframe = require("Dataframe.Dataframe")

local file_exists = function(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local dataframe_path = nil
for path in string.gmatch(package.path, "[^;]+;") do
  -- remove trailing
  path = string.sub(path, 1, string.len(path) - 1)
  if (file_exists(string.gsub(path, "?", "Dataframe/Extensions/load_batch"))) then
    dataframe_path = string.gsub(path, "?", "Dataframe/?")
    break;
  end
end
if (dataframe_path == nil) then
  error("Can't find package files in search path: " .. tostring(package.path))
end

extensions = {"load_batch"}
for _,ext in pairs(extensions) do
  file = string.gsub(dataframe_path,
                     "?",
                     "Extensions/" .. ext)
  assert(loadfile(file))(Dataframe)
end

return Dataframe
