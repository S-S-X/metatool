--
-- Register digtron ejector for tronwrench
--

local definition = {
	name = 'digtron ejector',
	nodes = "digtron:inventory_ejector",
	group = 'digtron ejector',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	error("Digtron ejector not implemented")

	return {
		description = metatool.util.description(pos, node, meta),
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)

	error("Digtron ejector not implemented")
end

return definition
