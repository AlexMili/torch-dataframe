local argdoc = require 'argcheck.doc'
local paths = require 'paths'

function parse_doc(raw_docs, file_name)
	-- Get documentation
	local doc_tbl = {
		content = trim(raw_docs),
		anchors = {
			tags = {},
			titles = {}
		},
		title = nil,
		title_rno = 0
	}

	local rows = doc_tbl.content:split("\n")
	for row_no,row in ipairs(rows) do
		if (row:match("^#")) then
			doc_tbl.title = trim(row:gsub("#", ""))
			doc_tbl.title_rno = row_no
			break
		end
	end

	-- If title not found use the file name
	if (not doc_tbl.title) then
		doc_tbl.title = "File: " .. file_name
	end

	if (doc_tbl.content:len() > 0) then
		local rows = doc_tbl.content:split("\n")

		-- Remove empty rows and initial rows that are part of the title
		local tmp = {}
		for row_no,row in ipairs(rows) do
			if (row_no > doc_tbl.title_rno) then
				if(trim(row):len() > 0) then
					tmp[#tmp + 1] = row
				end
			end
		end
		rows = tmp

		-- Find all the anchors in the text
		for idx,row in ipairs(rows) do
			if (row:match("<a%s*name%s*=[\"'][^\"']+[\"']%s*>")) then
				local subanchor_tag = row:gsub("<a%s*name%s*=[\"']([^\"']+)[\"']%s*>", "%1")
				local subtitle = subanchor_tag

				if (rows[idx + 1] and
				rows[idx + 1]:match("^%s*#")) then
					subtitle = trim(rows[idx + 1]:gsub("^#+", ""))
				end

				if (subtitle ~= title) then
					doc_tbl.anchors.titles[#doc_tbl.anchors.titles + 1] = subtitle
					doc_tbl.anchors.tags[#doc_tbl.anchors.tags + 1] = subanchor_tag
				end
			end
		end
	end

	return doc_tbl
end
