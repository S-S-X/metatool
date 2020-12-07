--
-- Register fallback node handler (wildcard node) for magic pen
--

local definition = {
	name = '*',
	nodes = '*',
	group = 'text',
}

local get_content_title = metatool.ns('magic_pen').get_content_title

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local infotext = meta:get("infotext")
	if infotext then
		local title = get_content_title(infotext:gsub("[\r\n]",""), 80)
		return {
			description = metatool.util.description(pos, node, meta),
			source = meta:get("owner"),
			title = title ~= infotext and title,
			content = infotext,
		}
	end
end

return definition
