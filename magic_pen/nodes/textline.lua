--
-- Register textline for Magic pen
--

--luacheck: ignore unused argument node player
return {
	name = 'textline',
	nodes = "textline:text",
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			return {
				description = ("Textline at %s"):format(minetest.pos_to_string(pos)),
				content = meta:get("text"),
			}
		end,
	}
}
