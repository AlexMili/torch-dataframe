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

_Return value_: Dataframe or table containing missing values per column, total na
]],
	{name="self", type="Dataframe"},
	{name="columns", type="Df_Array", doc="The columns to count", opt=true},
	{name='as_dataframe', type='boolean', default=true,
	 doc="Return a dataframe"},
	call=function(self, columns, as_dataframe)
	if (columns) then
		columns = columns.data
	else
		columns = self.column_order
	end

	local ret = {}
	local tot_na = 0
	for i=1,#columns do
		ret[columns[i]] = self:count_na(columns[i])
		tot_na = tot_na + ret[columns[i]]
	end

	if (as_dataframe) then
		local ret_df = Dataframe.new()
		for name,val in pairs(ret) do
			ret_df:append{rows = Df_Dict{Column = name, Value = val},
			              column_order = Df_Array("Column", "Value")}
		end
		return ret_df, tot_na
	else
		return ret, tot_na
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
	self:assert_has_column(column)

	return self:get_column(column):count_na()
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
	{name="default_value", type="number|string|boolean",
	 doc="The default missing value", default=0},
	call=function(self, column_name, default_value)
	self:assert_has_column(column_name)

	local column_data = self:get_column(column_name)

	column_data:fill_na(default_value)

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
	for i=1,#self.column_order do
		self:fill_na(self.column_order[i], default_value)
	end

	return self
end}
