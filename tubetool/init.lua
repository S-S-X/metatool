--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local modpath = minetest.get_modpath('tubetool')

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'pipeworks:lua_tube000000', '' },
	{ 'default:obsidian_shard', '', '' }
}

local tool = metatool:register_tool('tubetool', {
	description = 'TubeTool',
	name = 'TubeTool',
	texture = 'tubetool_wand.png',
	recipe = recipe,
})

-- Create namespace containing tubetool common functions
tool:ns({
	pipeworks_tptube_api_check = function(player)
		if not pipeworks or not pipeworks.tptube or not pipeworks.tptube.get_db then
			minetest.chat_send_player(
				player:get_player_name(),
				'Installed pipeworks version does not have required tptube.get_db function.'
			)
			return false
		end
		return true
	end,
	get_teleport_tubes = function(channel, pos)
		local db = pipeworks.tptube.get_db()
		local tubes = {}
		for hash,data in pairs(db) do
			if data.channel == channel then
				local tube_pos = minetest.get_position_from_hash(hash)
				table.insert(tubes, {
					pos = tube_pos,
					distance = vector.distance(pos, tube_pos),
					can_receive = data.cr == 1,
				})
			end
		end
		table.sort(tubes, function(a, b) return a.distance < b.distance end)
		return tubes
	end,
	explode_teleport_tube_channel = function(channel)
		-- Return channel, owner, type. Owner can be nil. Type can be nil, ; or :
		local a, b, c = channel:match("^([^:;]+)([:;])(.*)$")
		a = a ~= "" and a or nil
		b = b ~= "" and b or nil
		if b then
			return a,b,c
		end
		-- No match for owner and mode
		return nil,nil,channel
	end,
})

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/mese_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/teleport_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/sand_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/injector.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/any.lua'))
