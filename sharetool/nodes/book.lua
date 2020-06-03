--
-- Register books for sharetool
--

-- books
local nodes = {}

local bookcolors = {
	"red",
	"green",
	"blue",
	"violet",
	"grey",
	"brown"
}

for _, color in ipairs(bookcolors) do
	table.insert(nodes, string.format("homedecor:book_%s", color))
	table.insert(nodes, string.format("homedecor:book_open_%s", color))
end
table.insert(nodes, "homedecor:book")
table.insert(nodes, "homedecor:book_open")

-- get namespace defined at sharetool init.lua
local ns = metatool.ns('sharetool')

--luacheck: ignore unused argument node player
return {
	nodes = nodes,
	tooldef = {
		group = 'shared book',

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
