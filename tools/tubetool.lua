--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local write_wand = function(itemstack, data, description)
	if not itemstack then
		return
	end

	local meta = itemstack:get_meta()
	local datastring = minetest.serialize(data)
	description = string.format('%s (%s)', (description or 'No description'), data.group)
	meta:set_string('data', datastring)
	meta:set_string('description', description)
end

local read_wand = function(itemstack)
	if not itemstack then
		return
	end

	local meta = itemstack:get_meta()
	local datastring = meta:get_string('data')
	return minetest.deserialize(datastring)
end

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'pipeworks:lua_tube000000', '' },
	{ 'default:obsidian_shard', '', '' }
}

local tool = metatool:register_tool('tubetool', {

	description = 'TubeTool',
	texture = 'tubetool_wand.png',
	recipe = recipe,
	on_use = function(tooldef, itemstack, player, pointed_thing, node, pos)

		local controls = player:get_player_control()

		if controls.aux1 or controls.sneak then
			local data, group = tooldef:copy(node, pos, player)
			local description = type(data) == 'table' and data.description or ('Data from ' .. minetest.pos_to_string(pos))
			write_wand(itemstack, {data = data, group = group}, description)
		else
			local data = read_wand(itemstack)
			if data then
				tooldef:paste(node, pos, player, data.data, data.group)
			else
				minetest.chat_send_player(
					player:get_player_name(),
					'no data stored in this wand, use sneak+use or special+use to record data.'
				)
			end
		end

		return itemstack
	end,
})

minetest.register_alias('tubetool:wand', 'tubetool:tubetool')

-- nodes
tool:load_node_definition('mese_tube')
tool:load_node_definition('teleport_tube')
--dofile(basedir .. '/tools/tubetool/sand_tube.lua')
--dofile(basedir .. '/tools/tubetool/injector.lua')
