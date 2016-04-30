require 'dok'
local params = {...}
local Dataframe = params[1]

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
		{arg='verbose', type='boolean', help='verbose load', default=false}
	)

	-- Make sure that categorical columns are presented in the correct way
	save_data = {}
	for _,k in pairs(self.columns) do
		save_data[k] = self:get_column(k)
	end

	csvigo.save{path = args.path,
				data = save_data,
				separator = args.separator,
				verbose = args.verbose,
				column_order = self.column_order}
end
