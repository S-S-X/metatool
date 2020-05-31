--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local modpath = minetest.get_modpath('sharetool')

local rescipe = nil
--[[
local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'default:book', '' },
	{ 'default:obsidian_shard', '', '' }
}
--]]

--luacheck: ignore unused argument tooldef player pointed_thing node pos
local tool = metatool:register_tool('sharetool', {
	description = 'ShareTool',
	name = 'ShareTool',
	texture = 'sharetool_wand.png',
	privs = 'ban',
	recipe = recipe,
	on_read_node = function(tooldef, player, pointed_thing, node, pos)
		local data, group = tooldef:copy(node, pos, player)
		local description = type(data) == 'table' and data.description or 'Something weird happened!! ???'
		return data, group, description
	end,
	on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos)
		tooldef:paste(node, pos, player, data, group)
	end,
})

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/book.lua'))
-- tool:load_node_definition(dofile(modpath .. '/nodes/travelnet.lua'))
-- tool:load_node_definition(dofile(modpath .. '/nodes/poi.lua')
