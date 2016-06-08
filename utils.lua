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
	if (torch.isTensor(n)) then
		return torch.equal(n, torch.floor(n))
	else
		return n == math.floor(n)
	end
end

function isnan(n)
	return n ~= n
end

table.collapse_to_string = function(tbl, indent, start)
	assert(type(tbl) == "table")

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
					       table.collapse_to_string(v, indent .. "  ", ""),
					       indent)
			end

			if (isnan(v)) then
				ret = ret .. "'" .. k .. "'=>nan"
			else
				ret = ret .. "'" .. k .. "'=>'" .. tostring(v) .. "'"
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

-- maxn is deprecated for lua version >=5.3
table.maxn = table.maxn or function(t) local maxn=0 for i in pairs(t) do maxn=type(i)=='number'and i>maxn and i or maxn end return maxn end


-- Util for debugging purpose
table._dump = function(tbl)
	print(("\n-[ Table dump ]-\n%s"):format(table.collapse_to_string(tbl)))
end
-- END UTILS
