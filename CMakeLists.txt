cmake_minimum_required (VERSION 2.8)
cmake_policy(VERSION 2.8)

set(PKGNAME Dataframe)

file(GLOB_RECURSE luafiles RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.lua")

# Exclude doc helpers and spec files
set (EXCLUDE_DIRS "utils/doc_helpers/" "specs/")
list(REMOVE_ITEM luafiles "custom_assertions.lua")

foreach (TMP_PATH ${luafiles})

  foreach (EXCLUDE_DIR ${EXCLUDE_DIRS})
    string (FIND ${TMP_PATH} ${EXCLUDE_DIR} EXCLUDE_DIR_FOUND)
    if (NOT ${EXCLUDE_DIR_FOUND} EQUAL -1)
      MESSAGE("Removing ${TMP_PATH}")
      list (REMOVE_ITEM luafiles ${TMP_PATH})
    endif ()
  endforeach(EXCLUDE_DIR)

endforeach(TMP_PATH)

foreach(file ${luafiles})
  get_filename_component(dir ${file} PATH)
  install(FILES ${file} DESTINATION ${LUA_PATH}/${PKGNAME}/${dir})
endforeach()
