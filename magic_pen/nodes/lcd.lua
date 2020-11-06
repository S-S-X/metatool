--
-- Register lcd for Magic pen
--

local nodes = {}

--luacheck: ignore unused argument node player
return {
	name = 'book',
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
	}
}
