local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Row functions

]]

Dataframe.get_row = argcheck{
	doc =  [[
<a name="Dataframe.get_row">
### Dataframe.get_row(@ARGP)

Gets a single row from the Dataframe

@ARGT

_Return value_: A table with the row content
]],
	{name="self", type="Dataframe"},
	{name='index', type='number', doc='The row index to retrieve'},
	call=function(self, index)
	self:assert_is_index(index)

	local row = {}
	for _,key in pairs(self.columns) do
		if (self:is_categorical(key)) then
			row[key] = self:to_categorical(self.dataset[key][index],
			                               key)
		else
			row[key] = self.dataset[key][index]
		end
	end

	return row
end}

Dataframe.insert = argcheck{
	doc =  [[
<a name="Dataframe.insert">
### Dataframe.insert(@ARGP)

Inserts a row or multiple rows into database at the position of the provided index.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="index", type="number", doc="The row number where to insert the row(s)"},
	{name="rows", type="Df_Dict", doc="Insert values to the dataset"},
	call=function(self, index, rows)
	if (self:size(1) == 0 and index == 1) then
		return self:append{rows = rows}
	end

	self:assert_is_index{index = index, plus_one = true}
	if (index == self:size(1) + 1) then
		return self:append(rows)
	end

	rows, no_rows_2_insert =
		self:_check_and_prep_row_argmnt{rows = rows,
		                                add_new_columns = true,
		                                add_old_columns = true}

	for _, column_name in pairs(self.columns) do
		for j = index,(index + no_rows_2_insert - 1) do
			value = rows[column_name][j-index + 1]
			if (self:is_categorical(column_name) and
			    not isnan(value)) then
				vale = self:_get_raw_cat_key(column_name, value)
			end -- TODO: Should we convert string columns with '' to nan?
			table.insert(self.dataset[column_name], j, value)
		end
	end
	self:_refresh_metadata()
	self:_infer_schema()

	return self
end}

Dataframe.insert = argcheck{
	doc =  [[
Note, if you provide a Dataframe the primary dataframes meta-information will
be the ones that are kept

@ARGT

]],
	overload=Dataframe.insert,
	{name="self", type="Dataframe"},
	{name="index", type="number", doc="The row number where to insert the row(s)"},
	{name="rows", type="Dataframe", doc="A Dataframe that you want to insert"},
	call=function(self, index, rows)
	if (index == self:size(1) + 1) then
		return self:append(rows)
	end

	return self:insert(index, Df_Dict(rows.dataset))
end}

Dataframe.insert = argcheck{
	overload=Dataframe.insert,
	{name="self", type="Dataframe"},
	{name="rows", type="Df_Dict", doc="Insert values to the dataset"},
	call=function(self, rows)
	print("Warning: The insert without row number is a deprecated function and support will be dropped - use append instead")
	return self:append(rows)
end}

Dataframe.insert = argcheck{
	overload=Dataframe.insert,
	{name="self", type="Dataframe"},
	{name="rows", type="Dataframe", doc="A Dataframe that you want to append"},
	call=function(self, rows)
		print("Warning: The insert without row number is a deprecated function and support will be dropped - use append instead")
	self:append(Df_Dict(rows.dataset))
end}

Dataframe._check_and_prep_row_argmnt  = argcheck{
	{name="self", type="Dataframe"},
	{name="rows", type="Df_Dict"},
	{name="add_new_columns", type="boolean", default=true,
	 doc="Add columns with missing values to the datafame that appear in the rows dict"},
	{name="add_old_columns", type="boolean", default=true,
	 doc="Add columns with missing values to rows that are only in the dataframe"},
	call=function(self, rows, add_new_columns, add_old_columns)
	rows = rows.data
	local no_rows_2_insert = 0
	local new_columns = {}
	for k,v in pairs(rows) do
		-- Force all input into tables
		if (type(v) ~= 'table') then
			v = {v}
			rows[k] = v
		end

		-- Check input size
		if (no_rows_2_insert == 0) then
			no_rows_2_insert = table.maxn(v)
		else
			assert(no_rows_2_insert == table.maxn(v),
						 "The rows aren't the same between the columns." ..
						 " The " .. k .. " column has " .. " " .. table.maxn(v) .. " rows" ..
						 " while previous columns had " .. no_rows_2_insert .. " rows")
		end

		if (not table.has_element(self.columns, k) and add_new_columns) then
			self:add_column(k)
		end
	end

	if (add_old_columns) then
		for i=1,#self.columns do
			local k = self.columns[i]
			if (rows[k] == nil) then
				local tmp = {}
				for i=1,no_rows_2_insert do
					tmp[i] = 0/0
				end
				rows[k] = tmp
			end
		end
	end

	return rows, no_rows_2_insert
end}

Dataframe.append = argcheck{
	doc =  [[
<a name="Dataframe.append">
### Dataframe.append(@ARGP)

Appends the row(s) to the Dataframe.

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="rows", type="Df_Dict", doc="Values to append to the Dataframe"},
	{name="column_order", type="Df_Array", default=false,
	 doc="The order of the column (has to be array and _not_ a dictionary). Only used when the Dataframe is empty"},
	call=function(self, rows, column_order)
	if (self:size(1) == 0) then
		if (column_order) then
			return self:load_table{data = rows, column_order = column_order}
		else
			return self:load_table{data = rows}
		end
	end

	rows, no_rows_2_insert =
		self:_check_and_prep_row_argmnt{rows = rows,
		                                add_new_columns = true,
		                                add_old_columns = true}

	for _, column_name in pairs(self.columns) do
		for j = 1,no_rows_2_insert do
			value = rows[column_name][j]
			if (self:is_categorical(column_name) and
			    not isnan(value)) then
				vale = self:_get_raw_cat_key(column_name, value)
			end -- TODO: Should we convert string columns with '' to nan?
			self.dataset[column_name][self.n_rows + j] = value
		end
	end

	self:_refresh_metadata()
	self:_infer_schema()

	return self
end}

Dataframe.append = argcheck{
	doc =  [[
Note, if you provide a Dataframe the primary dataframes meta-information will
be the ones that are kept

@ARGT

]],
	overload=Dataframe.append,
	{name="self", type="Dataframe"},
	{name="rows", type="Dataframe", doc="A Dataframe that you want to append"},
	call=function(self, rows)
	if (self:size(1) == 0) then
		self.dataset = clone(rows.dataset)
		self.n_rows = rows.n_rows
		self:_infer_schema()
		self:_refresh_metadata()
		rows:_copy_meta(self)
		return self
	end

	return self:append(Df_Dict(rows.dataset))
end}


Dataframe.rbind = argcheck{
	doc =  [[
<a name="Dataframe.rbind">
### Dataframe.rbind(@ARGP)

Alias to Dataframe.append

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="rows", type="Df_Dict", doc="Values to append to the Dataframe"},
	call=function(self, rows)
	return self:append(rows)
end}

Dataframe.rbind = argcheck{
	doc =  [[
Note, if you provide a Dataframe the primary dataframes meta-information will
be the ones that are kept

@ARGT

]],
	overload=Dataframe.rbind,
	{name="self", type="Dataframe"},
	{name="rows", type="Dataframe", doc="A Dataframe that you want to append"},
	call=function(self, rows)
	return self:append(rows)
end}

Dataframe.remove_index = argcheck{
	doc =  [[
<a name="Dataframe.remove_index">
### Dataframe.remove_index(@ARGP)

Deletes a given row

@ARGT

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name="index", type="number", doc="The row index to remove"},
	call=function(self, index)
	self:assert_is_index(index)

	for i = 1,#self.columns do
		table.remove(self.dataset[self.columns[i]],index)
	end
	self.n_rows = self.n_rows - 1

	self:_refresh_metadata()

	return self
end}
