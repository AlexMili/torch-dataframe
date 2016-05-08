env = require 'argcheck.env' -- retrieve argcheck environement
env.istype = function(obj, typename)
	-- Either a number or string
  if (typename == "number|string") then
    return torch.type(obj) == "number" or
      torch.type(obj) == "string"
  end

	-- Check if either a number, table with numbers or a numerical tensor
	if (typename == "number|table") then
    if (torch.type(obj) == "number") then
			return true
		end

		if (torch.type(obj) == "table") then
			for _,v in pairs(obj) do
				if(torch.type(v) ~= "number") then
					return false
				end
			end
			return true
		end

		return false
  end

	-- Check if either string or a table with strings
	if (typename == "string|table") then
		if torch.type(obj) == "string" then
			return true
		end

		if (torch.type(obj) == "table") then
			for _,v in pairs(obj) do
				if(torch.type(v) ~= "string") then
					return false
				end
			end
			return true
    end
		return false
  end

	if (typename == "number|string|table") then
		if torch.type(obj) == "string" or
			torch.type(obj) == "number" then
			return true
		end

		if (torch.type(obj) == "table") then
			for _,v in pairs(obj) do
				if(torch.type(v) ~= "string" and
				   torch.type(v) ~= "number") then
					return false
				end
			end
			return true
		end
		return false
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
