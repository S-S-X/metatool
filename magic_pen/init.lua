--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local has_feather = not not minetest.registered_items['mobs:chicken_feather']
local texture = has_feather and 'magic_pen_feather.png' or 'magic_pen_graphite.png'
local ingredient = has_feather and 'mobs:chicken_feather' or 'group:stick'

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', ingredient, '' },
	{ 'default:coal_lump', '', '' }
}

--luacheck: ignore unused argument tooldef player pointed_thing node pos
local tool = metatool:register_tool('magic_pen', {
	description = 'Magic pen',
	name = 'MagicPen',
	texture = texture,
	recipe = recipe,
	settings = {
		machine_use_priv = 'server'
	},
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
local modpath = minetest.get_modpath('magic_pen')
tool:load_node_definition(dofile(modpath .. '/nodes/lcd.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/book.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/signs.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/geocache.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/textline.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/travelnet.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/basic_signs.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/luacontroller.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/microcontroller.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/display_modpack.lua'))
