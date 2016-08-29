# API documentation

- [paths.get_sorted_lua_files(path[, match_str])](#__paths.get_sorted_lua_files(path[, match_str])__)
- [load_dir_files(ARGP)](#load_dir_files)

<a name="__paths.get_sorted_lua_files(path[, match_str])__">
<a name="paths.get_sorted_lua_files">
### paths.get_sorted_lua_files(path[, match_str])

Calls the `paths.files()` with the directory and sorts the files according to
name.

```
({
   path      = string   -- The directory path
  [match_str = string]  -- The file matching string to search for. Defaults to lua file endings. [default=[.]lua$]
})
```

_Return value_: table with sorted file names
<a name="load_dir_files">
### load_dir_files(ARGP)

Traverses a directory and loads all files within

@ARPT

_Return values_:
 1. The files loaded in the processed order
 2. The doc content if `docs` argument was true - otherwise it's an empty table