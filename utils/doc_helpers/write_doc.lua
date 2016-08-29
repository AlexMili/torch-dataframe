local paths = require 'paths'

function write_doc(parsed_data, file_name)

		-- Set the general anchor
	local anchor = "__" .. parsed_data.title .. "__"
	local header = "# API documentation\n" ..
		("\n- [%s](#%s)"):format(parsed_data.title, anchor)

	for i=1,#parsed_data.anchors.tags do
		header = header .. ("\n- [%s](#%s)"):format(
			parsed_data.anchors.titles[i],
			parsed_data.anchors.tags[i]
		)
	end

	local docfile = io.open(file_name, "w")
	docfile:write(header)
	docfile:write(("\n\n<a name=\"%s\">\n%s"):format(anchor, parsed_data.content))
	docfile:close()

end
