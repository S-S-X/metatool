--
-- Register teleport tube for tubetool
--

local nodenameprefix = "pipeworks:teleport_tube_"

--luacheck: ignore unused argument node player
-- teleport tubes
local nodes = {}
for i=1,10 do
	table.insert(nodes, nodenameprefix .. i)
end

return {
	nodes = nodes,
	tooldef = {
		group = "teleport tube",
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)

			-- get and store channel and receive setting
			local channel = meta:get_string("channel")
			local receive = meta:get_int("can_receive")
			local description
			if channel == "" then
				description = "Teleport tube configuration cleaner"
			else
				description = meta:get_string("infotext")
			end

			-- return data required for replicating this tube settings
			return {
				description = description,
				channel = channel,
				receive = receive,
			}
		end,

		paste = function(node, pos, player, data)
			-- restore settings and update tube, no api available
			local fields = {
				channel = data.channel,
				["cr" .. data.receive] = data.receive,
			}
			local nodedef = minetest.registered_nodes[node.name]
			nodedef.on_receive_fields(pos, "", fields, player)
		end,
	}
}
