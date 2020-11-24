--
-- Register shared chest for containertool
--

local ns = metatool.ns('containertool')
local description = ns.description

local definition = {
	name = 'shared_chest',
	nodes = "more_chests:shared",
	group = 'container',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	return {
		description = description(meta, node, pos),
		shared_with = meta:get("shared"),
	}
end

function definition:paste(node, pos, player, data)
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", {shared=data.shared_with}, player)
end

return definition
