--
-- Register rest of compatible nodes for Container tool
--

local ns = metatool.ns('containertool')

-- Node feature checker
local is_tubedevice = ns.is_tubedevice
-- Base metadata reader
local get_common_attributes = ns.get_common_attributes
-- Special metadata setters
local set_key_lock_secret = ns.set_key_lock_secret
local set_digiline_meta = ns.set_digiline_meta
local set_splitstacks = ns.set_splitstacks

-- Blacklist some nodes
local tubedevice_blacklist = {
	"^technic:.*_battery_box",
	"^technic:.*tool_workshop",
	"^pipeworks:dispenser",
	"^pipeworks:nodebreaker",
	"^pipeworks:deployer",
	"^digtron:",
	"^jumpdrive:",
	"^vacuum:",
}
local function blacklisted(name)
	for _,value in ipairs(tubedevice_blacklist) do
		if name:find(value) then return true end
	end
end

-- Collect nodes and on_receive_fields callback functions
local nodes = {}
local on_receive_fields = {}
for nodename, nodedef in pairs(minetest.registered_nodes) do print(nodename)
	if is_tubedevice(nodename) and not blacklisted(nodename) then
		-- Match found, add to registration list
		table.insert(nodes, nodename)
		if nodedef.on_receive_fields then
			on_receive_fields[nodename] = nodedef.on_receive_fields
		end
	end
end

local definition = {
	name = 'common_container',
	nodes = nodes,
	group = 'container',
	protection_bypass_read = "interact",
}

function definition:before_write(pos, player)
	-- Stay safe and check both owner and protection for unknown nodes
	local meta = minetest.get_meta(pos)
	local owner = meta:get("owner")
	local owner_check = owner == nil or owner == player:get_player_name()
	if not owner_check then
		minetest.record_protection_violation(pos, player:get_player_name())
	end
	return owner_check and metatool.before_write(self, pos, player)
end

function definition:copy(node, pos, player)
	-- Read common data like owner, splitstacks, channel etc.
	return get_common_attributes(minetest.get_meta(pos), node, pos, player)
end

function definition:paste(node, pos, player, data)
	local meta = minetest.get_meta(pos)
	set_key_lock_secret(meta, data, node)
	set_splitstacks(meta, data, node, pos)
	set_digiline_meta(meta, {channel = data.channel}, node)
	-- Yeah, sorry... everyone just keeps their internal stuff "protected"
	if on_receive_fields[node.name] then
		if not pcall(function()on_receive_fields[node.name](pos, "", {}, player)end) then
			pcall(function()on_receive_fields[node.name](pos, "", {quit=1}, player)end)
		end
	end
end

return definition
