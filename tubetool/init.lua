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
})

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/mese_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/teleport_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/sand_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/injector.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/any.lua'))
