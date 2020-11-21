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
local get_content_title = metatool.ns('magic_pen').get_content_title

local paste
if signs_lib then
	paste = function(self, node, pos, player, data)
		if data.content then
			signs_lib.update_sign(pos, { text = truncate(data.content, 512) })
		end
	end
else
	paste = function(self, node, pos, player, data)
		if data.content then
			local meta = minetest.get_meta(pos)
			meta:set_string("text", truncate(data.content, 512))
			meta:set_string("infotext", data.content)
		end
	end
end

local definition = {
	name = 'basic_signs',
	nodes = nodes,
	group = 'text',
	protection_bypass_read = "interact",
	paste = paste
}

function definition:before_write(pos, player)
	return signs_lib.can_modify(pos, player)
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local content = meta:get("text")
	local nicename = minetest.registered_nodes[node.name].description or node.name
	return {
		description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
		content = content,
		title = get_content_title(content),
		source = meta:get("owner"),
	}
end

return definition
