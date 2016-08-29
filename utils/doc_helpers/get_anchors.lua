function get_doc_anchors(base_path, md_path, pd, rough_toc, detailed_toc)
	if (not base_path:match("/$")) then
		base_path = base_path .. "/"
	end
	local rel_md_path = md_path:gsub((base_path):quote(), "")
	rough_toc = rough_toc .. "\n- [".. pd.title .."]("..rel_md_path..")"
	detailed_toc = detailed_toc .. "\n- **[".. pd.title .."]("..rel_md_path..")**"
	for i=1,#pd.anchors.titles do
		detailed_toc = ("%s\n  - [%s](%s#%s)"):
			format(detailed_toc, pd.anchors.titles[i], rel_md_path, pd.anchors.tags[i])
	end
	return rough_toc, detailed_toc
end
