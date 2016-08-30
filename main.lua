-- Main Dataframe file
require 'torch'

local argcheck = require "argcheck"
local tds = require "tds"
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
Read in an csv-file

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
	{name="column_order", type="Df_Array", opt=true,
	 doc="The order of the column (has to be array and _not_ a dictionary)"},
	call=function(self, data, column_order)
	self:__init()
	self:load_table{data=data, column_order=column_order}
end}

Dataframe.__init = argcheck{
	doc =  [[
If you enter column schema* and number of rows a table will be initialized. Note
that you can optionally set all non-set values to `nan` values but this may be
time-consuming for big datasets.

* A schema is a hash table with the column names as keys and the column types
as values. The column types are:
- `boolean`
- `integer`
- `long`
- `double`
- `string` (this is stored as a `tds.Vec` and can be any value)

@ARGT

]],
	overload=Dataframe.__init,
	{name="self", type="Dataframe"},
	{name="schema", type="Df_Dict",
	 doc="The schema to use for initializaiton"},
	{name="no_rows", type="number",
	 doc="The number of rows"},
	{name="column_order", type="Df_Array", opt=true,
	 doc="The column order"},
	{name="set_missing", type="boolean", default=false,
	 doc="Whether all elements should be set to missing from start"},
	call=function(self, schema, no_rows, column_order)
	schema = schema.data
	assert(no_rows > 0 and isint(no_rows),
	       "The no_rows has to be a positive integer")

	if (column_order) then
		column_order = column_order.data
		assert(#column_order == table.exact_length(schema),
		       ("The schema (%d entries) doesn't match the number of columns (%d)"):
		       format(#column_order, table.exact_length(schema)))
		for _,cn in ipairs(column_order) do
			assert(schema[cn], "The schema doesn't have the column: " .. cn)
		end
	else
		column_order = {}
		for cn,_ in pairs(schema) do
			column_order[#column_order + 1] = cn
		end
	end

	self.dataset = {}
	for _,cn in ipairs(column_order) do
		self.dataset[cn] = Dataseries{
			size = no_rows,
			type = schema[cn]
		}
		if (set_missing) then
			self.dataset[cn]:fill(0/0)
		end
	end
	self.n_rows = no_rows
	self.column_order = column_order

	return self
end}


-- Private function for cleaning and reseting all data and meta data
Dataframe._clean = argcheck{
	{name="self", type="Dataframe"},
	call=function(self)
	self.dataset = {}
	self.column_order = {}
	self.n_rows = 0
	self:set_version()
	return self
end}

-- Private function for copying core settings to new Dataframe
Dataframe._copy_meta = argcheck{
	{name="self", type="Dataframe"},
	{name="to", type="Dataframe", doc="The Dataframe to copy to"},
	call=function(self, to)
	to.column_order = clone(self.column_order)
	to.tostring_defaults = clone(self.tostring_defaults)

	return to
end}
-- Internal function to detect columns types
Dataframe._infer_csvigo_schema = argcheck{
	noordered=true,
	{name="self", type="Dataframe"},
	{name="iterator", type="table", -- TODO: ask csvigo to add a class name
	 doc="Data iterator where [i] returns the i:th row."},
	{name="column_order", type="Df_Array",
	 doc="The column order"},
	{name="rows2explore", type="number",
	 doc="The maximum number of rows to traverse",
	 default=1e3},
	{name="first_data_row", type="number",
	 doc="The first number in the iterator to use (i.e. skip header == 2)",
	 default=1},
	call=function(self, iterator, column_order, rows2explore, first_data_row)
	rows2explore = math.min(rows2explore, #iterator)
	column_order = column_order.data

 	local schema = {}
 	for i = first_data_row,rows2explore do
 		local row = iterator[i]
 		for idx,val in ipairs(row) do
			local cn = column_order[idx]
 			schema[cn] =
 				get_variable_type{value = val,
 				                  prev_type = schema[cn]}
 		end
 	end

 	return schema
 end}

-- Internal function to detect columns types
Dataframe._infer_data_schema = argcheck{
	{name="self", type="Dataframe"},
	{name="data", type="Df_Dict",
	 doc="Data for exploration. If omitted it defaults to the self.dataset"},
	{name="rows2explore", type="number",
	 doc="The maximum number of rows to traverse",
	 default=1e3},
	{name="first_data_row", type="number",
	 doc="The first number in the iterator to use (i.e. skip header == 2)",
	 default=1},
	call=function(self, data, rows2explore, first_data_row)

	data = data.data
	local collength = nil
	for key,column in pairs(data) do
		local len = 1
		if (type(column) == "table") then
			len = table.maxn(column)
		end

		if (collength ~= nil) then
			assert(collength == len or
			       len == 1 or
			       collength == 1,
			      ("Column %s doesn't match the length of the other columns %d ~= %d"):
			      format(key, len, collength))
			collength = math.max(collength, len)
		else
			collength = len
		end

	end
	rows2explore = math.min(rows2explore, collength)

	local schema = {}
	for cn,col_vals in pairs(data) do
		if (torch.isTypeOf(col_vals, "Dataseries")) then
			schema[cn] = col_vals:get_variable_type()
		else
			for i=first_data_row,rows2explore do
				if (type(col_vals) == "number" or
				    type(col_vals) == "boolean" or
				    type(col_vals) == "string") then
					schema[cn] =
						get_variable_type{value = col_vals,
						                  prev_type = schema[cn]}
				elseif(col_vals[i]) then
					schema[cn] =
						get_variable_type{value = col_vals[i],
						                  prev_type = schema[cn]}
				end
			end
		end
	end

	return schema
end}

Dataframe.get_schema = argcheck{
	doc =  [[
<a name="Dataframe.get_schema">
### Dataframe.get_schema(@ARGP)

Returns the schema, i.e. column types

@ARGT

_Return value_: string
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string",
	 doc="The column to get schema for"},
	call=function(self, column_name)
	self:assert_has_column(column_name)

	return self:get_column(column_name):get_variable_type()
end}

Dataframe.get_schema = argcheck{
	doc=[[
@ARGT

_Return value_: table
]],
	{name="self", type="Dataframe"},
	{name="columns", type="Df_Array", opt=true,
	 doc="The columns to get schema for"},
	overload=Dataframe.get_schema,
	call=function(self, columns)
	if (columns) then
		columns = columns.data
	else
		columns = self.column_order
	end

	local schema = {}
	for _,cn in ipairs(columns) do
		if (self.dataset[cn]) then
			schema[cn] = self:get_column(cn):get_variable_type()
		end
	end

	return schema
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
	return {rows=self.n_rows,cols=#self.column_order}
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
	self.__version = "1.6"
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

	if (current_version < 1.5) then
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
	end

	if (current_version <= 1.6) then
		self.columns = nil
		for _,cn in ipairs(self.column_order) do
			self.dataset[cn] = Dataseries(Df_Array(cn))
		end
		self.schema = nil
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
