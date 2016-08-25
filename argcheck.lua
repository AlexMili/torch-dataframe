local env = require 'argcheck.env' -- retrieve argcheck environement

env.istype = function(obj, typename)
	if (typename == "*") then
		return true
	end

	local thtype = torch.type(obj)
	-- Either a number or string
	if (typename:match("|")) then
		for _,subtype in ipairs(typename:split("|")) do
			if ((thtype == subtype) or
			    (thtype == "nan" and isnan(obj)) or
			    (subtype:match("^Df_") and torch.isTypeOf(obj, subtype)))
			then
				return true
			end
		end
		return false
	end

	if (typename == "!table" and thtype ~= "table") then
		return true
	end

	-- From the original argcheck env
	local thname = torch.typename(obj)
	if thname then
		-- __typename (see below) might be absent
		local match = thname:match(typename)
		if match and (match ~= typename or match == thname) then
			return true
		end
		local mt = torch.getmetatable(thname)
		while mt do
			if mt.__typename then
				match = mt.__typename:match(typename)
				if match and (match ~= typename or match == mt.__typename) then
					return true
				end
			end
			mt = getmetatable(mt)
		end
		return false
	end

	return type(obj) == typename
end
