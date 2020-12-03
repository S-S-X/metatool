--
-- Register digtron ejector for tronwrench
--

local definition = {
	name = 'digtron_ejector',
	nodes = "digtron:inventory_ejector",
	group = 'digtron ejector',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	return {
		description = metatool.util.description(pos, node, meta),
		nonpipe = meta:get_string("nonpipe"),
		autoeject = meta:get_string("autoeject"),
	}
end

function definition:paste(node, pos, player, data)
	local def = minetest.registered_nodes[node.name]
	if def and def.on_receive_fields then
		def.on_receive_fields(pos, "", { nonpipe = data.nonpipe, autoeject = data.autoeject }, player)
	end
end

return definition
