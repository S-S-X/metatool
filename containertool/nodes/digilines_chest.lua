--
-- Register digilines chest for containertool
--

local ns = metatool.ns('containertool')
local description = ns.description
local get_digiline_channel = ns.get_digiline_channel

local definition = {
	name = 'digilines_chest',
	nodes = "digilines:chest",
	group = 'container',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local channel = get_digiline_channel(meta, node)
	if channel then
		return {
			description = description(meta, node, pos),
			channel = channel,
		}
	end
end

function definition:paste(node, pos, player, data)
	if data.channel and metatool.settings("containertool", "copy_digiline_channel") then
		local nodedef = minetest.registered_nodes[node.name]
		nodedef.on_receive_fields(pos, "", {channel=data.channel}, player)
	end
end

return definition
