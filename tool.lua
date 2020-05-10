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

minetest.register_craftitem('tubetool:wand', {

	description = 'TubeTool',
	inventory_image = 'tubetool_wand.png',
	groups = {},
	stack_max = 1,
	wield_image = 'tubetool_wand.png',
	wield_scale = { x = 0.8, y = 1, z = 0.8 },
	liquids_pointable = false,
	node_placement_prediction = nil,

	on_use = function(itemstack, player, pointed_thing)
		if not player or type(player) == 'table' then
			return
		end

		local node, pos = tubetool:get_node(player, pointed_thing)
		if not node then
			return
		end

		local controls = player:get_player_control()

		if controls.aux1 or controls.sneak then
			local data, group = tubetool:copy(node, pos, player)
			local description = type(data) == 'table' and data.description or ('Data from ' .. minetest.pos_to_string(pos))
			write_wand(itemstack, {data = data, group = group}, description)
		else
			local data = read_wand(itemstack)
			if data then
				tubetool:paste(node, pos, player, data.data, data.group)
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

minetest.register_craft({
	output = 'tubetool:wand 1',
	recipe = {
		{ '', '', 'default:mese_crystal' },
		{ '', 'pipeworks:lua_tube000000', '' },
		{ 'default:obsidian_shard', '', '' }
	}
})

minetest.register_craft({
	type = "shapeless",
	output = 'tubetool:wand 1',
	recipe = { 'tubetool:wand' }
})
