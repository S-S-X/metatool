--
-- Register digtron crate for Magic pen
--

local definition = {
	name = 'digtron_crate',
	nodes = {
		"digtron:loaded_crate",
		"digtron:loaded_locked_crate",
	},
	group = 'text',
	protection_bypass_read = "interact",
}

local digtron_on_receive_fields
if minetest.registered_nodes["digtron:loaded_crate"] then
	digtron_on_receive_fields = minetest.registered_nodes["digtron:loaded_crate"].on_receive_fields
end
local get_content_title = metatool.ns('magic_pen').get_content_title

local function get_node_name(node_image)
	return type(node_image.node) == "table" and node_image.node.name or "ignore"
end

local function node_pos_to_string(node_image)
	if type(node_image.pos) == "table"
		and type(node_image.pos.x) == "number"
		and type(node_image.pos.y) == "number"
		and type(node_image.pos.z) == "number" then
		return ("%d,%d,%d"):format(node_image.pos.x, node_image.pos.y, node_image.pos.z)
	end
	return "<invalid pos>"
end

local function layout_to_text(layout)
	local results = {}
	local counts = {}
	for _,node_image in pairs(layout.all) do
		local nodename = get_node_name(node_image)
		local nodepos = node_pos_to_string(node_image)
		table.insert(results, ("%s at %s"):format(nodename, nodepos))
		counts[nodename] = counts[nodename] and (counts[nodename] + 1) or 1
	end
	if #results > 0 then
		counts_text = "Component count:\n"
		for nodename, count in pairs(counts) do
			counts_text = ("%s%d %s\n"):format(counts_text, count, nodename)
		end
		return counts_text .. "Component locations:\n" .. table.concat(results, "\n")
	end
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local layout_string = meta:get_string("crated_layout")
	local layout = DigtronLayout.deserialize(layout_string)
	return {
		description = ("%s at %s"):format(node.name, minetest.pos_to_string(pos)),
		source = meta:get("owner"),
		title = meta:get("title"),
		content = layout and layout_to_text(layout),
	}
end

if type(digtron_on_receive_fields) == "function" then
	function definition:paste(node, pos, player, data)
		local title = data.title or data.content and get_content_title(data.title or data.content)
		if title then
			digtron_on_receive_fields(pos, "", { save = 1, title = title }, player)
		end
	end
end

return definition
