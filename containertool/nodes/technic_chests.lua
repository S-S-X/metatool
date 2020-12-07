--
-- Register technic chests for Container tool
--

-- Collect nodes and on_receive_fields callback functions (no API available)
local nodes = {}
local on_receive_fields = {}
for nodename, nodedef in pairs(minetest.registered_nodes) do
	if nodedef.groups and nodedef.groups.technic_chest then
		-- Match found, add to registration list
		table.insert(nodes, nodename)
		on_receive_fields[nodename] = nodedef.on_receive_fields
	end
end

-- Collect lookup data for colored variants (no API available)
local colornode2basenode = {}
local basenode2colornode = {}
for _, nodename in ipairs(nodes) do
	for i,colordef in ipairs(technic.chests.colors) do
		local color_nodename = nodename .. "_" .. colordef[1]
		local nodedef = minetest.registered_nodes[color_nodename]
		if nodedef and nodedef.groups and nodedef.groups.technic_chest then
			colornode2basenode[color_nodename] = nodename
			if not basenode2colornode[nodename] then basenode2colornode[nodename] = {} end
			-- This can leave holes depending on what colors chest actually uses, always use `pairs` to iterate
			basenode2colornode[nodename][i] = color_nodename
		end
	end
end

local ns = metatool.ns('containertool')

-- Helpers
local has_digiline = ns.has_digiline
-- Base metadata reader
local get_common_attributes = ns.get_common_attributes
-- Special metadata setters
local set_key_lock_secret = ns.set_key_lock_secret
local set_digiline_meta = ns.set_digiline_meta
local set_splitstacks = ns.set_splitstacks
-- Common metadata setters/getters
local get_int = ns.get_int
local set_int = ns.set_int
local set_string = ns.set_string

local function set_color(meta, node, pos, color)
	if color then
		local is_color = not not technic.chests.colors[color]
		local newname
		if is_color then
			-- Set color
			newname = basenode2colornode[node.name] and basenode2colornode[node.name][color]
			if not newname then
				local basenode = colornode2basenode[node.name]
				newname = basenode2colornode[basenode] and basenode2colornode[basenode][color]
			end
		else
			-- Remove color
			newname = colornode2basenode[node.name]
		end
		if newname and newname ~= node.name then
			node.name = newname
			minetest.swap_node(pos, node)
			set_string(meta, "color", is_color and color or "")
		end
	end
end

local definition = {
	name = 'technic_chest',
	nodes = nodes,
	group = 'container',
	protection_bypass_read = "interact",
	settings = {
		copy_color = true,
	},
}

function definition:before_write(pos, player)
	return technic.chests.change_allowed(pos, player, true, true)
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local has_color = not not (basenode2colornode[node.name] or colornode2basenode[node.name])
	-- Read common data like owner, splitstacks, channel etc.
	local data = get_common_attributes(meta, node, pos, player)
	-- Information/interface
	data.color = self.settings.copy_color and (get_int(meta, "color") or has_color)
	data.sort_mode = get_int(meta, "sort_mode")
	data.autosort = get_int(meta, "autosort")
	data.infotext = meta:get("infotext")
	-- Digilines
	if has_digiline(node.name) then
		-- Chests seems to be clearing unchecked meta so we do the same
		data.technic_chest_put = get_int(meta, "send_put") or ""
		data.technic_chest_take = get_int(meta, "send_take") or ""
		data.technic_chest_inject = get_int(meta, "send_inject") or ""
		data.technic_chest_pull = get_int(meta, "send_pull") or ""
		data.technic_chest_overflow = get_int(meta, "send_overflow") or ""
	end
	-- Return collected data
	return data
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	-- Information/interface
	set_color(meta, node, pos, data.color)
	set_int(meta, "sort_mode", data.sort_mode)
	set_int(meta, "autosort", data.autosort)
	set_string(meta, "infotext", data.infotext)
	-- Security
	set_key_lock_secret(meta, data, node)
	-- Pipeworks
	set_splitstacks(meta, data, node, pos)
	-- Digilines
	local digiline_data = {
		channel = data.channel,
		send_put = data.technic_chest_put,
		send_take = data.technic_chest_take,
		send_inject = data.technic_chest_inject,
		send_pull = data.technic_chest_pull,
		send_overflow = data.technic_chest_overflow,
	}
	set_digiline_meta(meta, digiline_data, node)
	-- Update formspec
	on_receive_fields[node.name](pos, nil, {quit=1}, player)
end

return definition
