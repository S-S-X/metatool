--
-- Register lcd for Magic pen
--

local get_content_title = metatool.ns('magic_pen').get_content_title

local definition = {
	name = 'lcd',
	nodes = "digilines:lcd",
	group = 'text',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local content = meta:get("text")
	local title = get_content_title(content)
	local nicename = minetest.registered_nodes[node.name].description or node.name
	return {
		description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
		content = content,
		title = title,
	}
end

return definition
