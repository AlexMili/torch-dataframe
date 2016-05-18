-- UTILS

function trim(s)
	local from = s:match"^%s*()"
	return s:match"^%s*()" > #s and "" or s:match(".*%S", s:match"^%s*()")
end

function trim_table_strings(t)
	assert(type(t) == 'table', "You must provide a table")

	for index,value in pairs(t) do
		if(type(value) == 'string') then
			t[index] = trim(value)
		end
	end

	return t
end

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
	return n == math.floor(n)
end

function isnan(n)
	return n ~= n
end

table.collapse_to_string = function(tbl)
	assert(type(tbl) == "table")
	local ret = ""
	if(tbl == nil) then
		ret = "No table provided"
	elseif(table.exact_length(tbl) == 0) then
		ret = "Empty table"
	elseif (tbl[1] ~=  nil) then
		for _,v in pairs(tbl) do
			if (ret ~= "") then
				ret = ret .. ", "
			end

			if (type(v) == "table") then
				v = ("[%s]"):format(table.collapse_to_string(v))
			end

			ret = ret .. "'" .. v .."'"
		end
	else
		for k,v in pairs(tbl) do
			if (ret ~= "") then
				ret = ret .. ", "
			end

			if (type(v) == "table") then
				v = ("[%s]"):format(table.collapse_to_string(v))
			end

			ret = ret .. "'" .. k .. "'=>'" .. v .. "'"
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

-- Util for debugging purpose
table._dump = function(tbl)
	print(table.collapse_to_string(tbl))
end
-- END UTILS
