--
-- Register drawers for Container tool
--

if not minetest.get_modpath('drawers') then
	return
end

local ns = metatool.ns('containertool')

-- Helper functions
local get_description = ns.description

local properties = {
	on_construct = drawers.drawer_on_construct,
	on_destruct = drawers.drawer_on_destruct,
	on_dig = drawers.drawer_on_dig,
	allow_metadata_inventory_put = drawers.drawer_allow_metadata_inventory_put,
	-- not typo, take and put are same function in drawers API:
	allow_metadata_inventory_take = drawers.drawer_allow_metadata_inventory_put,
	on_metadata_inventory_put = drawers.add_drawer_upgrade,
	on_metadata_inventory_take = drawers.remove_drawer_upgrade,
}

local function is_drawer(nodedef)
	for key, value in pairs(properties) do
		if nodedef[key] ~= value then
			return false
		end
	end
	return true
end

-- Collect nodes
local nodes = {}
for nodename, nodedef in pairs(minetest.registered_nodes) do
	if is_drawer(nodedef) then
		table.insert(nodes, nodename)
	end
end

local definition = {
	name = 'drawer',
	nodes = nodes,
	group = 'drawer',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	local inv = meta:get_inventory()
	local invlist = inv:get_list("upgrades")
	local upgrades = {}
	for index, stack in pairs(invlist) do
		if not stack:is_empty() then
			upgrades[index] = ("%s %d"):format(stack:get_name(), stack:get_count())
		end
	end

	return {
		description = get_description(meta, node, pos),
		owner = meta:get("owner"),
		inv = {
			upgrades = upgrades,
		}
	}
end

function definition:paste(node, pos, player, data)
	if type(data.inv) ~= "table" or type(data.inv.upgrades) ~= "table" then
		return
	end

	-- Handle possible machine upgrades and player inventory
	local meta = minetest.get_meta(pos)
	local require_update = false

	local playerinv = player:get_inventory()
	local inv = meta:get_inventory()
	for index, itemstring in pairs(data.inv.upgrades) do
		if inv:get_stack("upgrades", index):is_empty() then
			-- Target slot is empty, try to place upgrade item
			local datastack = ItemStack(itemstring)
			local itemcount = drawers.drawer_allow_metadata_inventory_put(pos, "upgrades", index, datastack, player)
			-- Usually if there's space for item itemcount should be same as datastack count
			if itemcount and itemcount > 0 and itemcount <= datastack:get_count() then
				datastack:set_count(itemcount)
				local playerstack = playerinv:remove_item("main", datastack)
				inv:set_stack("upgrades", index, playerstack)
				require_update = true
			end
		end
	end

	if require_update then
		drawers.update_drawer_upgrades(pos)
	end
end

return definition
