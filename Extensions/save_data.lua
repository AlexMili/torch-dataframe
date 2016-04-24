require 'dok'
local params = {...}
local Dataframe = params[1]

-- UTILS

local function escapeCsv(s, separator)
   if string.find(s, '["' .. separator .. ']') then
   --if string.find(s, '[,"]') then
      s = '"' .. string.gsub(s, '"', '""') .. '"'
   end
   return s
end

-- convert an array of strings or numbers into a row in a csv file
local function tocsv(t, separator, column_order)
   local s = ""
	 for i=1,#column_order do
		 p = t[column_order[i]]
		 if (isnan(p)) then
			 p = ''
		 end
     s = s .. separator .. escapeCsv(p, separator)
   end
   return string.sub(s, 2) -- remove first comma
end

--
-- to_csv() : convert dataset to CSV file
--
-- ARGS: - filename 	(required) 				[string] : path where to save CSV file
-- 		 - separator 	(optional, default=',') [string]	: character to split items in one CSV line
--
-- RETURNS: nothing
--
function Dataframe:to_csv(...)
	local args = dok.unpack(
		{...},
		'Dataframe.to_csv',
		'Saves a Dataframe into a CSV using csvigo as backend',
		{arg='path', type='string', help='path to file', req=true},
		{arg='separator', type='string', help='separator (one character)', default=','},
		{arg='verbose', type='boolean', help='verbose load', default=true}
	)

	file, msg = io.open(args.path, 'w')
	if not file then error("Could not open file") end
	for i = 0,self.n_rows do
		if (i == 0) then
			row = {}
			for _,k in pairs(self.columns) do
				row[k] = k
			end
		else
			row = self:get_row(i)
		end
		res, msg = file:write(tocsv(row, args.separator, self.column_order), "\n")
		if (not res) then error(msg) end
	end
	file:close()
end
