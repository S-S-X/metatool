--
-- Register digtron builder for tronwrench
--

local definition = {
	name = 'digtron_builder',
	nodes = "digtron:builder",
	group = 'digtron builder',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv and inv:get_stack("main", 1)
	return {
		description = metatool.util.description(pos, node, meta),
		nodename = (stack and stack:get_count() > 0) and stack:get_name(),
		period = meta:get_int("period"),
		offset = meta:get_int("offset"),
		build_facing = meta:get_int("build_facing"),
		extrusion = meta:get_int("extrusion"),
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv:get_size("main") ~= 1 then
		minetest.chat_send_player(player:get_player_name(), "Cannot get inventory, your digtron might be broken")
		return
	end
	if not data.nodename then
		inv:set_stack("main", 1, ItemStack(""))
	elseif data.nodename ~= "air" and minetest.get_item_group(data.nodename, "digtron") == 0 then
		local nodename = digtron.builder_read_item_substitutions[data.nodename] or data.nodename
		inv:set_stack("main", 1, ItemStack(nodename .. " 1"))
	end
	meta:set_int("period", data.period)
	meta:set_int("offset", data.offset)
	meta:set_int("build_facing", data.build_facing)
	meta:set_int("extrusion", data.extrusion)
	digtron.update_builder_item(pos)
end

return definition
