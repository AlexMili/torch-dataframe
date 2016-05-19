require "lfs"
local argdoc = require 'argcheck.doc'

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

-- Custom argument checks
local argcheck_file = string.gsub(dataframe_path,"?", "argcheck")
assert(loadfile(argcheck_file))()

-- README file
local readmefile = io.open("Doc/README.md", "w")
readmefile:write("# Documentation\n\n")

-- Documentation
local mainfile = io.open("Doc/main.md", "w")
argdoc.record()

local main_file = string.gsub(dataframe_path,"?", "main")
local Dataframe = assert(loadfile(main_file))()

content = argdoc.stop()
title = content:split("\n")[1]
title = trim(title:gsub("#",""))
readmefile:write("- ["..title.."](main.md)\n")

mainfile:write(content)
mainfile:close()

-- Load all extensions, i.e. .lua files in Extensions directory
ext_path = string.gsub(dataframe_path, "[^/]+$", "") .. "Extensions/"
for extension_file,_ in lfs.dir (ext_path) do
  if (string.match(extension_file, "[.]lua$")) then
    local file = ext_path .. extension_file

    -- Documentation
    local doc_filename = extension_file:gsub(".lua",".md")
    local doc_file = io.open("Doc/"..doc_filename, "w")
    argdoc.record()
    
    assert(loadfile(file))(Dataframe)

    content = argdoc.stop()
    title = content:split("\n")[1]
    title = trim(title:gsub("#",""))
    readmefile:write("- ["..title.."]("..doc_filename..")\n")

    doc_file:write(content)
    doc_file:close()
  end
end


readmefile:close()

