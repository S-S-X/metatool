--
-- metatool:containertool is in game tool that allows cloning container configuration
--

local recipe = {
	{ '', '', 'default:cobble' },
	{ '', 'default:cobble', '' },
	{ 'default:cobble', '', '' }
}

--luacheck: ignore unused argument tooldef player pointed_thing node pos
local tool = metatool:register_tool('containertool', {
	description = 'Container tool',
	name = 'ContainerTool',
	texture = 'containertool.png',
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

-- nodes
local modpath = minetest.get_modpath('containertool')
tool:load_node_definition(dofile(modpath .. '/nodes/technic_chests.lua'))
