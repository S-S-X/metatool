--
-- metatool:tronwrench is in game tool that allows cloning digtron settings
--

local has_duplicator = not not minetest.registered_items['digtron:duplicator']
local ingredient = has_duplicator and 'digtron:duplicator' or 'default:steelblock'

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', ingredient, '' },
	{ 'default:obsidian_shard', '', '' }
}

local tool = metatool:register_tool('tronwrench', {
	description = 'Tron wrench',
	name = 'Tron wrench',
	texture = 'tronwrench.png',
	recipe = recipe,
})

-- nodes
local modpath = minetest.get_modpath('tronwrench')
tool:load_node_definition(dofile(modpath .. '/nodes/digtron_builder.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digtron_digger.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digtron_ejector.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digtron_controller.lua'))
