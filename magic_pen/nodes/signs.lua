--
-- Register signs for Magic pen
--

local nodes = {
	"default:sign_wall_wood",
	"default:sign_wall_steel",
}

--luacheck: ignore unused argument node player
return {
	name = 'sign',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			return {
				description = "NOT IMPLEMENTED",
				content = "NOT IMPLEMENTED",
			}
		end,

		--luacheck: ignore unused argument data
		paste = function(node, pos, player, data)
			local meta = minetest.get_meta(pos)
		end,
	}
}
