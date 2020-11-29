--
-- Register digtron builder for tronwrench
--

local definition = {
	name = 'digtron builder',
	nodes = "digtron:builder",
	group = 'digtron builder',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	error("Digtron builder not implemented")

	return {
		description = metatool.util.description(pos, node, meta),
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)

	error("Digtron builder not implemented")
end

return definition
