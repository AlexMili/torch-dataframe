function get_anchor_link(title, md_path, tag, indent)
	indent = indent or "  "
	md_path = md_path or ""
	title = trim(title)
	title = title:gsub("(.+)%([^)]+%)", "%1")
	title = title:gsub("([^ `]+)%.__([^_()]+)__([^_`]*)", "%1.`__%2__`%3")
	title = title:gsub("%.__([^_()`]+)$", ".`__%1`")
	title = title:gsub("%._(.+)$", ".`_%1`")
	tag = trim(tag)

	return ("\n%s- [%s](%s#%s)"):
		format(indent, title, md_path, tag)
end

function get_doc_anchors(base_path, md_path, pd, rough_toc, detailed_toc)
	if (not base_path:match("/$")) then
		base_path = base_path .. "/"
	end
	local rel_md_path = md_path:gsub((base_path):quote(), "")
	rough_toc = rough_toc .. "\n- [".. pd.title .."]("..rel_md_path..")"
	detailed_toc = detailed_toc .. "\n- **[".. pd.title .."]("..rel_md_path..")**"
	for i=1,#pd.anchors.titles do
		detailed_toc = detailed_toc .. get_anchor_link(pd.anchors.titles[i], rel_md_path, pd.anchors.tags[i])
	end
	return rough_toc, detailed_toc
end
