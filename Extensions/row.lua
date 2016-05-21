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
	assert(isint(index), "The index should be an integer, you've provided " .. tostring(index))
	assert(index > 0 and index <= self.n_rows, ("The index (%d) is outside the bounds 1-%d"):format(index, self.n_rows))

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

Inserts a row or multiple rows into database. Automatically appends to the Dataframe.

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="rows", type="Df_Dict", doc="Insert values to the dataset"},
	call=function(self, rows)
	rows = rows.data
	if (self:size(1) == 0) then
		return self:load_table{data = Df_Dict(rows)}
	end

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

		if (not table.has_element(self.columns, k)) then
			self:add_column(k)
		end
	end

	for _, column_name in pairs(self.columns) do
		-- If the column is not currently inserted by the user
		if rows[column_name] == nil then
			-- Default rows are inserted with nan values (0/0)
			for j = 1,no_rows_2_insert do
				table.insert(self.dataset[column_name], 0/0)
			end
		else
			for j = 1,no_rows_2_insert do
				value = rows[column_name][j]
				if (self:is_categorical(column_name) and
				    not isnan(value)) then
					vale = self:_get_raw_cat_key(column_name, value)
				end -- TODO: Should we convert string columns with '' to nan?
				self.dataset[column_name][self.n_rows + j] = value
			end
		end
	end

	self:_refresh_metadata()
	self:_infer_schema()
end}

Dataframe.remove_index = argcheck{
	doc =  [[
<a name="Dataframe.remove_index">
### Dataframe.remove_index(@ARGP)

Deletes a given row

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="index", type="number", doc="The row index to remove"},
	call=function(self, index)
	assert(isint(index), "The index should be an integer, you've provided " .. tostring(index))
	assert(index > 0 and index <= self.n_rows, ("The index (%d) is outside the bounds 1-%d"):format(index, self.n_rows))

	for i = 1,#self.columns do
		table.remove(self.dataset[self.columns[i]],index)
	end
	self.n_rows = self.n_rows - 1

	self:_refresh_metadata()
end}

Dataframe.insert = argcheck{
	doc =  [[
<a name="Dataframe.insert">
### Dataframe.insert(@ARGP)

Inserts a row or multiple rows into database. Automatically appends to the Dataframe.

@ARGT

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name="index", type="number", doc="Insert values to the dataset"},
	{name="rows", type="Df_Dict", doc="Insert values to the dataset"},
	call=function(self, index, rows)

end}
