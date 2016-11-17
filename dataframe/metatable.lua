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

By providing dimension you can get only that dimension, row == 1, col == 2. If
value omitted it will  return the number of rows in order to comply with torchnet
standard.

@ARGT

_Return value_: integer
]],
	{name="self", type="Dataframe"},
	{name="dim", type="number", doc="The dimension of interest", default = 1},
	call=function(self, dim)
	assert(isint(dim), "The dimension isn't an integer: " .. tostring(dim))
	assert(dim == 1 or dim == 2, "The dimension can only be between 1 and 2 - you've provided: " .. dim)
	if (dim == 1) then
		if (not self.column_order or #self.column_order == 0) then
			return 0
		end

		local col = self.column_order[1]
		if (self:has_column(col)) then
			return self:get_column(self.column_order[1]):size()
		else
			-- this case happends when _copy_meta has been called and the column_order has been set
			-- TODO: remove the dependence of column_order for the row calc
			return 0
		end
	end

	return #self.column_order
end}

doc =  [[
<a name="Dataframe.[]">
### Dataframe.[]

The `__index__` function is a powerful tool that allows quick access to regular functions

- _Single integer_: it returns the raw row table (see `get_row()`)
- _Df_Array()_: select rows of interest (see `_create_subset()`)
- _"start:stop"_: get a row span using start/stop index, e.g. `"2:5"` (see `sub()`)
- _"$column_name"_: get a column by prepending the name with `$`, e.g. `"$a column name"` (see `get_column`)
- _"/subset_name"_: get a subset by prepending the name with `/`, e.g. `"/a subset name"` (see `get_subset`)

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

		-- Index a subset using a / at the beginning of a string
		if (index:match("^[/]")) then
			local subset_name = index:gsub("^[/]", "")
			return self:get_subset(subset_name), true
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

Dataframe.__tostring__ = argcheck{
	doc=[[
	<a name="Dataframe.__tostring__">
### Dataframe.__tostring__(@ARGP)

A wrapper for `tostring()`

@ARGT

_Return value_: string
]],
	{name="self", type="Dataframe"},
	call=function (self)
	return self:tostring()
end}


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
	return self:size(1)
end}

Dataframe.__len__ = argcheck{
	overload=Dataframe.__len__,
	{name="self", type="Dataframe"},
	call=function(self)
	return self:size(1)
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
	if (self:size(1) ~= other:size(1) or
	    self:size(2) ~= other:size(2)) then
		return false
	end

	-- Check that columns match
	for i=1,#self.column_order do
		if (not other:has_column(self.column_order[i])) then
			return false
		end
	end

	-- Check actual content (expensive why this is left to last)
	for i=1,#self.column_order do
		local self_col = self:get_column(self.column_order[i])
		local other_col = other:get_column(self.column_order[i])

		for i=1,self:size(1) do
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
