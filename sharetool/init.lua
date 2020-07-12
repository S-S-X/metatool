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

--luacheck: ignore unused argument data group pointed_thing
local tool = metatool:register_tool('sharetool', {
	description = 'ShareTool',
	name = 'ShareTool',
	texture = 'sharetool_wand.png',
	privs = 'ban',
	recipe = recipe,
	allow_use_empty = true,
	settings = {
		shared_account = 'shared'
	},
	on_read_node = function(tooldef, player, pointed_thing, node, pos)
		local definition = tooldef.nodes[node.name]
		if definition then
			local res = definition.copy(node, pos, player)
			local name = player:get_player_name()
			local success = type(res) ~= 'table' or res.success or res.success == nil
			if success then
				minetest.chat_send_player(name, S('Node %s ownership changed to %s', node.name, name))
			else
				minetest.chat_send_player(name, S('Failed %s ownership change to %s', node.name, name))
			end
			-- Return nil to keep tool without metadata
			return nil, nil, nil
		end
	end,
	on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos)
		local definition = tooldef.nodes[node.name]
		if definition then
			local res = definition.paste(node, pos, player)
			local name = player:get_player_name()
			local sname = tooldef.settings.shared_account
			local success = type(res) ~= 'table' or res.success or res.success == nil
			if success then
				minetest.chat_send_player(name, S('Node %s ownership changed to %s', node.name, sname))
			else
				minetest.chat_send_player(name, S('Failed %s ownership change to %s', node.name, sname))
			end
			-- Return nil to keep tool without metadata
			return nil, nil, nil
		end
	end,
})

-- Create namespace containing sharetool runtime data and functions
tool:ns({
	shared_account = metatool.settings('sharetool', 'shared_account'),
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
		if not travelnet.targets[owner] then
			travelnet.targets[owner] = {}
		end
		if not travelnet.targets[owner][network] then
			travelnet.targets[owner][network] = {}
		end
		if #travelnet.targets[owner][network] >= travelnet.MAX_STATIONS_PER_NETWORK then
			minetest.chat_send_player(name, S('Too many travelnets attached to network %s owned by %s.', network, owner))
			return false
		end
		for stname,stdata in pairs(travelnet.targets[owner][network]) do
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
		if travelnet.targets[current_owner] and travelnet.targets[current_owner][network] then
			travelnet.targets[current_owner][network][station] = nil
        end
		-- Update owner
		meta:set_string('owner', owner)
		-- Attach to network
		travelnet.targets[owner][network][station] = {pos=pos, timestamp=os.time()}
		-- Update formspec to reflect changes
		travelnet.update_formspec(pos, owner, nil)
		-- Mark node as shared
		self.mark_shared(meta)
		-- Save travelnet database
		travelnet.save_data()
		return true
	end
})

-- nodes
tool:load_node_definition(dofile(modpath .. '/nodes/book.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/travelnet.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/missions.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/mapserver.lua'))
