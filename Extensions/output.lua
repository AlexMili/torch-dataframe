local params = {...}
local Dataframe = params[1]

local argcheck = require "argcheck"
local doc = require "argcheck.doc"

doc[[

## Output functions

]]

Dataframe.output = argcheck{
	doc =  [[
<a name="Dataframe.output">
### Dataframe.output(@ARGP)

@ARGT

Prints the table into itorch.html if in itorch and html == true, otherwise prints a table string

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='html', type='boolean', doc='If the output should be in html format', default=itorch ~= nil},
	{name='max_rows', type='number', doc='Limit the maximum number of printed rows', default=20},
	{name='digits', type='number|boolean',
	 doc='Set this to an integer >= 0 in order to reduce the number of integers shown',
	 default=false},
	call=function(self, html, max_rows, digits)
	assert(max_rows > 0, "Can't print less than 1 row")
	max_rows = math.min(self.n_rows, max_rows)

	data = self:sub(1, max_rows)
	if (html) then
		html_string = data:_to_html{digits = digits}
		if (itorch ~= nil) then
			itorch.html(html_string)
		else
			print(html_string)
		end
	else
		print(data:__tostring__{digits = digits})
	end
end}

Dataframe.show = argcheck{
	doc =  [[
<a name="Dataframe.show">
### Dataframe.show(@ARGP)

@ARGT

Prints the top  and bottom section of the table for better overview. Uses itorch if available

_Return value_: void
]],
	{name="self", type="Dataframe"},
	{name='digits', type='number|boolean',
	 doc='Set this to an integer >= 0 in order to reduce the number of integers shown',
	 default=false},
	call=function(self, digits)

	if (self.n_rows <= 20) then
		-- Print all
		self:output{max_rows = 20,
								digits = digits}
	else
		head = self:head(10)
		tail = self:tail(10)
		-- Print itorch if present otherwise use stndrd output
		if itorch ~= nil then
			text = ''
			text = text..head:_to_html{split_table='bottom',
			                           digits = digits}
			text = text..'\n\t<tr>'
			text = text..'<td><span style="font-size:20px;">...</span></td>' -- index cell
			text = text..'<td colspan="'.. self:shape()["cols"] ..'"><span style="font-size:20px;">...</span></td>' -- the remainder
			text = text..'\n</tr>'
			text = text..tail:_to_html{split_table='top',
			                           offset=self.n_rows - tail:shape()["rows"],
																 digits = digits}

			itorch.html(text)
		else
			head:output{digits = digits}
			print('...')
			tail:output{digits = digits}
		end
	end
end}

Dataframe.tostring = argcheck{
	doc=[[
<a name="Dataframe.tostring">
### Dataframe.tostring(@ARGP)

@ARGT

A convenience wrapper for __tostring

_Return value_: string
]],
	{name="self", type="Dataframe"},
	call=function (self)
	return self:__tostring__()
end}

-- helper
local function _numeric2string(val, digits)
	if (isint(val)) then
		return tostring(val)
	else
		return ("%." .. digits .. "f"):format(val)
	end
end

Dataframe.__tostring__ = argcheck{
	doc=[[
<a name="Dataframe.__tostring__">
### Dataframe.__tostring__(@ARGP)

@ARGT

Converts table to a string representation that follows standard markdown syntax

_Return value_: string
]],
	{name="self", type="Dataframe"},
	{name='digits', type='number|boolean',
	 doc='Set this to an integer >= 0 in order to reduce the number of integers shown',
	 default=false},
	call=function(self, digits)

	if (digits) then
		assert(digits >= 0, "The digits argument must be positive")
	end
  local no_rows = math.min(self.print.no_rows, self.n_rows)
	max_width = self.print.max_col_width

	-- Get the width of each column
	local lengths = {}
	for _,k in pairs(self.column_order) do
		lengths[k] = string.len(k)
		v = self:get_column(k)
		for i = 1,no_rows do
			if (v[i] ~= nil) then
				if (digits and self:is_numerical(k)) then
					val = _numeric2string(v[i], digits)
				else
					val = v[i]
				end
				if (lengths[k] < string.len(val)) then
					lengths[k] = string.len(val)
				end
			end
		end
	end

	add_padding = function(df_string, out_len, target_len)
		if (out_len < target_len) then
			df_string = df_string .. string.rep(" ", (target_len - out_len))
		end
		return df_string
	end

	table_width = 0
	for _,l in pairs(lengths) do
		table_width = table_width + math.min(l, max_width)
	end
	table_width = table_width +
		3 * (table.exact_length(lengths) - 1) + -- All the " | "
		2 + -- The beginning of each line "| "
		2 -- The end of each line " |"

	add_separator = function(df_string, table_width)
		df_string = df_string .. "\n+" .. string.rep("-", table_width - 2) .. "+"
		return df_string
	end

	df_string = add_separator("", table_width)
	df_string = df_string .. "\n| "
	for i = 0,no_rows do
		if (i == 0) then
			row = {}
			for _,k in pairs(self.columns) do
				row[k] = k
			end
		else
			row = self:get_row(i)
		end

		if (i > 0) then
			-- Underline header with ----------------
			if (i == 1) then
				df_string = add_separator(df_string, table_width)
			end
			df_string = df_string .. "\n| "
		end

		for ii = 1,#self.column_order do
			column_name = self.column_order[ii]

			if (ii > 1) then
				df_string = df_string .. " | "
			end

			output = row[column_name]
			if (self:is_numerical(column_name)) then
			  if (digits and i > 0) then
					output = _numeric2string(output, digits)
				end
				-- TODO: maybe use :format instead of manual padding
				-- Right align numbers by padding to left
				df_string = add_padding(df_string, string.len(output), lengths[column_name])
				df_string = df_string .. output
			else

				if (string.len(output) > max_width) then
					output = string.sub(output, 1, max_width - 3) .. "..."
				end
				df_string = df_string .. output
				-- Padd left if needed
				df_string = add_padding(df_string, string.len(output), math.min(max_width, lengths[column_name]))
			end
		end

		df_string = df_string .. " |"
	end

	if (self.n_rows > no_rows) then
		df_string = df_string .. "\n| ..." .. string.rep(" ", table_width - 5 - 1) .. "|"
	end

	df_string = add_separator(df_string, table_width) .. "\n"
	return df_string
end}

Dataframe._to_html = argcheck{
	doc=[[
<a name="Dataframe._to_html">
### Dataframe._to_html(@ARGP)

@ARGT

Internal function to convert a table to html (only works for 1D table)

_Return value_: string
]],
	{name="self", type="Dataframe"},
	{name='split_table', type='string', doc=[[
		Where the table is split. Valid input is 'none', 'top', 'bottom', 'all'.
		Note that the 'bottom' removes the trailing </table> while the 'top' removes
		the initial '<table>'. The 'all' removes both but retains the header while
		the 'top' has no header.
	]], default='none'},
	{name='offset', type='number', doc="The line index offset", default=0},
	{name='digits', type='number|boolean',
	 doc='Set this to an integer >= 0 in order to reduce the number of integers shown',
	 default=false},
	call=function(self, digits)

	if (digits) then
		assert(digits >= 0, "The digits argument must be positive")
	end

	result = ''
	if split_table ~= 'top' and split_table ~= 'all' then
		result = result.. '<table>'
	end

	if split_table ~= 'top' then
		result = result.. '\n\t<tr>'
		result = result.. '\n\t\t<th>#</th>'
		for i = 1,#self.column_order do
			k = self.column_order[i]
			result = result.. '<th>' ..k.. '</th>'
		end
		result = result.. '\n\t</tr>'
	end

	for row_no = 1,self.n_rows do
		result = result.. '\n\t<tr>'
		result = result.. '\n\t\t<td>'..(row_no + offset)..'</td>'
		for col_no = 1,#self.column_order do
			k = self.column_order[col_no]
			val = self:get_column(k)[row_no]
			if (digits and self:is_numerical(k)) then
				val = _numeric2string(val, digits)
			else
				val = tostring(val)
			end
			result = result.. '<td>' .. val .. '</td>'
		end
		result = result.. '\n\t</tr>'
	end

	if split_table ~= 'bottom' and split_table ~= 'all' then
		result = result.. '\n</table>'
	end

	return result
end}
