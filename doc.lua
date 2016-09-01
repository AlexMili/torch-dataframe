local argdoc = require 'argcheck.doc'
local paths = require 'paths'

local dataframe_path = paths.thisfile():gsub("doc.lua$", "?.lua")
local dataframe_dir = string.gsub(dataframe_path, "[^/]+$", "")

-- Custom argument checks
local argcheck_file = string.gsub(dataframe_path,"?", "argcheck")
assert(loadfile(argcheck_file))()

-- Get the core loader function
local loader_file = string.gsub(dataframe_path,"?", "utils/loader")
assert(loadfile(loader_file))()

load_dir_files(dataframe_dir .. "utils/doc_helpers/")

--[[
The doc.lua loads everything in the same order as the init script. As
we want to later link the scripts has three sections:

1. Load the scripts and store the full docs in the docs table. The file order is
   retained via the files table.
2. Parse the files in the apropriate order and generate a table of content for exact_length
   file that is written to the doc folder with the same name as the file but with
	 `md` as file ending.
3. Merge all the table of contents data into the README so that the docs are
   easier to navigate.
]]
local docs = {}
local files = {}
files.utils, docs.utils = load_dir_files{
	path = dataframe_dir .. "utils/",
	docs = true
}

files.helper_classes, docs.helper_classes = load_dir_files{
	path = dataframe_dir .. "helper_classes/",
	docs = true
}

files.dataseries, docs.dataseries = load_dir_files{
	path = dataframe_dir .. "dataseries/",
	docs = true
}

files.core, docs.core = load_dir_files{
	path = dataframe_dir .. "dataframe/",
	docs = true
}

files.sub_classes, docs.sub_classes =
	-- Load all sub classes
	load_dir_files{
		path = dataframe_dir .. "sub_classes/",
		params = {Dataframe},
		docs = true
	}

--[[
!!! Start section 2 !!!
Parse each group, create a directory for that group, parse all files and write an
MD for each file. Then add a Readme for that directory.
]]

local parsed_docs = {}
local doc_path = "doc"
if (not paths.dirp(doc_path)) then
	paths.mkdir(doc_path)
end

local rough_toc_tbl = {}
local detailed_toc_tbl = {}
for group_name,group in pairs(docs) do
	local sub_doc_path = ("%s/%s/"):format(doc_path,group_name)
	if (not paths.dirp(sub_doc_path)) then
		paths.mkdir(sub_doc_path)
	end

	local grp_rough_toc = ""
	local grp_detailed_toc = ""
	local gnrl_rough_toc = ""
	local gnrl_detailed_toc = ""

	parsed_docs[group_name] = {}
	for _,file_name in ipairs(files[group_name]) do
		local base_fn = paths.basename(file_name)
		local md_path = ("%s%s"):format(sub_doc_path,
		                                base_fn:gsub("%.lua$", ".md"))

		parsed_docs[group_name][base_fn] = parse_doc(group[file_name], base_fn)
		local pd = parsed_docs[group_name][base_fn]
		write_doc(pd,
		          md_path)

		grp_rough_toc, grp_detailed_toc =
		 	get_doc_anchors(sub_doc_path, md_path, pd, grp_rough_toc, grp_detailed_toc)
		gnrl_rough_toc, gnrl_detailed_toc =
		 	get_doc_anchors(doc_path, md_path, pd, gnrl_rough_toc, gnrl_detailed_toc)
	end

	local readmefile = io.open(sub_doc_path .. "README.md", "w")
	readmefile:write(([[# Documentation for %s

This documentation ha been auto-generated from code using the `argcheck` system.

## Table of contents (file-level)

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.

%s

## Detailed table of contents (file-level + anchors)<a name=\"detailed\">

%s]]):format(group_name:gsub("_", " "), grp_rough_toc, grp_detailed_toc))

	-- Save the group TOCS for the general README
	rough_toc_tbl[group_name] = gnrl_rough_toc
	detailed_toc_tbl[group_name] = gnrl_detailed_toc
end

local readmefile = io.open("doc/README.md", "w")
readmefile:write(([[# Documentation for torch-dataframe

This documentation ha been auto-generated from code using the `argcheck` system.

Below follows a more [detailed](#detailed) table of contents with links to
the different functions. Not this list may be incompleted due to failure to
add apropriate anchor tags during documentation.

## Dataframe core components

%s

## Dataseries - Dataframe's data storage

%s

## Dataframe sub-classes

%s

## Helper classes

%s]]):format(rough_toc_tbl["core"],
             rough_toc_tbl["dataseries"],
             rough_toc_tbl["sub_classes"],
             rough_toc_tbl["helper_classes"]))

detailed_toc = ([[

# Detailed table of contents (file-level + anchors)<a name=\"detailed\">

## Dataframe core components

%s

## Dataseries - Dataframe's data storage

%s

## Dataframe sub-classes

%s

## Helper classes

%s]]):format(detailed_toc_tbl["core"],
             detailed_toc_tbl["dataseries"],
             detailed_toc_tbl["sub_classes"],
             detailed_toc_tbl["helper_classes"])

-- Remove these elements from the tables in order to avoid ouputting them twice
for _,key in ipairs({"core", "dataseries", "sub_classes", "helper_classes"}) do
	rough_toc_tbl[key] = nil
	detailed_toc_tbl[key] = nil
end

for group_name, toc in pairs(rough_toc_tbl) do
	local group_title = group_name:sub(1,1):upper() .. group_name:sub(2):gsub("_", " ")
	readmefile:write(([[

## %s

%s]]):format(group_title, toc))
	detailed_toc = ([[%s

## %s

%s]]):format(detailed_toc, group_title, detailed_toc_tbl[group_name])
end

readmefile:write(([[

%s
]]):format(detailed_toc))

readmefile:close()
