--
-- Register jumpdrive engines for Container tool
--

if not minetest.get_modpath('jumpdrive') then
	return
end

local definition = {
	name = "jumpdrive_engine",
	nodes = {
		"jumpdrive:engine",
		"jumpdrive:area_engine",
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

	-- Get installed upgrades
	data.inv = { upgrade = {} }
	local inv = meta:get_inventory()
	local invlist = inv:get_list("upgrade")
	local upgrades = data.inv.upgrade

	for index, stack in pairs(invlist) do
		if not stack:is_empty() then
			upgrades[index] = ("%s %d"):format(stack:get_name(), stack:get_count())
		end
	end

	return data
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)

	-- Set common metadata values
	set_digiline_meta(meta, {channel = data.channel}, node)

	if type(data.inv) == "table" and type(data.inv.upgrade) == "table" then

		-- Handle machine upgrades and player inventory
		local require_update = false

		local playerinv = player:get_inventory()
		local inv = meta:get_inventory()
		for index, itemstring in pairs(data.inv.upgrades) do
			if inv:get_stack("upgrade", index):is_empty() then
				-- Target slot is empty, try to place upgrade item
				local datastack = ItemStack(itemstring)
				if datastack:get_count() > 0 then
					local playerstack = playerinv:remove_item("main", datastack)
					inv:set_stack("upgrade", index, playerstack)
					require_update = true
				end
			end
		end

		if require_update then
			jumpdrive.upgrade.calculate(pos)
		end
	end

end

return definition
