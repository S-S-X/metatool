--
-- Register jumpdrive engines for Container tool
--

local definition = {
	name = "jumpdrive_engine",
	nodes = {
		"jumpdrive:engine"
	},
	group = "jumpdrive_engine",
	protection_bypass_read = "interact",
}

local ns = metatool.ns('containertool')

-- Base metadata reader and metadata setters
local get_common_attributes = ns.get_common_attributes
local set_digiline_meta = ns.set_digiline_meta

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	-- Read common data like owner, splitstacks, channel etc.
	local data = get_common_attributes(meta, node, pos, player)

	return data
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)

	-- Set common metadata values
	set_digiline_meta(meta, {channel = data.channel}, node)

	-- Handle possible machine upgrades and player inventory
	-- TODO, Nothing here yet.
end

return definition
