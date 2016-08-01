-- UTILS

local argcheck = require "argcheck"
local doc = require "argcheck.doc"
local paths = require "paths"
doc[[

## Utility functions

Here are utility functions that are not specific to the dataframe but add a general
Lua functionality.

]]

trim = argcheck{
	doc =  [[
<a name="trim">
### trim(@ARGP)

Trims a string fro whitespace chars

@ARGT

_Return value_: string
]],
	{name="s", type="string", doc="The string to trim"},
	{name="ignore", type="number", doc="As gsub returns a number this needs to be ignored", default=false},
	call = function(s, ignore)
	local from = s:match"^%s*()"
	return s:match"^%s*()" > #s and "" or s:match(".*%S", s:match"^%s*()")
end}

trim_table_strings= argcheck{
	doc =  [[
<a name="trim_table_strings">
### trim_table_strings(@ARGP)

Trims a table with strings fro whitespace chars

@ARGT

_Return value_: string
]],
	{name="t", type="table", doc="The table with strings to trim"},
	call = function(t)
	for index,value in pairs(t) do
		if(type(value) == 'string') then
			t[index] = trim(value)
		end
	end

	return t
end}


-- See https://stackoverflow.com/questions/20325332/how-to-check-if-two-tablesobjects-have-the-same-value-in-lua
function tables_equals(o1, o2, ignore_mt)
	if o1 == o2 then return true end
	local o1Type = type(o1)
	local o2Type = type(o2)
	if o1Type ~= o2Type then return false end
	if o1Type ~= 'table' then return false end

	if not ignore_mt then
	local mt1 = getmetatable(o1)
	if mt1 and mt1.__eq then
		--compare using built in method
		return o1 == o2
	end
	end

	local keySet = {}

	for key1, value1 in pairs(o1) do
		local value2 = o2[key1]
		if value2 == nil or tables_equals(value1, value2, ignore_mt) == false then
			return false
		end
		keySet[key1] = true
	end

	for key2, _ in pairs(o2) do
		if not keySet[key2] then return false end
	end
	return true
end

function clone(t) -- shallow-copy a table
	if type(t) ~= "table" then return t end
	local meta = getmetatable(t)
	local target = {}
	for k, v in pairs(t) do target[k] = v end
	setmetatable(target, meta)
	return target
end

table.exact_length = function(tbl)
	if (type(tbl) ~= 'table') then
		return 1
	end
  local i = 0
  for k,v in pairs(tbl) do
    i = i + 1
  end
  return i
end

function isint(n)
	if (torch.isTensor(n)) then
		return torch.eq(n, torch.floor(n))
	else
		return n == math.floor(n)
	end
end

function isnan(n)
	return n ~= n
end

table.get_key_string = function(tbl)
	local ret = ""
	for key,_ in pairs(tbl) do
		if (ret ~= "") then
			ret = ret .. ", "
		end
		ret = ret .. ("'%s'"):format(key)
	end
	return ret
end

table.get_val_string = function(tbl)
	local ret = ""
	for _,val in pairs(tbl) do
		if (ret ~= "") then
			ret = ret .. ", "
		end
		ret = ret .. ("'%s'"):format(val)
	end
	return ret
end

