local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Metatable functions

]]

Dataframe.size = argcheck{
	doc =  [[
<a name="Dataframe.size">
### Dataframe.size(@ARGP)

Returns the number of rows and columns in a tensor

@ARGT

_Return value_: tensor (rows, columns)
]],
	{name="self", type="Dataframe"},
	call=function(self)
	return torch.IntTensor({self.n_rows,#self.columns})
end}

Dataframe.size = argcheck{
	doc =  [[
By providing dimension you can get only that dimension, row == 1, col == 2

@ARGT

_Return value_: integer
]],
	overload=Dataframe.size,
	{name="self", type="Dataframe"},
	{name="dim", type="number", doc="The dimension of interest"},
	call=function(self, dim)
	assert(isint(dim), "The dimension isn't an integer: " .. tostring(dim))
	assert(dim == 1 or dim == 2, "The dimension can only be between 1 and 2 - you've provided: " .. dim)
	if (dim == 1) then
		return self.n_rows
	end

	return #self.columns
end}

-- Wait until https://github.com/torch/torch7/issues/693 is resolved
doc =  [[
<a name="Dataframe.[]">
### Dataframe.[]

Subsets rows. You can either use integers corresponding to valid row numbers,
or you can provide a Df_Array() with multiple values or you can provide a
row span "2:5"

_Return value_: Dataframe
]]

function Dataframe:__index__(index)
	if (torch.type(index) == "number") then
		local tmp = self:_create_subset(Df_Array(index))
		return tmp, true
	end

	if (torch.type(index) == "string") then
		if (index:match("^[0-9]+:[0-9]+$")) then
			-- Get the core data
			local first = index:gsub(":.*", "")
			first = tonumber(first)
			local last = index:gsub("[^:]+:", "")
			last = tonumber(last)

			local indexes = {}
			if (first <= last) then
				for i=first,last do
					table.insert(indexes, i)
				end
			else
				-- insert in reverse order
				for i=last,first do
					table.insert(indexes, 1, i)
				end
			end

			return self[Df_Array(indexes)], true
		end

		-- Index a column using a $ at the beginning of a string
		if (index:match("^[$]")) then
			local column_name = index:gsub("^[$]", "")
			return self:get_column(column_name), true
		end

		return false
	end

	if (torch.type(index) == "Df_Array") then
		return self:_create_subset(index), true
	end

	return false
end
