local argcheck = require "argcheck"
local paths = require "paths"

paths.get_sorted_files  = argcheck{
	doc=[[
<a name="paths.get_sorted_lua_files">
### paths.get_sorted_lua_files(@ARGP)

Calls the `paths.files()` with the directory and sorts the files according to
name.

@ARGT

_Return value_: table with sorted file names
]],
	{name="path", type="string",
	 doc="The directory path"},
	{name="match_str", type="string", default="[.]lua$",
	 doc="The file matching string to search for. Defaults to lua file endings."},
	call=function(path, match_str)
	local files = {}
	for f in paths.files(path) do
	  if (f:match(match_str)) then
	    files[#files + 1] = f
	  end
	end

	table.sort(files)

	return files
end}

load_dir_files = argcheck{
  doc=[[
<a name="load_dir_files">
### load_dir_files(ARGP)

Traverses a directory and loads all files within

@ARPT

]],
	{name="path", type="string", doc="The directory"},
  {name="params", type="table", doc="Objects to pass to the files", default={}},
	call = (function()
  -- Hidden variable that makes sure we don't reload files
  local loaded_files = {paths.thisfile()}

  return function(path, params)
    assert(paths.dirp(path), ("The path '%s' isn't a valid directory"):format(path))
    table.insert(params, path)

    local files = paths.get_sorted_files(path)
    for _,file in pairs(files) do
      local file = path .. file

      local already_loaded = false
      for _,fn in ipairs(loaded_files) do
        if (fn == file) then
          already_loaded = true
          break
        end
      end

      if (not already_loaded) then
        assert(loadfile(file))(table.unpack(params))
        table.insert(loaded_files, file)
      end
    end
  end
end)()}
