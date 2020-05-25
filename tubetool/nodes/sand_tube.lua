--
-- Register vacuum tube for tubetool
--

local nodenameprefix = "pipeworks:mese_sand_tube_"

-- sand tubes, 8 nodes
local nodes = {}
for i=1,8 do
	table.insert(nodes, nodenameprefix .. i)
end

--luacheck: ignore unused argument node player
return {
	nodes = nodes,
	tooldef = {
		group = 'vacuum tube',

		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local dist = meta:get_int("dist")
			local description = meta:get_string("infotext")
			-- return data required for replicating this tube settings
			return {
				description = description,
				dist = dist,
			}
		end,

		paste = function(node, pos, player, data)
			-- restore settings and update tube, no api available
			local fields = {
				dist = data.dist,
			}
			local nodedef = minetest.registered_nodes[node.name]
			nodedef.on_receive_fields(pos, "", fields, player)
		end,
	}
}
