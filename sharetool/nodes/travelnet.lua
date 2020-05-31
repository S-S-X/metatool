--
-- Register travelnet for sharetool
--

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
--
-- FIXME: THIS IS JUST CLEANED UP COPY OF book.lua
--
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-- shared account name
local shared_account = 'shared'

-- travelnet nodes
local nodes = {}

--luacheck: ignore unused argument node player
return {
	nodes = nodes,
	tooldef = {
		group = 'shared travelnet',
		protection_bypass_read = 'ban',
		protection_bypass_write = 'ban',

		before_read = function(nodedef, pos, player)
			if not metatool.before_read(nodedef, pos, player) then
				-- Player is allowed to operate in area without need to bypass protections
				return true
			end
			-- Allow bypass protection if owner is shared or tool user
			local name = player:get_player_name()
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string('owner')
			local shared = meta:get_int('sharetool_shared_node')
			return name == owner or owner == shared_account or shared == 1
		end,

		before_write = function(nodedef, pos, player)
			if metatool.before_write(nodedef, pos, player) then
				-- Player is allowed to operate in area without need to bypass protections
				return true
			end
			-- Allow bypass protection if owner is shared or tool user
			local name = player:get_player_name()
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string('owner')
			local shared = meta:get_int('sharetool_shared_node')
			return name == owner or owner == shared_account or shared == 1
		end,

		copy = function(node, pos, player)
			-- Copy function does not really copy anything here
			-- but instead it will claim ownership of pointed
			-- node and mark it as shared node
			local meta = minetest.get_meta(pos)
			local name = player:get_player_name()

			-- change ownership and mark as shared node
			meta:set_int('sharetool_shared_node', 1)
			meta:set_string("owner", name)

			-- return data required for replicating this tube settings
			return {
				description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
			}
		end,

		--luacheck: ignore unused argument data
		paste = function(node, pos, player, data)
			-- Copy function does not really copy anything here
			-- but instead it will claim ownership of pointed
			-- node and mark it as shared node
			local meta = minetest.get_meta(pos)

			-- change ownership and mark as shared node
			meta:set_int('sharetool_shared_node', 1)
			meta:set_string("owner", shared_account)
		end,
	}
}
