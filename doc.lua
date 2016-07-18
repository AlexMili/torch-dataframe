local argdoc = require 'argcheck.doc'
local paths = require 'paths'

local dataframe_path = paths.thisfile():gsub("doc.lua$", "?.lua")

-- Make utils available to all
local utils_file = string.gsub(dataframe_path,"?", "utils")
assert(loadfile(utils_file))()

-- Custom argument checks
local argcheck_file = string.gsub(dataframe_path,"?", "argcheck")
assert(loadfile(argcheck_file))()

-- README file
if (not paths.dirp("doc")) then
  paths.mkdir("doc")
end
local readmefile = io.open("doc/README.md", "w")
readmefile:write("# Documentation\n")
readmefile:write([[

This documentation ha been auto-generated from code using the `argcheck` system.

]])

-- Documentation
readmefile:write("## Dataframe\n\n")
local mainfile = io.open("doc/main.md", "w")
argdoc.record()

local main_file = string.gsub(dataframe_path,"?", "main")
local Dataframe = assert(loadfile(main_file))()

content = argdoc.stop()
title = content:split("\n")[1]
title = trim(title:gsub("#",""))
readmefile:write("- ["..title.."](main.md)\n")

mainfile:write(content)
mainfile:close()

-- Load all extensions, i.e. .lua files in extensions directory
ext_path = string.gsub(dataframe_path, "[^/]+$", "") .. "extensions/"
local ext_files = paths.get_sorted_files(ext_path)

for _, extension_file in pairs(ext_files) do
  if (string.match(extension_file, "[.]lua$")) then
    local file = ext_path .. extension_file

    -- Documentation
    local doc_filename = extension_file:gsub(".lua",".md")
    local doc_file = io.open("doc/"..doc_filename, "w")
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

readmefile:write("\n## Child classes\n\n")

-- Load all extensions, i.e. .lua files in extensions directory
sub_clss_path = string.gsub(dataframe_path, "[^/]+$", "") .. "sub_classes/"
local sub_files = paths.get_sorted_files(sub_clss_path)

for _, sub_file in pairs(sub_files) do
  if (string.match(sub_file, "[.]lua$")) then
    local file = sub_clss_path .. sub_file

    -- Documentation
    local doc_filename = sub_file:gsub(".lua",".md")
    local doc_file = io.open("doc/"..doc_filename, "w")
    argdoc.record()

    assert(loadfile(file))(Dataframe, sub_clss_path)

    content = argdoc.stop()
    title = content:split("\n")[1]
    title = trim(title:gsub("#",""))
    readmefile:write("- ["..title.."]("..doc_filename..")\n")

    doc_file:write(content)
    doc_file:close()
  end
end


readmefile:write("\n## Helper classes\n\n")

-- Load all extensions, i.e. .lua files in extensions directory
local hlpr_clss_path = string.gsub(dataframe_path, "[^/]+$", "") .. "helper_classes/"
local hlpr_files = paths.get_sorted_files(hlpr_clss_path)

for _,hlpr_file in pairs(hlpr_files) do
  if (string.match(hlpr_file, "[.]lua$")) then
    local file = hlpr_clss_path .. hlpr_file

    -- Documentation
    local doc_filename = hlpr_file:gsub(".lua",".md")
    local doc_file = io.open("doc/"..doc_filename, "w")
    argdoc.record()

    assert(loadfile(file))()

    content = argdoc.stop()
    title = content:split("\n")[1]
    title = trim(title:gsub("#",""))
    readmefile:write("- ["..title.."]("..doc_filename..")\n")

    doc_file:write(content)
    doc_file:close()
  end
end

readmefile:close()
