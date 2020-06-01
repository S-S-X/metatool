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

-- Shared account name
local shared_account = metatool.settings('sharetool', 'shared_account')

local can_bypass = function(pos, player)
	-- Allow bypass protection if owner is shared or tool user
	local name = player:get_player_name()
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string('owner')
	local shared = meta:get_int('sharetool_shared_node')
	local allowed = name == owner or owner == shared_account or shared == 1
	if not allowed then
		minetest.record_protection_violation(pos, name)
	end
	return allowed
end

--luacheck: ignore unused argument node player
return {
	nodes = nodes,
	tooldef = {
		group = 'shared book',

		before_read = function(nodedef, pos, player)
			if metatool.before_read(nodedef, pos, player, true) then
				-- Player is allowed to operate in area without need to bypass protections
				return true
			end
			return can_bypass(pos, player)
		end,

		before_write = function(nodedef, pos, player)
			if metatool.before_write(nodedef, pos, player, true) then
				-- Player is allowed to operate in area without need to bypass protections
				return true
			end
			return can_bypass(pos, player)
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
			meta:set_int('sharetool_shared_node', 1)
			meta:set_string("owner", shared_account)
		end,
	}
}
