--
-- Register technic self contained injector for Container tool
--

local ns = metatool.ns('containertool')

-- Base metadata reader
local get_common_attributes = ns.get_common_attributes
-- Special metadata setters
local set_splitstacks = ns.set_splitstacks

local nodedef = minetest.registered_nodes["technic:injector"]
local on_receive_fields = nodedef and (nodedef.on_receive_fields or function(...)end)

local definition = {
	name = 'technic_injector',
	nodes = "technic:injector",
	group = 'container',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	-- Read common data like owner, splitstacks, channel etc.
	local data = get_common_attributes(meta, node, pos, player)
	-- Technic injector specific configuration
	local enabled = minetest.get_node_timer(pos):is_started() or nil
	if not enabled then
		-- technic mod version might not have nodetimers for injector, check formspec
		local formspec = meta:get_string("formspec")
		if formspec:find("button%[[0-9.;,]+;enable;") then
			enabled = false
		end
	end
	data.enabled = enabled
	data.technic_sci_mode = meta:get_string("mode")
	-- Return collected data
	return data
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	-- Pipeworks
	set_splitstacks(meta, data, node, pos)
	-- Update formspec
	local fields = {
		enable = data.enabled and 1 or nil,
		disable = (data.enabled == false) and 1 or nil,
		mode_item = (data.technic_sci_mode == "single items") and 1 or nil,
		mode_stack = (data.technic_sci_mode == "whole stacks") and 1 or nil,
	}
	for k,v in pairs(fields) do
		on_receive_fields(pos, "", {[k] = v}, player)
	end
end

return definition
