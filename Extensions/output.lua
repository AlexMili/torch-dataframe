require 'dok'
local params = {...}
local Dataframe = params[1]

--
-- output() : a print function for the dataset
--
-- See dok.unpack
--
function Dataframe:output(...)
	local args = dok.unpack(
		{...},
		'Dataframe.print',
		[[Prints the table into itorch.html if in itorch and html == true, otherwise prints a table string]],
		{arg='html', type='boolean', help='If the output should be in html format', default=itorch ~= nil},
		{arg='max_rows', type='integer', help='Limit the maximum number of printed rows', default=20},
		{arg='digits', type='integer', help='Set this to an integer >= 0 in order to reduce the number of integers shown'}
	)
	assert(args.max_rows > 0, "Can't print less than 1 row")
	args.max_rows = math.min(self.n_rows, args.max_rows)

	data = self:sub(1, args.max_rows)
	if (args.html) then
		html_string = data:_to_html{digits = args.digits}
		if (itorch ~= nil) then
			itorch.html(html_string)
		else
			print(html_string)
		end
	else
		print(data:__tostring__{digits = args.digits})
	end
end

--
-- show() : print dataset
--
-- ARGS: see dok.unpack
--
-- RETURNS: nothing
--
function Dataframe:show(...)
	local args = dok.unpack(
		{...},
		'Dataframe.show',
		[[Prints the top  and bottom section of the table for better overview. Uses itorch if available]],
		{arg='digits', type='integer', help='Set this to an integer >= 0 in order to reduce the number of integers shown'}
	)
	if (self.n_rows <= 20) then
		-- Print all
		self:output{max_rows = 20,
								digits = args.digits}
	else
		head = self:head(10)
		tail = self:tail(10)
		-- Print itorch if present otherwise use stndrd output
		if itorch ~= nil then
			text = ''
			text = text..head:_to_html{split_table='bottom',
			                           digits = args.digits}
			text = text..'\n\t<tr>'
			text = text..'<td><span style="font-size:20px;">...</span></td>' -- index cell
			text = text..'<td colspan="'.. self:shape()["cols"] ..'"><span style="font-size:20px;">...</span></td>' -- the remainder
			text = text..'\n</tr>'
			text = text..tail:_to_html{split_table='top',
			                           offset=self.n_rows - tail:shape()["rows"],
																 digits = args.digits}

			itorch.html(text)
		else
			head:output{digits = args.digits}
			print('...')
			tail:output{digits = args.digits}
		end
	end
end

--
-- tostring() : A convenience wrapper for __tostring
--
-- ARGS: none
--
-- RETURNS: string
--
function Dataframe:tostring()
	return self:__tostring__()
end

-- helper
local function _numeric2string(val, digits)
	if (isint(val)) then
		return tostring(val)
	else
		return ("%." .. digits .. "f"):format(val)
	end
end

--
-- __tostring__() : Converts table to a string representation that follows standard
--                markdown syntax
--
-- ARGS: see dok.unpack
--
-- RETURNS: string
--
function Dataframe:__tostring__(...)
	local args = dok.unpack(
		{...},
		'Dataframe.__tostring__',
		[[Converts table to a string representation that follows standard
	    markdown syntax]],
		{arg='digits', type='integer', help='Set this to an integer >= 0 in order to reduce the number of integers shown'}
	)
	if (args.digits) then
		assert(isint(args.digits), "The digits argument must be an int")
		assert(args.digits >= 0, "The digits argument must be positive")
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
				if (args.digits and self:is_numerical(k)) then
					val = _numeric2string(v[i], args.digits)
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
			  if (args.digits and i > 0) then
					output = _numeric2string(output, args.digits)
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
end

-- Internal function to convert a table to html (only works for 1D table)
function Dataframe:_to_html(...)--data, start_at, end_at, split_table)
	local args = dok.unpack(
		{...},
		{"Dataframe._to_html"},
		{"Converts table to a html table string"},
		{arg='split_table', type='string', help=[[
			Where the table is split. Valid input is 'none', 'top', 'bottom', 'all'.
			Note that the 'bottom' removes the trailing </table> while the 'top' removes
			the initial '<table>'. The 'all' removes both but retains the header while
			the 'top' has no header.
		]], default='none'},
		{arg='offset', type='integer', help="The line index offset", default=0},
		{arg='digits', type='integer', help='Set this to an integer >= 0 in order to reduce the number of integers shown'}
	)
	if (args.digits) then
		assert(isint(args.digits), "The digits argument must be an int")
		assert(args.digits >= 0, "The digits argument must be positive")
	end

	result = ''
	if args.split_table ~= 'top' and args.split_table ~= 'all' then
		result = result.. '<table>'
	end

	if args.split_table ~= 'top' then
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
		result = result.. '\n\t\t<td>'..(row_no + args.offset)..'</td>'
		for col_no = 1,#self.column_order do
			k = self.column_order[col_no]
			val = self:get_column(k)[row_no]
			if (args.digits and self:is_numerical(k)) then
				val = _numeric2string(val, args.digits)
			else
				val = tostring(val)
			end
			result = result.. '<td>' .. val .. '</td>'
		end
		result = result.. '\n\t</tr>'
	end

	if args.split_table ~= 'bottom' and args.split_table ~= 'all' then
		result = result.. '\n</table>'
	end

	return result
end
