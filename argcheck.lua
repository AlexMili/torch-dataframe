local env = require 'argcheck.env' -- retrieve argcheck environement

env.istype = function(obj, typename)
	local thtype = torch.type(obj)
	-- Either a number or string
	if (typename == "number|string") then
		return thtype == "number" or
			thtype == "string"
	end

	-- Either a number or boolean
	if (typename == "number|boolean") then
		return thtype == "number" or
			thtype == "boolean"
	end

	-- Either a boolean or string
	if (typename == "string|boolean") then
		return thtype == "boolean" or
			thtype == "string"
	end

	if (typename == "number|string|boolean") then
		return thtype == "boolean" or
			thtype == "string" or
			thtype == "number"
	end

	if (typename == "number|string|boolean|nan") then
		return thtype == "boolean" or
			thtype == "string" or
			thtype == "number" or
			isnan(obj)
	end

	if (typename == "number|boolean|nan") then
		return thtype == "boolean" or
			thtype == "number" or
			isnan(obj)
	end

	if (typename == "Df_Array|boolean") then
		return thtype == "boolean" or
			thtype == "Df_Array"
	end

	if (typename == "function|Df_Array") then
		return thtype == "function" or
			thtype == "Df_Array"
	end

	-- Either a Df_Dict or boolean
	if (typename == "Df_Dict|boolean") then
		return thtype == "boolean" or
			torch.isTypeOf(obj, "Df_Dict")
	end

	-- Either a Df_Dict or string
	if (typename == "Df_Dict|string") then
		return thtype == "string" or
			torch.isTypeOf(obj, "Df_Dict")
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
