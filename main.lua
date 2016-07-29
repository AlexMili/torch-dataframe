-- Main Dataframe file
require 'torch'

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

-- Since torchnet also uses docs we need to escape them when recording the documentation
local torchnet
if (doc.__record) then
	doc.stop()
	torchnet = require "torchnet"
	doc.record()
else
	torchnet = require "torchnet"
end

doc[[

## Core functions

]]

-- create class object
local Dataframe, parent_class = torch.class('Dataframe', 'tnt.Dataset')

Dataframe.__init = argcheck{
	doc =  [[
<a name="Dataframe.__init">
### Dataframe.__init(@ARGP)

Creates and initializes a Dataframe class. Envoked through `local my_dataframe = Dataframe()`

@ARGT

]],
	{name="self", type="Dataframe"},
	call=function(self)
	parent_class.__init(self)

	self:_clean()
	self.tostring_defaults = self:_get_init_tostring_dflts()
end}

Dataframe.__init = argcheck{
	doc =  [[
Read in an csv-filef

@ARGT

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

]],
	overload=Dataframe.__init,
	{name="self", type="Dataframe"},
	{name="data", type="Df_Dict", doc="The data to read in"},
	{name="column_order", type="Df_Array", default=false,
	 doc="The order of the column (has to be array and _not_ a dictionary)"},
	call=function(self, data, column_order)
	self:__init()
	if (column_order) then
		self:load_table{data=data, column_order=column_order}
	else
		self:load_table{data=data}
	end
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
	self:set_version()
	return self
end}

-- Private function for copying core settings to new Dataframe
Dataframe._copy_meta = argcheck{
	{name="self", type="Dataframe"},
	{name="to", type="Dataframe", doc="The Dataframe to copy to"},
	call=function(self, to)
	to.column_order = clone(self.column_order)
	to.schema = clone(self.schema)
	to.tostring_defaults = clone(self.tostring_defaults)
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

	return self
end}

-- Internal function to detect columns types
Dataframe._infer_schema = argcheck{
	{name="self", type="Dataframe"},
	{name="max_rows", type="number", doc="The maximum number of rows to traverse", default=1e3},
	call=function(self, max_rows)
	local rows_to_explore = math.min(max_rows, self.n_rows)

	local is_empty = function(val)
		return val == nil or
			val == '' or
			isnan(val)
	end

	for _,key in pairs(self.columns) do
		local is_a_numeric_column = true
		self.schema[key] = 'string'
		if (self:is_categorical(key)) then
			self.schema[key] = 'number'
		else
			for i = 1, rows_to_explore do
				-- If the current cell is not a number and not nil (in case of empty cell, type inference is not compromised)
				local val = self.dataset[key][i]
				if (tonumber(val) == nil and
				    not is_empty(val)) then
					is_a_numeric_column = false
					break
				end
			end

			if is_a_numeric_column then
				self.schema[key] = 'number'
				for i = 1, self.n_rows do
					self.dataset[key][i] = tonumber(self.dataset[key][i])
				end
			else
				local is_a_boolean_column = true
				-- Check if we have a boolean column
				for i = 1, rows_to_explore do
					local val = self.dataset[key][i]
					if (torch.type(val) ~= "boolean" and
					    not is_empty(val)) then
						is_a_boolean_column = false
						break
					end
				end

				if (is_a_boolean_column) then
					self.schema[key] = 'boolean'
					-- TODO: Should string boolean columns be converted to boolean values?
				end

			end
		end
	end

	return self
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
	return torch.version(self)
end}

Dataframe.set_version = argcheck{
	doc =  [[
<a name="Dataframe.set_version">
### Dataframe.set_version(@ARGP)

Sets the data-frame version

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	call=function(self)
	self.__version = "1.5"
	return self
end}

Dataframe.upgrade_frame = argcheck{doc =  [[
<a name="Dataframe.upgrade_frame">
### Dataframe.upgrade_frame(@ARGP)

Upgrades a dataframe using the old batch loading framework to the new framework
by instantiating the subsets argument, copying the indexes and setting the
samplers to either:

- linear for test/validate or shuffle = false
- permutation if shuffle = true and none of above names

@ARGT

_Return value_: Dataframe
]],
	{name = "self", type = "Dataframe"},
	call = function(self)
	local current_version = self:version()
	self:set_version()
	if (current_version == self.__version) then
		print(("No need to update dataframe as it already is version '%s'"):format(current_version))
		return
	end

	assert(self.subsets == nil, "The dataframe seems to be upgraded as it already has a subset property")

	if (self.batch == nil) then
		print("No need to update batch info")
	else

		-- Initiate the subsets
		self:create_subsets(Df_Dict(self.batch.data_types))
		self.batch.data_types = nil

		-- Copy the old indexes into the subsets created
		for sub_name,sub_keys in pairs(self.batch.datasets) do
			-- Note, can't use drop/add since this breaks with __init call
			self.subsets.sub_objs[sub_name].dataset["indexes"] = sub_keys
			self.subsets.sub_objs[sub_name].nrows = #sub_keys

			if (self.batch.shuffle and
					(sub_name ~= "test" and sub_name ~= "validate")) then
				self.subsets.sub_objs[sub_name]:set_sampler("permutation")
			else
				self.subsets.sub_objs[sub_name]:set_sampler("linear")
			end

		end
		self.batch = nil

		print("Updated batch metadata")
	end

	if (type(self.print) == "table") then
		-- Do silently as this is rather unimportant
		self.tostring_defaults = self.print
		self.tostring_defaults.max_col_width = nil

		local str_defaults = self:_get_init_tostring_dflts()
		for key, value in pairs(str_defaults) do
			if (not self.tostring_defaults[key]) then
				self.tostring_defaults[key] = value
			end
		end
	end

	return self
end}

Dataframe._get_init_tostring_dflts = argcheck{
	{name = "self", type = "Dataframe"},
	call = function(self)
	return {
		no_rows = 10,
		min_col_width = 7,
		max_table_width = 80
	}
end}

Dataframe.assert_is_index = argcheck{doc =  [[
<a name="Dataframe.assert_is_index">
### Dataframe.assert_is_index(@ARGP)

Asserts that the number is a valid index.

@ARGT

_Return value_: Dataframe
]],
	{name = "self", type = "Dataframe"},
	{name = "index", type = "number", doc="The index to investigate"},
	{name = "plus_one", type = "boolean", default = false,
	 doc= "When adding rows, an index of size(1) + 1 is OK"},
	call = function(self, index, plus_one)
	if (plus_one) then
		if (not isint(index) or
				index < 0 or
				index > self:size(1) + 1) then
				assert(false, ("The index has to be an integer between 1 and %d - you've provided %s"):
					format(self:size(1) + 1, index))
		end
	else
		if (not isint(index) or
				index < 0 or
				index > self:size(1)) then
				assert(false, ("The index has to be an integer between 1 and %d - you've provided %s"):
					format(self:size(1), index))
		end
	end

	return self
end}

return Dataframe
