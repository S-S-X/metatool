--
-- Register textline for Magic pen
--

--luacheck: ignore unused argument node player
return {
	name = 'book',
	nodes = "textline:text",
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
