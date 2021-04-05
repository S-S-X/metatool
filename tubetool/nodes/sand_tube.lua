--
-- Register vacuum tube for tubetool
--

local nodenameprefix = "pipeworks:mese_sand_tube_"

-- sand tubes, 8 nodes
local nodes = {}
for i=1,8 do
	table.insert(nodes, nodenameprefix .. i)
end

local definition = {
	name = 'vacuum_tube',
	nodes = nodes,
	group = 'vacuum tube',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local dist = meta:get_int("dist")
	local description = meta:get_string("infotext")
	-- return data required for replicating this tube settings
	return {
		description = description,
		dist = dist,
	}
end

function definition:paste(node, pos, player, data)
	-- restore settings and update tube, no api available
	local fields = {
		set_dist = 1,
		key_enter_field = "dist",
		dist = data.dist,
	}
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", fields, player)
end

return definition
