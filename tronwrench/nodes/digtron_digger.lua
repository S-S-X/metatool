--
-- Register digtron diggers for tronwrench
--

local definition = {
	name = 'digtron digger',
	nodes = {
		"digtron:intermittent_digger",
		"digtron:intermittent_soft_digger",
	},
	group = 'digtron digger',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	error("Digtron digger not implemented")

	return {
		description = metatool.util.description(pos, node, meta),
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)

	error("Digtron digger not implemented")
end

return definition
