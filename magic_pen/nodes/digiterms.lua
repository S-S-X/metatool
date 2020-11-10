--
-- Register digiterms nodes for Magic pen
-- https://github.com/pyrollo/digiterms
--

local nodes = {}

for nodename, nodedef in pairs(minetest.registered_nodes) do
	if nodename:find('^digiterms:') and nodedef.groups and nodedef.groups.display_api then
		-- Match found, add to registration list
		table.insert(nodes, nodename)
	end
end

local get_content_title = metatool.ns('magic_pen').get_content_title

return {
	name = 'digiterms',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local content = meta:get("display_text")
			if type(content) == "string" then
				content = content:gsub("(\r?\n)%s+\r?\n","%1")
			end
			local title = get_content_title(content)
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = content,
				title = title,
				source = meta:get("owner"),
			}
		end,
	}
}
