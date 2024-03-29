--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local S = metatool.S
local modpath = minetest.get_modpath('sharetool')

local recipe = nil
--[[
local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'default:book', '' },
	{ 'default:obsidian_shard', '', '' }
}
--]]

local sharetool = {
	description = 'ShareTool',
	name = 'ShareTool',
	texture = 'sharetool_wand.png',
	privs = 'ban',
	recipe = recipe,
	allow_use_empty = true,
	settings = {
		shared_account = 'shared',
		max_radius = 45,
	},
}

local function send_confirmation_message(player, targetname, nodename, result)
	local success = type(result) ~= 'table' or result.success or result.success == nil
	minetest.chat_send_player(player:get_player_name(),
		(type(result) == 'table' and result.description)
		or (success
			and S('Node %s ownership changed to %s', nodename, targetname)
			or S('Failed %s ownership change to %s', nodename, targetname)
		)
	)
end

--luacheck: ignore unused argument data group pointed_thing
function sharetool:on_read_node(player, pointed_thing, node, pos)
	local definition = self.nodes[node.name]
	if definition then
		local res = definition:copy(node, pos, player)
		send_confirmation_message(player, player:get_player_name(), node.name, res)
	end
	-- Return nil to keep tool without metadata
end

function sharetool:on_write_node(data, group, player, pointed_thing, node, pos)
	local definition = self.nodes[node.name]
	if definition then
		local res = definition:paste(node, pos, player)
		send_confirmation_message(player, self.settings.shared_account, node.name, res)
	end
end

local tool = metatool:register_tool('sharetool', sharetool)

-- Create namespace containing sharetool runtime data and functions
tool:ns({
	shared_account = metatool.settings('sharetool', 'shared_account'),
	player_exists = function(player)
		player = type(player) == "userdata" and player:get_player_name() or player
		return type(player) == "string" and minetest.get_auth_handler().get_auth(player) ~= nil
	end,
	set_area_owner = function(self, id, owner, player)
		--luacheck: globals areas
		if not self.player_exists(owner) then
			minetest.chat_send_player(player:get_player_name(), S('Player %s not found.', owner))
			return false
		end
		id = tonumber(id)
		if id == nil or not areas.areas[id] then
			minetest.chat_send_player(player:get_player_name(), id == nil
				and S('Invalid area id.')
				or S('Area %d not found from database.', id)
			)
			return false
		end
		areas.areas[id].owner = owner
		areas:save()
		return true
	end,
	mark_shared = function(meta)
		meta:set_int('sharetool_shared_node', 1)
	end,
	can_bypass = function(self, pos, player, owner_key)
		-- Allow bypass protection if owner is shared or tool user
		local name = player:get_player_name()
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string(owner_key)
		local shared = meta:get_int('sharetool_shared_node')
		local allowed = name == owner or owner == self.shared_account or shared == 1
		return allowed
	end,
	set_travelnet_owner = function(self, pos, player, owner)
		--luacheck: globals travelnet
		owner = owner or self.shared_account
		local name = player:get_player_name()
		local meta = minetest.get_meta(pos)
		local current_owner = meta:get_string('owner')
		if owner == current_owner then
			-- Nothing to do, current_owner is same as new owner
			return true
		end
		local network = meta:get_string("station_network")
		local station = meta:get_string("station_name")
		local current_owner_travelnets = travelnet.get_travelnets(current_owner, true)
		local new_owner_travelnets = travelnet.get_travelnets(owner, true)

		if not new_owner_travelnets[network] then
			new_owner_travelnets[network] = {}
		end
		if #new_owner_travelnets[network] >= travelnet.MAX_STATIONS_PER_NETWORK then
			minetest.chat_send_player(name, S('Too many travelnets attached to network %s owned by %s.', network, owner))
			return false
		end
		for stname,stdata in pairs(new_owner_travelnets[network]) do
			if stname == station then
				if stdata.pos.x ~= pos.x or stdata.pos.y ~= pos.y or stdata.pos.z ~= pos.z then
					-- Station already exists on network and is at different location
					minetest.chat_send_player(name, S(
						'Travelnet network %s owned by %s already has station %s at %s.',
						network, owner, station, minetest.pos_to_string(stdata.pos)
					))
					return false
				end
			end
		end
		-- Remove old network link
		if current_owner_travelnets[network] then
			current_owner_travelnets[network][station] = nil
			-- Save current owners travelnets
			travelnet.set_travelnets(current_owner, current_owner_travelnets)
		end
		-- Update owner
		meta:set_string('owner', owner)
		-- Attach to network
		new_owner_travelnets[network][station] = {pos=pos, timestamp=os.time()}
		-- Save new owners travelnets
		travelnet.set_travelnets(owner, new_owner_travelnets)
		-- Update formspec to reflect changes
		travelnet.update_formspec(pos, owner, nil)
		return true
	end
})

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/book.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/travelnet.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/missions.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/mapserver.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digiline_global_memory.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/pipeworks.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/any.lua'))
