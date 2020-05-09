local nodenameprefix = "pipeworks:teleport_tube_"

local tooldef = {
	copy = function(node, pos)
		local nodename = node.name
		local variant = nodename:sub(#nodenameprefix + 1, #nodenameprefix + 6)
		local meta = minetest.get_meta(pos)

		-- get and store channel and receive setting
		local channel = meta:get_string("channel")
		local receive = meta:get_int("can_receive")

		-- return data required for replicating this tube settings
		return {
			description = string.format("Items: %d States: %s Variant: %s", itemcount, table.concat(enabled, ","), variant),
			variant = variant,
			channel = channel,
			receive = receive,
		}
	end,

	paste = function(node, pos, data)
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
	tubetool:register_node("pipeworks:teleport_tube_" .. i, tooldef)
end
