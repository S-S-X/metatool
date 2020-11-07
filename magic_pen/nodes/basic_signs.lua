--
-- Register basic_signs for Magic pen
-- https://gitlab.com/VanessaE/basic_signs
--

local nodes = {}

for nodename,_ in pairs(minetest.registered_nodes) do
	if nodename:find('^basic_signs:') then
		-- Match found, add to registration list
		table.insert(nodes, nodename)
	end
end

--luacheck: ignore unused argument nodedef node player
return {
	name = 'basic_signs',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		before_write = function(nodedef, pos, player)
			return signs_lib.can_modify(pos, player)
		end,
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = meta:get("text"),
				source = meta:get("owner"),
			}
		end,
		--luacheck: ignore unused argument data
		paste = function(node, pos, player, data)
			signs_lib.update_sign(pos, { text = data.content })
		end,
	}
}
