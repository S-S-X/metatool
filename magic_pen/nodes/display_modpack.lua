--
-- Register display_modpack nodes for Magic pen
-- https://github.com/pyrollo/display_modpack
--

local S = signs.intllib

-- Collected nodes that will be registered for tool
local nodes = {}

-- Needles to search from haystack
local needles = {
	"^signs:",
	"^signs_road:",
	"^boards:",
}

for _,needle in ipairs(needles) do
	for nodename,_ in pairs(minetest.registered_nodes) do
		if nodename:find(needle) then
			-- Match found, add to registration list
			table.insert(nodes, nodename)
		end
	end
end

-- Get metadata keys for content and title
local metakeys = {
	["signs:paper_poster"] = {"text", "display_text", nil},
}
setmetatable(metakeys, { __index = function() return {"display_text", nil, nil} end })

local function get_content(keys, meta) return keys[1] and meta:get(keys[1]) end
local function get_title(keys, meta) return keys[2] and meta:get(keys[2]) end
local function get_author(keys, meta) return keys[3] and meta:get(keys[3]) end

local function set_content(keys, meta, value) if keys[1] and value then meta:set_string(keys[1], value) end end
local function set_title(keys, meta, value) if keys[2] and value then meta:set_string(keys[2], value) end end
--local function set_author(keys, meta, value) if keys[3] and value then meta:set_string(keys[3], value) end end

return {
	name = 'display_modpack',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local keys = metakeys[node.name]
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = get_content(keys, meta),
				source = get_author(keys, meta),
				title = get_title(keys, meta),
			}
		end,
		paste = function(node, pos, player, data)
			local meta = minetest.get_meta(pos)
			local keys = metakeys[node.name]
			-- Set infotext. Update node and text entity
			if keys[2] then
				set_content(keys, meta, data.content)
				set_title(keys, meta, data.title)
				if data.title then
					meta:set_string("infotext", "\"".. data.title .."\"\n"..S("(right-click to read more text)"))
				end
			elseif data.content then
				signs_api.set_display_text(pos, data.content)
			end
			display_api.update_entities(pos)
		end,
	}
}
