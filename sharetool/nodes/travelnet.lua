--
-- Register travelnet for sharetool
--

-- get namespace defined at sharetool init.lua
local ns = metatool.ns('sharetool')

local definition = {
	name = 'travelnet',
	nodes = {
		'travelnet:travelnet',
		'locked_travelnet:travelnet',
		'travelnet:travelnet_private',
		'travelnet:elevator',
	},
	group = 'shared travelnet',
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
	-- Copy function does not really copy anything here
	-- but instead it will claim ownership of pointed
	-- node and mark it as shared node.

	-- Change ownership to player and mark as shared node
	return {
		success = ns:set_travelnet_owner(pos, player, player:get_player_name()),
		description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
	}
end

function definition:paste(node, pos, player, data)
	-- Paste function does not really paste anything here
	-- but instead it will restore ownership of pointed
	-- node and mark it as shared node

	-- Change ownership to shared account and mark as shared node
	return {
		success = ns:set_travelnet_owner(pos, player),
		description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
	}
end

return definition
