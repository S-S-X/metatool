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
		local meta = minetest.get_meta(pos)

		-- restore channel and receive setting
		meta:set_string("channel", data.channel)
		meta:set_int("can_receive", data.receive)

		-- update tube
		-- TODO: Requires updating teleport tube database, see pipeworks mod for how this is done
	end,
}

-- teleport tubes
for i=1,10 do
	tubetool:register_node(nodenameprefix .. i, tooldef)
end
