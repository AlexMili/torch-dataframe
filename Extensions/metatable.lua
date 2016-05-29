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

doc =  [[
<a name="Dataframe.[]">
### Dataframe.[]

The `__index__` function is a powerful tool that allows quick access to regular functions

- _Single integer_: it returns the raw row table (see `get_row()`)
- _Df_Array()_: select rows of interest (see `_create_subset()`)
- _"start:stop"_: get a row span using start/stop index, e.g. "2:5" (see `sub()`)
- _"$column_name"_: get a column by prepending the name with $, e.g. "$a column name" (see `get_column`)

_Return value_: Table or Dataframe
]]

function Dataframe:__index__(index)
	if (torch.type(index) == "number") then
		return self:get_row(index), true
	end

	if (torch.type(index) == "string") then
		if (index:match("^[0-9]+:[0-9]+$")) then
			-- Get the core data
			local start = index:gsub(":.*", "")
			start = tonumber(start)
			local stop = index:gsub("[^:]+:", "")
			stop = tonumber(stop)

			return self:sub{start=start, stop=stop}, true
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

doc =  [[
<a name="Dataframe.[] =">
### Dataframe.[] =

The `__newindex__` allows easy updating of a single row (see `_update_single_row()`)

]]

function Dataframe:__newindex__(index, value)
	if (torch.type(index) == "number") then
		self:_update_single_row(index, Df_Tbl(value), Df_Tbl(self:get_row(index)))
		return true
	end

	return false
end

Dataframe.copy = argcheck{
	doc =  [[
<a name="Dataframe.copy">
### Dataframe.copy(@ARGP)

Copies the table together with all metadata

@ARGT

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	call=function(self)
	local new_df = Dataframe.new(Df_Dict(self.dataset))
	new_df = self:_copy_meta(new_df)
	return new_df
end}


Dataframe.__len__ = argcheck{
	doc =  [[
<a name="Dataframe.#">
### Dataframe.#

Returns the number of rows

_Return value_: integer
]],
	{name="self", type="Dataframe"},
	{name="other", type="Dataframe"},
	call=function(self, other)
	return self.n_rows
end}

Dataframe.__eq__ = argcheck{
	doc =  [[
<a name="Dataframe.==">
### Dataframe.==

Checks if Dataframe's contain the same values

_Return value_: boolean
]],
	{name="self", type="Dataframe"},
	{name="other", type="Dataframe"},
	call=function(self, other)
	-- Check that size matches
	if (not torch.all(torch.eq(self:size(), other:size()))) then
		return false
	end

	-- Check that columns match
	for i=1,#self.columns do
		if (not other:has_column(self.columns[i])) then
			return false
		end
	end

	-- Check actual content (expensive why this is left to last)
	for i=1,#self.columns do
		local self_col = self:get_column(self.columns[i])
		local other_col = other:get_column(self.columns[i])

		for i=1,self.n_rows do
			-- one is nan and not the other
			if ((not isnan(self_col[i]) and
			     isnan(other_col[i])) or
			    (isnan(self_col[i]) and
			     not isnan(other_col[i]))) then
				return false
			end

			-- Actual value check if both weren't nan
			if (not(isnan(self_col[i]))) then
				if (self_col[i] ~= other_col[i]) then
					return false
				end
			end

		end
	end

	-- If the function hasn't exited before then it means that the two dataframes are equal
	return true
end}