table.collapse2str = function(tbl, indent, start)
	assert(type(tbl) == "table", "The object isn't of type table: " .. type(tbl))

	indent = indent or ""
	start = start or indent
	local ret = start

	if(tbl == nil) then
		ret = "No table provided"

	elseif(table.exact_length(tbl) == 0) then
		ret = "Empty table"

	else
		for k,v in pairs(tbl) do
			if (ret ~= start) then
				ret = ret .. ", "

				-- If deeper structure then the description should be dense
				if (indent:len() <= 2*1) then
					ret = ret .. "\n" .. indent
				end
			end

			if (type(v) == "table") then
				v = ("[\n%s%s\n%s]"):
					format(indent .. "  ",
					       table.collapse2str(v, indent .. "  ", ""),
					       indent)
			end

			if (isnan(v)) then
				ret = ret .. "'" .. k .. "'=>nan"
			elseif (torch.type(v):match("Tensor")) then
				ret = ret .. "'" .. k .. "'=> Tensor with size: '" .. tostring(v:size()) .. "'"
			else
				local v_string = tostring(v)
				if (#v_string > 50) then
					ret = ret .. "'" .. k .. "'=> '" .. v_string:sub(1, 50) .. "...'"
				else
					ret = ret .. "'" .. k .. "'=> '" .. v_string .. "'"
				end
			end
		end
	end

	return ret
end

table.has_element = function(haystack, needle)
	for _,value in pairs(haystack) do
		if (value == needle) then
			return true
		end
	end
	return false
end

table.array2hash = argcheck{
	doc=[[
<a name="table.array2hash">
### table.array2hash(@ARGP)

Converts an array to hash table with numbers corresponding to the index of the
original elements position in the array. Intended for use with arrays where all
values are unique.

@ARGT

_Return value_: table with string keys
]],
	{name="array", type="table", doc="An array of elements"},
	call=function(array)
	local ret = {}
	for index,value in ipairs(array) do
		value = tostring(value)
		if (ret[value] == nil) then
			ret[value] = index
		end
	end

	return ret
end}

-- maxn is deprecated for lua version >=5.3
table.maxn = table.maxn or function(t) local maxn=0 for i in pairs(t) do maxn=type(i)=='number'and i>maxn and i or maxn end return maxn end

-- unpack is deprecated for lua version >= 5.2 and has moved to table.unpack
if (not table.unpack) then
	table.unpack = unpack
end

-- Util for debugging purpose
table._dump = function(tbl)
	local dump_str = ""
	if (torch.type(tbl) == "table") then
		dump_str = ("\n-[ Table dump ]-\n%s"):format(table.collapse2str(tbl))
	else
		dump_str = ("\n-[ not a table: '%s' ]-\ntostring(): %s"):format(torch.type(tbl), tostring(tbl))
	end
	io.stderr:write(dump_str)
end

_dump = function(var)
	local dump_str = ""
	if (torch.type(var) == "table") then
		dump_str = ("\n-[ Table dump ]-\n%s"):format(table.collapse2str(var))
	elseif(torch.type(var):match("Tensor")) then
		dump_str = ("\n-[ Tensor dump ]-\n%s"):format(tostring(var:size()))
	else
		dump_str = ("\n-[ not a table: '%s' ]-\ntostring(): %s"):format(torch.type(var), tostring(var))
	end

	io.stderr:write(dump_str)
end

-- A benchmark function that can be used for checking performance
df_bnchmrk = (function()
	local start
	local i =  0
	return function(desc, reset)
		if (not start or reset) then
			start = os.clock()
			print("Start benchmark")
		else
			i = i + 1
			local new_time = os.clock()
			local digits = math.floor(math.log10(new_time - start))
			local out_str = "Passed time %.1f at point no %d"
			if (digits <= 0) then
				out_str = ("Passed time %%.%df at point no %d"):
					format(1-digits, i)
			end
			out_str = out_str:format(new_time - start, i)
			if (desc) then
				out_str = out_str .. (" (- %s -)"):format(desc)
			end
			print(out_str)
		end
	end
end)()

if (itorch ~= nil) then
	-- The itorch has a strange handling of tables that generate huge outputs for
	-- large dataframe objects. This may hang the notebook as it tries to print
	-- thousands of entries. This snippet overloads if we seem to be in an itorch environement
	print_itorch = print
	print_df = function(...)
		for i = 1,select('#',...) do
			local obj = select(i,...)
			if torch.isTypeOf(obj, Dataframe) then
				print_itorch(tostring(obj))
			else
				print_itorch(obj)
			end
		end
		if select('#',...) == 0 then
			print_itorch()
		end
	end
	print = print_df
end
-- END UTILS

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
