local paths = require 'paths'

function write_doc(parsed_data, file_name)

		-- Set the general anchor
	local anchor = "__" .. parsed_data.title .. "__"
	local title = parsed_data.title
	if (title:match("^[A-Z][a-z]") and
	    not title:match("^Data") and
	    not title:match("^Df") and
	    not title:match("^Batc")) then
		title = title:sub(1,1):lower() .. title:sub(2)
	end
	local header = ("# API documentation for [%s](#%s)"):
		format(title, anchor)

	for i=1,#parsed_data.anchors.tags do
		header = header .. get_anchor_link(parsed_data.anchors.titles[i], nil, parsed_data.anchors.tags[i], "")
	end

	local docfile = io.open(file_name, "w")
	docfile:write(header)
	docfile:write(("\n\n<a name=\"%s\">\n%s"):format(anchor, parsed_data.content))
	docfile:close()

end
