-- UTILS

function trim(s)
	local from = s:match"^%s*()"
	return s:match"^%s*()" > #s and "" or s:match(".*%S", s:match"^%s*()")
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
  i = 0
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
	if(tbl == nil) then
		ret = "No table provided"
	elseif(table.exact_length(tbl) == 0) then
		ret = "Empty table"
	elseif (tbl[1] ~=  nil) then
		for _,v in pairs(tbl) do
			if (ret ~= "") then
				ret = ret .. ", "
			end
			ret = ret .. "'" .. v .."'"
		end
	else
		for k,v in pairs(tbl) do
			if (ret ~= "") then
				ret = ret .. ", "
			end
			ret = ret .. "'" .. k .. "'=>'" .. v .. "'"
		end
	end
	return ret
end

-- END UTILS
