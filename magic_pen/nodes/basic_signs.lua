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
if minetest.registered_nodes["default:sign_wall_wood"] then
	table.insert(nodes, "default:sign_wall_wood")
end
if minetest.registered_nodes["default:sign_wall_steel"] then
	table.insert(nodes, "default:sign_wall_steel")
end

local truncate = metatool.ns('magic_pen').truncate

local paste
if signs_lib then
	paste = function(node, pos, player, data)
		if data.content then
			signs_lib.update_sign(pos, { text = truncate(data.content, 512) })
		end
	end
else
	paste = function(node, pos, player, data)
		if data.content then
			local meta = minetest.get_meta(pos)
			meta:set_string("text", truncate(data.content, 512))
			meta:set_string("infotext", data.content)
		end
	end
end

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
		paste = paste
	}
}
