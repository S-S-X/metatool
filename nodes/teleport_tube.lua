--
-- Register teleport tube for tubetool
--

local nodenameprefix = "pipeworks:teleport_tube_"

--luacheck: ignore unused argument node player
local tooldef = {
	group = 'teleport tube',

	copy = function(node, pos, player)
		local meta = minetest.get_meta(pos)

		-- get and store channel and receive setting
		local channel = meta:get_string("channel")
		local receive = meta:get_int("can_receive")

		-- return data required for replicating this tube settings
		return {
			description = string.format("Channel: %s Receive: %d", channel, receive),
			channel = channel,
			receive = receive,
		}
	end,

	paste = function(node, pos, player, data)
		-- restore settings and update tube, no api available
		local fields = {
			channel = data.channel,
			['cr' .. data.receive] = data.receive,
		}
		local nodedef = minetest.registered_nodes[node.name]
		nodedef.on_receive_fields(pos, "", fields, player)
	end,
}

-- teleport tubes
for i=1,10 do
	tubetool:register_node(nodenameprefix .. i, tooldef)
end
