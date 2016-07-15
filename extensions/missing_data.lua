local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Missing data functions

]]

Dataframe.count_na = argcheck{
	doc =  [[
<a name="Dataframe.count_na">
### Dataframe.count_na(@ARGP)

Count missing values in dataset

@ARGT

_Return value_: Datafrmae or table containing missing values per column
]],
	{name="self", type="Dataframe"},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, as_dataframe)

	return self:count_na(Df_Array(self.column_order), as_dataframe)
end}

Dataframe.count_na = argcheck{
	doc = [[
You can manually choose the columns by providing a Df_Array

@ARGT

]],
	overload=Dataframe.count_na,
	{name="self", type="Dataframe"},
	{name="columns", type="Df_Array", doc="The columns to count"},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, as_dataframe)
	columns = columns.data

	local ret = {}
	for i=1,#columns do
		ret[columns[i]] = self:count_na(columns[i])
	end

	if (as_dataframe) then
		local ret_df = Dataframe.new()
		for name,val in pairs(ret) do
			ret_df:append(Df_Dict{Column = name, Value = val},
			              Df_Array("Column", "Value"))
		end
		return ret_df
	else
		return ret
	end
end}

Dataframe.count_na = argcheck{
	doc =  [[
If you only want to count a single column

@ARGT

_Return value_: single integer
	]],
	overload=Dataframe.count_na,
	{name="self", type="Dataframe"},
	{name="column", type="string", doc="The column to count"},
	call=function(self, column)

	counter = 0
	for i = 1, self.n_rows do
		local val = self.dataset[column][i]
		if val == nil or val == '' or isnan(val) then
			counter = counter + 1
		end
	end

	return counter
end}

Dataframe.fill_na = argcheck{
	doc = [[
<a name="Dataframe.fill_na">
### Dataframe.fill_na(@ARGP)

Replace missing value in a specific column

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="column_name", type="string", doc="The column to fill"},
	{name="default_value", type="number|string|boolean", doc="The default missing value", default=0},
	call=function(self, column_name, default_value)
	self:assert_has_column(column_name)

	if (self:is_categorical(column_name) and
	    self.categorical[column_name][default_value] == nil) then
		self.categorical[column_name]["__nan__"] = default_value
	end

	for i = 1, self.n_rows do
		local val = self.dataset[column_name][i]
		if val == nil or isnan(val) then
			self.dataset[column_name][i] = default_value
		end
	end

	return self
end}

Dataframe.fill_all_na = argcheck{
	doc = [[
<a name="Dataframe.fill_na">
### Dataframe.fill_na(@ARGP)

Replace missing value in all columns

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="default_value", type="number|string|boolean", doc="The default missing value", default=0},
	call=function(self, default_value)
	for i=1,#self.columns do
		self:fill_na(self.columns[i], default_value)
	end

	return self
end}
