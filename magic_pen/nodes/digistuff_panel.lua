--
-- Register Digistuff panel for Magic pen
--

--luacheck: ignore unused argument node player
return {
	name = 'digistuff_panel',
	nodes = "digistuff:panel",
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = meta:get("text"),
			}
		end,
	}
}
