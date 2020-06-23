--
-- Register travelnet for sharetool
--

-- get namespace defined at sharetool init.lua
local ns = metatool.ns('sharetool')

--luacheck: ignore unused argument node player
return {
	name = 'travelnet',
	nodes = {
		'travelnet:travelnet',
		'locked_travelnet:travelnet',
		'travelnet:travelnet_private',
		'travelnet:elevator',
	},
	tooldef = {
		group = 'shared travelnet',

		before_read = function(nodedef, pos, player)
			if ns:can_bypass(pos, player, 'owner') or metatool.before_read(nodedef, pos, player, true) then
				-- Player is allowed to bypass protections or operate in area
				return true
			end
			return false
		end,

		before_write = function(nodedef, pos, player)
			if ns:can_bypass(pos, player, 'owner') or metatool.before_write(nodedef, pos, player, true) then
				-- Player is allowed to bypass protections or operate in area
				return true
			end
			return false
		end,

		copy = function(node, pos, player)
			-- Copy function does not really copy anything here
			-- but instead it will claim ownership of pointed
			-- node and mark it as shared node.

			-- Change ownership to player and mark as shared node
			return {
				success = ns:set_travelnet_owner(pos, player, player:get_player_name()),
				description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
			}
		end,

		--luacheck: ignore unused argument data
		paste = function(node, pos, player, data)
			-- Paste function does not really paste anything here
			-- but instead it will restore ownership of pointed
			-- node and mark it as shared node

			-- Change ownership to shared account and mark as shared node
			return {
				success = ns:set_travelnet_owner(pos, player),
				description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
			}
		end,
	}
}
