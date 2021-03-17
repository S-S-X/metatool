
minetest.register_node(":default:dirt", {})
minetest.register_node(":pipeworks:teleport_tube_1", {})

-- Hash function for pipeworks teleport tube
local function hash(pos)
	return string.format("%.30g", minetest.hash_node_position(pos))
end

local tubedb = {}

pipeworks = {
	tptube = {
		get_db = function()
			return tubedb
		end,
	}
}

local function add_tp_tube(pos, channel, receive)
	world.set_node(pos, "pipeworks:teleport_tube_1")
	local meta = minetest.get_meta(pos)
	meta:set_string("channel", channel)
	meta:set_int("can_receive", receive and 1 or 0)
	tubedb[hash(pos)] = {
		channel = channel,
		cr = receive and 1 or 0,
	}
end

world.clear()
world.set_node({x=0,y=0,z=0}, "default:dirt")

add_tp_tube({x=1,y=1,z=1}, "SX:private", true)
add_tp_tube({x=2,y=1,z=1}, "SX;receiver", true)
add_tp_tube({x=3,y=1,z=1}, "public", true)
add_tp_tube({x=3,y=2,z=1}, "public", true)
add_tp_tube({x=3,y=3,z=1}, "public", true)
