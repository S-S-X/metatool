--
-- Register technic chests for Container tool
--

local ns = metatool.ns('containertool')

-- Helper functions
local is_tubedevice = ns.is_tubedevice
local is_blacklisted = ns.is_blacklisted
-- Base metadata reader
local get_common_attributes = ns.get_common_attributes
-- Special metadata setters
local set_key_lock_secret = ns.set_key_lock_secret
local set_digiline_meta = ns.set_digiline_meta
local set_splitstacks = ns.set_splitstacks

-- Collect nodes and callback functions (no API available)
local nodes = {}
local allow_metadata_inventory_put = {}
-- Remove items from machines
--local allow_metadata_inventory_take = {}
local on_receive_fields = {}

for nodename, nodedef in pairs(minetest.registered_nodes) do
	if nodedef.groups and nodedef.groups.technic_machine then
		if nodedef.allow_metadata_inventory_put and nodedef.allow_metadata_inventory_take then
			print("Possibly upgradeable technic machine: ", nodename)
			-- Match found, add to registration list
			table.insert(nodes, nodename)
			allow_metadata_inventory_put[nodename] = nodedef.allow_metadata_inventory_put
			--allow_metadata_inventory_take[nodename] = nodedef.allow_metadata_inventory_take
			if nodedef.on_receive_fields and is_tubedevice(nodename) and not is_blacklisted(nodename) then
				print("Tube device with on_receive_fields: ", nodename)
				on_receive_fields[nodename] = nodedef.on_receive_fields
			end
		end
	end
end

-- Inventory list names for upgrades, assume single inventory slot
local upgrade_inventory_lists = { "upgrade1", "upgrade2" }

local definition = {
	name = 'technic_machine',
	nodes = nodes,
	group = 'container',
	protection_bypass_read = "interact",
}

function definition:before_write(pos, player)
	-- Check both owner and protection for registered machines
	local meta = minetest.get_meta(pos)
	local owner = meta:get("owner")
	local owner_check = owner == nil or owner == player:get_player_name()
	if not owner_check then
		minetest.record_protection_violation(pos, player:get_player_name())
	end
	return owner_check and metatool.before_write(self, pos, player)
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	-- Read common data like owner, splitstacks, channel etc.
	local data = get_common_attributes(meta, node, pos, player)

	-- Look for upgrade inventories
	data.inv = {}
	local has_upgrades = false
	local inv = meta:get_inventory()
	for _,list in ipairs(upgrade_inventory_lists) do
		if inv:get_size(list) == 1 then
			-- Valid upgrade inventory found, read and save contents
			local upgradestack = inv:get_stack(list, 1)
			if upgradestack:get_count() == 1 then
				-- Use table just to possibly allow multiple slots if needed, stack size is hardcoded to one item
				data.inv[list] = { ("%s 1"):format(upgradestack:get_name()) }
				has_upgrades = true
			end
		end
	end

	if has_upgrades then
		data.description = ("%s with upgrades"):format(data.description)
	end

	return data
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)

	-- Set common metadata values
	set_key_lock_secret(meta, data, node)
	set_splitstacks(meta, data, node, pos)
	set_digiline_meta(meta, {channel = data.channel}, node)

	-- Handle possible machine upgrades and player inventory
	if type(data.inv) == "table" then
		local playerinv = player:get_inventory()
		local inv = meta:get_inventory()
		for _,list in ipairs(upgrade_inventory_lists) do
			-- Check if there's anything to insert and make sure target is empty
			if data.inv[list] and data.inv[list][1] and inv:get_size(list) == 1 and inv:is_empty(list) then
				local datastack = ItemStack(data.inv[list][1])
				-- Allow only itemstacks with single item, has to be changed if stackable upgrades are allowed
				if not datastack:is_empty() then
					local itemcount = allow_metadata_inventory_put[node.name](pos, list, 1, datastack, player)
					if itemcount and itemcount > 0 then
						datastack:set_count(itemcount)
						local playerstack = playerinv:remove_item("main", datastack)
						inv:set_stack(list, 1, playerstack)
					end
				end
			end
			-- Remove items from machine
			--local itemcount = allow_metadata_inventory_take[node.name](pos, list, index, stack, player)
		end
	end

	-- Yeah, sorry... everyone just keeps their internal stuff "protected"
	if on_receive_fields[node.name] then
		if not pcall(function()on_receive_fields[node.name](pos, "", {}, player)end) then
			pcall(function()on_receive_fields[node.name](pos, "", {quit=1}, player)end)
		end
	end
end

return definition
