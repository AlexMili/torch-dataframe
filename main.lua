	-- Main Dataframe file
require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Core functions

]]

-- create class object
local Dataframe = torch.class('Dataframe')

Dataframe.__init = argcheck{
	doc =  [[
<a name="Dataframe.__init">
### Dataframe.__init(@ARGP)

Creates and initializes a Dataframe class. Envoked through `local my_dataframe = Dataframe()`

@ARGT

_Return value_: Dataframe
]],
	{name="self", type="Dataframe"},
	call=function(self)
	self:_clean()
	self.print = {no_rows = 10, max_col_width = 20}
end}

Dataframe.__init = argcheck{
	doc =  [[
Read in an csv-file

@ARGT

_Return value_: Dataframe
]],
	overload=Dataframe.__init,
	{name="self", type="Dataframe"},
	{name="csv_file", type="string", doc="The file path to the CSV"},
	call=function(self, csv_file)
	self:__init()
	self:load_csv{path=csv_file,verbose=false}
end}

Dataframe.__init = argcheck{
	doc =  [[
Directly input a table

@ARGT

_Return value_: Dataframe
]],
	overload=Dataframe.__init,
	{name="self", type="Dataframe"},
	{name="data", type="Df_Dict", doc="The data to read in"},
	call=function(self, data)
	self:__init()
	self:load_table{data=data}
end}

-- Private function for cleaning and reseting all data and meta data
Dataframe._clean = argcheck{
	{name="self", type="Dataframe"},
	call=function(self)
	self.dataset = {}
	self.columns = {}
	self.column_order = {}
	self.n_rows = 0
	self.categorical = {}
	self.schema = {}
end}

-- Private function for copying core settings to new Dataframe
Dataframe._copy_meta = argcheck{
	{name="self", type="Dataframe"},
	{name="to", type="Dataframe", doc="The Dataframe to copy to"},
	call=function(self, to)
	to.column_order = clone(self.column_order)
	to.schema = clone(self.schema)
	to.print = clone(self.print)
	to.categorical = clone(self.categorical)

	return to
end}

-- Internal function to collect columns names
Dataframe._refresh_metadata = argcheck{
	{name="self", type="Dataframe"},
	call=function(self)

	local keyset={}
	local rows = -1
	for k,v in pairs(self.dataset) do
		table.insert(keyset, k)

		-- handle the case when there is only one value for the entire column
		local no_rows_in_v = 1
		if (type(v) == 'table') then
			no_rows_in_v = table.maxn(v)
		end

		if (rows == -1) then
			rows = no_rows_in_v
		else
		 	assert(rows == no_rows_in_v,
			       "It seems that the number of elements in row " ..
			       k .. " (# " .. no_rows_in_v .. ")" ..
			       " don't match the number of elements in other rows #" .. rows)
		 end
	end


	self.columns = keyset
	self.n_rows = rows
end}

-- Internal function to detect columns types
Dataframe._infer_schema = argcheck{
	{name="self", type="Dataframe"},
	{name="max_rows", type="number", doc="The maximum number of rows to traverse", default=1e3},
	call=function(self, max_rows)
	local rows_to_explore = math.min(max_rows, self.n_rows)

	for _,key in pairs(self.columns) do
		local is_a_numeric_column = true
		self.schema[key] = 'string'
		if (self:is_categorical(key)) then
			self.schema[key] = 'number'
		else
			for i = 1, rows_to_explore do
				-- If the current cell is not a number and not nil (in case of empty cell, type inference is not compromised)
				local val = self.dataset[key][i]
				if tonumber(val) == nil and
				  val ~= nil and
					val ~= '' and
					not isnan(val)
					then
					is_a_numeric_column = false
					break
				end
			end

			if is_a_numeric_column then
				self.schema[key] = 'number'
				for i = 1, self.n_rows do
					self.dataset[key][i] = tonumber(self.dataset[key][i])
				end
			end
		end
	end
end}

--
-- shape() : give the number of rows and columns
--
-- ARGS: nothing
--
-- RETURNS: {rows=x,cols=y}
--
Dataframe.shape = argcheck{
	doc =  [[
<a name="Dataframe.shape">
### Dataframe.shape(@ARGP)

Returns the number of rows and columns in a table

@ARGT

_Return value_: table
]],
	{name="self", type="Dataframe"},
	call=function(self)
	return {rows=self.n_rows,cols=#self.columns}
end}

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

-- Internal function for getting raw value for a categorical variable
Dataframe._get_raw_cat_key = argcheck{
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The name of the column"},
	{name="key", type="number|string|boolean|nan"},
	call=function(self, column_name, key)
	if (isnan(key)) then
		return key
	end

	local keys = self:get_cat_keys(column_name)
	if (keys[key] ~= nil) then
		return keys[key]
	end

	return self:add_cat_key(column_name, key)
end}

Dataframe.version = argcheck{
	doc =  [[
<a name="Dataframe.version">
### Dataframe.version(@ARGP)

Returns the current data-frame version

@ARGT

_Return value_: string
]],
	{name="self", type="Dataframe"},
	call=function(self)
	return "1.1.dev"
end}

return Dataframe
