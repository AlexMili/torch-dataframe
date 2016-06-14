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

_Return value_: self
]],
	{name="self", type="Dataframe"},
	{name='html', type='boolean', doc='If the output should be in html format', default=itorch ~= nil},
	{name='max_rows', type='number', doc='Limit the maximum number of printed rows', default=20},
	{name='digits', type='number|boolean',
	 doc='Set this to an integer >= 0 in order to reduce the number of integers shown',
	 default=false},
	call=function(self, html, max_rows, digits)
	assert(max_rows > 0, "Can't print less than 1 row")

	-- Subset only if we have more rows than we can show
	if (max_rows < self.n_rows) then
		max_rows = math.min(self.n_rows, max_rows)

		data = self:sub(1, max_rows)
	else
		data = self
	end

	if (html) then
		html_string = data:_to_html{digits = digits}
		itorch.html(html_string)
	else
		print(data:tostring{digits = digits})
	end
end}

Dataframe.show = argcheck{
	doc =  [[
<a name="Dataframe.show">
### Dataframe.show(@ARGP)

@ARGT

Prints the top  and bottom section of the table for better overview. Uses itorch if available

_Return value_: self
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

-- helper
local function _numeric2string(val, digits)
	if (isint(val)) then
		return tostring(val)
	else
		return ("%." .. digits .. "f"):format(val)
	end
end

Dataframe.tostring = argcheck{
	doc=[[
<a name="Dataframe.tostring">
### Dataframe.tostring(@ARGP)

Converts table to a string representation that follows standard markdown syntax

{no_rows = 10,
max_col_width = 20,
min_col_width = 7,
max_table_width = 80}
@ARGT

_Return value_: string
]],
	{name="self", type="Dataframe"},
	{name='digits', type='number|boolean',
	 doc='Set this to an integer >= 0 in order to reduce the number of integers shown',
	 default=false},
	{name='columns2skip', type='Df_Array',
	 doc='Columns to skip from the output', default=false},
	 {name="no_rows", type="number",
	 doc='The number of rows to display. If -1 then shows all. Defaults to setting in Dataframe.tostring_defaults',
	 default=false},
	{name="min_col_width", type="number",
	 doc='The minimum column width in characters. Defaults to setting in Dataframe.tostring_defaults',
	 default=false},
	{name="max_table_width", type="number",
	 doc='The maximum table width in characters. Defaults to setting in Dataframe.tostring_defaults',
	 default=false},
	call=function(self, digits, columns2skip, no_rows, min_col_width, max_table_width)
	if (digits) then
		assert(digits >= 0, "The digits argument must be positive")
	end

	if (columns2skip) then
		columns2skip = columns2skip.data
	else
		columns2skip = {}
	end

	if (not no_rows) then
		no_rows = math.min(self.tostring_defaults.no_rows, self.n_rows)
	else
		if (no_rows == -1) then
			no_rows = self.n_rows
		else
			self:assert_is_index(no_rows)
		end
	end

	if (not min_col_width) then
		min_col_width = self.tostring_defaults.min_col_width
	end

	if (not max_table_width) then
		max_table_width = self.tostring_defaults.max_table_width
	end

	-------------------------------
	-- Internal helper functions --
	-------------------------------
	function get_widths(columns2skip)
		local widths = {}
		for _,k in pairs(self.column_order) do
			if (not table.has_element(columns2skip, k)) then
				widths[k] = string.len(k)
				v = self:get_column(k)
				for i = 1,no_rows do
					if (v[i] ~= nil) then
						if (digits and self:is_numerical(k)) then
							val = _numeric2string(v[i], digits)
						else
							val = v[i]
						end

						if (widths[k] < string.len(val)) then
							widths[k] = string.len(val)
						end
					end
				end
			end
		end

		return widths
	end

	function get_tbl_width(widths)
		local raw_cell_width = 0
		for _,w in pairs(widths) do
			raw_cell_width = raw_cell_width + w
		end

		local full_table_width = raw_cell_width +
			3 * (table.exact_length(widths) - 1) + -- All the " | "
			2 + -- The beginning of each line "| "
			2 -- The end of each line " |"
		return full_table_width, raw_cell_width
	end

	function add_padding(str2pad, out_len, target_len)
		if (out_len < target_len) then
			str2pad = str2pad .. string.rep(" ", (target_len - out_len))
		end
		return str2pad
	end

	function add_separator(str2add_sep, table_width)
		str2add_sep = str2add_sep .. "\n+" .. string.rep("-", table_width - 2) .. "+"
		return str2add_sep
	end

	function get_output_row(i, columns2skip, widths)
		local row = {}
		if (i == 0) then
			for _,k in pairs(self.columns) do
				row[k] = k
			end
		else
			row = self:get_row(i)
		end

		local ret_row = {}
		for key,value in pairs(row) do
			if (not table.has_element(columns2skip, key)) then
				if (self:is_numerical(key)) then
					if (digits and i > 0) then
						value = _numeric2string(value, digits)
					end

					-- TODO: maybe use :format instead of manual padding
					-- Right align numbers by padding to left
					value = add_padding("", string.len(value), widths[key]) .. value

				elseif (value ~= nil) then
					-- Pad right
					value = add_padding(value, string.len(value), widths[key])
				else
					value = add_padding(value, 0, widths[key])
				end

				-- Clip the trailing string to match column width
				if (string.len(value) > widths[key]) then
					value = string.sub(value, 1, widths[key]-3) .. "..."
				end

				ret_row[key] = value
			end
		end

		return ret_row
	end

	local widths = get_widths(columns2skip)
	local table_width, raw_tbl_width = get_tbl_width(widths)

	-- If our script excludes columns we should in addition to the 'Columns skipped'
	-- text below the table also add a column | ... | to the rows in order to convey
	-- that we have removed additional columns
	local skip = false
	if (table_width > max_table_width) then
		-- If the table is larger than allowed print we need to shrink it down to match
		--  the max width limit to the table to fit in the window in two principal ways
		-- (1) reduce rows to min_col_width and exclude all columns that don't fit
		-- (2) calculate difference, decide what columns to reduce in length, and
		--     reduce them accordingly

		local min_length = {}
		for _,l in pairs(widths) do
			min_length[#min_length + 1] = math.min(l, min_col_width)
		end
		min_length = get_tbl_width(min_length)

		if (min_length > max_table_width) then
			-- Update the widths and add excluded columns
			local tmp = {}
			for i=1,#self.column_order do

				local cn = self.column_order[i]
				local new_col_length = math.min(widths[cn], min_col_width)

				local new_length = get_tbl_width(tmp) + new_col_length
				if (not skip and
				    new_length < max_table_width) then
					tmp[cn] = new_col_length
				else
					skip = true
					columns2skip[#columns2skip + 1] = cn
				end
			end

			widths = tmp
			table_width = get_tbl_width(widths)
		else
			local available_width =
				(max_table_width - (table_width - raw_tbl_width))

			local no_elmnts2large = 0
			for _,w in pairs(widths) do
				if (w > min_col_width) then
					no_elmnts2large = no_elmnts2large + 1
				else
					available_width = available_width - w
				end
			end

			local new_min_col_width = math.floor(available_width/no_elmnts2large)
			assert(new_min_col_width > min_col_width, "Script bug")

			local tmp = {}
			for i=1,#self.column_order do
				local cn = self.column_order[i]
				local new_col_length = math.min(widths[cn], new_min_col_width)
				tmp[cn] = new_col_length
			end
			widths = tmp
		end
	end

	table_width = get_tbl_width(widths)
	local end_str = " | ... "
	if (skip) then
		-- Add length indicator
		table_width = table_width + string.len(end_str)
	end

	-- The core creating of the table
	ret_str = ""
	ret_str = add_separator(ret_str, table_width)
	ret_str = ret_str .. "\n| "
	for i = 0,no_rows do
		local row = get_output_row(i, columns2skip, widths)

		if (i > 0) then
			-- Underline header with ----------------
			if (i == 1) then
				ret_str = add_separator(ret_str, table_width)
			end

			ret_str = ret_str .. "\n| "
		end

		for ii = 1,#self.column_order do
			column_name = self.column_order[ii]

			if (row[column_name] ~= nil) then
				if (ii > 1) then
					ret_str = ret_str .. " | "
				end

				ret_str = ret_str .. row[column_name]
			end
		end

		if (skip) then
			ret_str = ret_str .. end_str
		end
		ret_str = ret_str .. " |"
	end

	if (self.n_rows > no_rows) then
		ret_str = ret_str .. "\n| ..." .. string.rep(" ", table_width - 5 - 1) .. "|"
	end

	ret_str = add_separator(ret_str, table_width) .. "\n"

	if (#columns2skip > 0 ) then
		if (#columns2skip == 1) then
			ret_str = ret_str .. "\n * Column skipped: "
		else
			ret_str = ret_str .. "\n * Columns skipped: "
		end
		ret_str = ret_str .. table.get_val_string(columns2skip)
	end

	return ret_str
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
	call=function(self, split_table,  offset, digits)

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
		result = result.. '\n\t\t<td><span style="font-weight:bold;">'..(row_no + offset)..'</span></td>'
		for col_no = 1,#self.column_order do
			k = self.column_order[col_no]
			val = self:get_column(k)[row_no]
			if (digits and
			    self:is_numerical(k) and
			    not self:is_categorical(k)) then
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
