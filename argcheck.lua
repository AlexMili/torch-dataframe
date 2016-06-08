env = require 'argcheck.env' -- retrieve argcheck environement
env.istype = function(obj, typename)
	if (typename == "Dataframe") then
		return torch.istype(obj, typename)
	end

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

	-- Either a Df_Dict or boolean
  if (typename == "Df_Dict|boolean") then
    return torch.type(obj) == "boolean" or
      torch.type(obj) == "Df_Dict"
  end

	-- Either a Df_Dict or string
  if (typename == "Df_Dict|string") then
    return torch.type(obj) == "string" or
      torch.type(obj) == "Df_Dict"
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
