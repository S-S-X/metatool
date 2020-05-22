--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local modpath = minetest.get_modpath('tubetool')

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'pipeworks:lua_tube000000', '' },
	{ 'default:obsidian_shard', '', '' }
}

--luacheck: ignore unused argument tooldef player pointed_thing node pos
local tool = metatool:register_tool('tubetool', {
	description = 'TubeTool',
	nice_name = 'TubeTool',
	texture = 'tubetool_wand.png',
	recipe = recipe,
	on_read_node = function(tooldef, player, pointed_thing, node, pos)
		local data, group = tooldef:copy(node, pos, player)
		local description = type(data) == 'table' and data.description or ('Data from ' .. minetest.pos_to_string(pos))
		return data, group, description
	end,
	on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos)
		tooldef:paste(node, pos, player, data, group)
	end,
})

minetest.register_alias('tubetool:wand', 'metatool:tubetool')

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/mese_tube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/teleport_tube.lua'))
-- tool:load_node_definition(dofile(modpath .. '/nodes/sand_tube.lua')
-- tool:load_node_definition(dofile(modpath .. '/nodes/injector.lua')
