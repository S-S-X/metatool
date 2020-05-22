--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'mesecons_luacontroller:luacontroller0000', '' },
	{ 'default:obsidian_shard', '', '' }
}

--luacheck: ignore unused argument tooldef player pointed_thing node pos
local tool = metatool:register_tool('luatool', {
	description = 'LuaTool',
	name = 'LuaTool',
	texture = 'luatool_wand.png',
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
local modpath = minetest.get_modpath('luatool')
tool:load_node_definition(dofile(modpath .. '/nodes/luatube.lua'))
