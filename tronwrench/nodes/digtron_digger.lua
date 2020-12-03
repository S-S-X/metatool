--
-- Register digtron diggers for tronwrench
--

local definition = {
	name = 'digtron_digger',
	nodes = {
		"digtron:intermittent_digger",
		"digtron:intermittent_soft_digger",
	},
	group = 'digtron digger',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	return {
		description = metatool.util.description(pos, node, meta),
		period = meta:get_int("period"),
		offset = meta:get_int("offset"),
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	meta:set_int("period", data.period)
	meta:set_int("offset", data.offset)
end

return definition
