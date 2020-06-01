--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local modpath = minetest.get_modpath('sharetool')

local recipe = nil
--[[
local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'default:book', '' },
	{ 'default:obsidian_shard', '', '' }
}
--]]

--luacheck: ignore unused argument data group pointed_thing
local tool = metatool:register_tool('sharetool', {
	description = 'ShareTool',
	name = 'ShareTool',
	texture = 'sharetool_wand.png',
	privs = 'ban',
	recipe = recipe,
	allow_use_empty = true,
	settings = {
		shared_account = 'shared'
	},
	on_read_node = function(tooldef, player, pointed_thing, node, pos)
		local definition = tooldef.nodes[node.name]
		if definition then
			local data = definition.copy(node, pos, player)
			local name = player:get_player_name()
			minetest.chat_send_player(
				name,
				string.format('Node %s ownership changed to %s', node.name, name)
			)
			local description = (type(data) == 'table' and data.description)
				and data.description
				or 'Something weird happened!! ???'
			-- Return nil as data storage is not needed for this tool
			return nil, definition.group, description
		end
	end,
	on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos)
		local definition = tooldef.nodes[node.name]
		if definition then
			local result = definition.paste(node, pos, player)
			minetest.chat_send_player(
				player:get_player_name(),
				string.format('Node %s ownership changed to %s', node.name, tooldef.settings.shared_account)
			)
			return result
		end
	end,
})

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/book.lua'))
-- tool:load_node_definition(dofile(modpath .. '/nodes/travelnet.lua'))
-- tool:load_node_definition(dofile(modpath .. '/nodes/poi.lua')
