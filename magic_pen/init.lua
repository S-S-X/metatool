--
-- metatool:magic_pen is in game tool that allows copying text
--

local has_feather = not not minetest.registered_items['mobs:chicken_feather']
local texture = has_feather and 'magic_pen_feather.png' or 'magic_pen_graphite.png'
local ingredient = has_feather and 'mobs:chicken_feather' or 'group:stick'

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', ingredient, '' },
	{ 'default:coal_lump', '', '' }
}

local tool = metatool:register_tool('magic_pen', {
	description = 'Magic pen',
	name = 'MagicPen',
	texture = texture,
	recipe = recipe,
	settings = {
		machine_use_priv = 'server',
		storage_size = 1024 * 16,
	},
})

tool:ns({
	truncate = function(value, length)
		if type(value) == 'string' and type(length) == 'number' and #value > length then
			value = value:sub(1, length)
		end
		return value
	end,
	get_content_title = function(content, limit)
		local title = content and content:gmatch("[\t ]*([^\r\n]+)")()
		if type(title) == 'string' and #title > 40 then
			title = title:sub(1, limit or 40)
		end
		return title
	end,
})

-- nodes
local modpath = minetest.get_modpath('magic_pen')
tool:load_node_definition(dofile(modpath .. '/nodes/any.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/lcd.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/book.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digtron.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/geocache.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/textline.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digiterms.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/travelnet.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/basic_signs.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/luacontroller.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/microcontroller.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/display_modpack.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digistuff_panel.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digistuff_touchscreen.lua'))
