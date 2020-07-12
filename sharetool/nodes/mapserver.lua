--
-- Register POI for sharetool
--

-- get namespace defined at sharetool init.lua
local ns = metatool.ns('sharetool')

--luacheck: ignore unused argument node player
return {
	name = 'poi',
	nodes = {
		'mapserver:label',
		'mapserver:poi',
		'mapserver:poi_blue',
		'mapserver:poi_green',
		'mapserver:poi_orange',
		'mapserver:poi_red',
		'mapserver:poi_purple',
	},
	tooldef = {
		group = 'shared poi',

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
			-- node and mark it as shared node
			local meta = minetest.get_meta(pos)
			local name = player:get_player_name()

			-- change ownership and mark as shared node
			ns.mark_shared(meta)
			meta:set_string("owner", name)

			-- return new description for tool
			return {
				description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
			}
		end,

		--luacheck: ignore unused argument data
		paste = function(node, pos, player, data)
			-- Paste function does not really paste anything here
			-- but instead it will restore ownership of pointed
			-- node and mark it as shared node
			local meta = minetest.get_meta(pos)

			-- change ownership and mark as shared node
			ns.mark_shared(meta)
			meta:set_string("owner", ns.shared_account)
		end,
	}
}
