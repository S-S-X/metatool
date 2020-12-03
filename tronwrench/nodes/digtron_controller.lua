--
-- Register digtron controller for tronwrench
--

local definition = {
	name = 'digtron_controller',
	nodes = "digtron:auto_controller",
	group = 'digtron controller',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	error("Digtron controller not implemented")

	return {
		description = metatool.util.description(pos, node, meta),
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)

	error("Digtron controller not implemented")
end

return definition
