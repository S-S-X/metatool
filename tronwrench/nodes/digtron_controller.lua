--
-- Register digtron controller for tronwrench
--

local definition = {
	name = 'digtron_controller',
	nodes = "digtron:auto_controller",
	group = 'digtron controller',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv and inv:get_stack("stop", 1)
	return {
		description = metatool.util.description(pos, node, meta),
		nodename = (stack and stack:get_count() > 0) and stack:get_name(),
		cycles = meta:get_int("cycles"),
		slope = meta:get_int("slope"),
		offset = meta:get_int("offset"),
		period = meta:get_int("period"),
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv:get_size("stop") ~= 1 then
		minetest.chat_send_player(player:get_player_name(), "Cannot get inventory, your digtron might be broken")
		return
	end
	if not data.nodename then
		inv:set_stack("stop", 1, ItemStack(""))
	elseif minetest.get_item_group(data.nodename, "digtron") == 0 then
		inv:set_stack("stop", 1, ItemStack(data.nodename .. " 1"))
	end
	meta:set_int("cycles", data.cycles)
	meta:set_int("slope", data.slope)
	meta:set_int("offset", data.offset)
	meta:set_int("period", data.period)
end

return definition
