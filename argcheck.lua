local env = require 'argcheck.env' -- retrieve argcheck environement

-- Should be a fast and more convenient alternative to built-in regular expression
--  the re could be used that is a layer on top of lpeg but there is currently no need for that
local lpeg = require 'lpeg'
local r_batchframe = lpeg.Cg("Batchframe")
local r_dataframe = lpeg.Cg("Dataframe")
local r_subset = lpeg.Cg("Df_Subset")
local any_frame = r_batchframe + r_dataframe + r_subset

env.istype = function(obj, typename)

	-- Either a number or string
	if (typename == "number|string") then
		return torch.type(obj) == "number" or
			torch.type(obj) == "string"
	end

	-- Either a number or boolean
	if (typename == "number|boolean") then
		return torch.type(obj) == "number" or
			torch.type(obj) == "boolean"
	end

	-- Either a boolean or string
	if (typename == "string|boolean") then
		return torch.type(obj) == "boolean" or
			torch.type(obj) == "string"
	end

	if (typename == "number|string|boolean") then
		return torch.type(obj) == "boolean" or
			torch.type(obj) == "string" or
			torch.type(obj) == "number"
	end

	if (typename == "number|string|boolean|nan") then
		return torch.type(obj) == "boolean" or
			torch.type(obj) == "string" or
			torch.type(obj) == "number" or
			isnan(obj)
	end

	if (typename == "number|boolean|nan") then
		return torch.type(obj) == "boolean" or
			torch.type(obj) == "number" or
			isnan(obj)
	end

	if (typename == "Df_Array|boolean") then
		return torch.type(obj) == "boolean" or
			torch.type(obj) == "Df_Array"
	end

	if (typename == "function|Df_Array") then
		return torch.type(obj) == "function" or
			torch.type(obj) == "Df_Array"
	end

	-- Either a Df_Dict or boolean
	if (typename == "Df_Dict|boolean") then
		return torch.type(obj) == "boolean" or
			torch.isTypeOf(obj, "Df_Dict")
	end

	-- Either a Df_Dict or string
	if (typename == "Df_Dict|string") then
		return torch.type(obj) == "string" or
			torch.isTypeOf(obj, "Df_Dict")
	end

	local frame = any_frame:match(typename)
	if (frame) then
		return torch.isTypeOf(obj, frame)
	end

	-- Only numerical tensors count
	if (typename == "torch.*Tensor") then
	-- regular expressions don't work therefore this
		return torch.type(obj) == "torch.IntTensor" or
			torch.type(obj) == "torch.FloatTensor" or
			torch.type(obj) == "torch.DoubleTensor"
	end

	return torch.type(obj) == typename
end
