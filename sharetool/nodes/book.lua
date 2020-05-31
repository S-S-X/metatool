--
-- Register books for sharetool
--

-- shared account name
local shared_account = 'shared'

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

--luacheck: ignore unused argument node player
return {
	nodes = nodes,
	tooldef = {
		group = 'shared book',

		before_read = function(nodedef, pos, player)
			if metatool.before_read(nodedef, pos, player) then
				-- Player is allowed to operate in area without need to bypass protections
				return true
			end
			-- Allow bypass protection if owner is shared or tool user
			local name = player:get_player_name()
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string('owner')
			local shared = meta:get_int('sharetool_shared_node')
			return name == owner or name == shared_account or shared == 1
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
			return name == owner or name == shared_account or shared == 1
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
