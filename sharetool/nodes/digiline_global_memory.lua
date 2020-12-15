--
-- Register global memory controller for sharetool
--

-- get namespace defined at sharetool init.lua
local ns = metatool.ns('sharetool')

local definition = {
	name = 'global_memory',
	nodes = "digiline_global_memory:controller",
	group = 'shared global memory',
}

function definition:before_read(pos, player)
	if ns:can_bypass(pos, player, 'owner') or metatool.before_read(self, pos, player, true) then
		-- Player is allowed to bypass protections or operate in area
		return true
	end
	return false
end

function definition:before_write(pos, player)
	if ns:can_bypass(pos, player, 'owner') or metatool.before_write(self, pos, player, true) then
		-- Player is allowed to bypass protections or operate in area
		return true
	end
	return false
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	-- change ownership and mark as shared node
	ns.mark_shared(meta)
	meta:set_string("owner", name)
	return {
		description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
	}
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	-- change ownership and mark as shared node
	ns.mark_shared(meta)
	meta:set_string("owner", ns.shared_account)
end

return definition
