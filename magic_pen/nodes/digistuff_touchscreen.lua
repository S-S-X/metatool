--
-- Register Digistuff Touchscreen for Magic pen
--

--luacheck: ignore unused argument node player
return {
	name = 'touchscreen',
	nodes = "digistuff:touchscreen",
	tooldef = {
		group = 'text',
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local data = minetest.deserialize(meta:get_string("data"))
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = type(data) == "table" and table.concat(data, "\n"),
			}
		end,
	}
}
