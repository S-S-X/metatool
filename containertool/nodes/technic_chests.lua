--
-- Register technic chests for Container tool
--

local nodes = {}

for nodename, nodedef in pairs(minetest.registered_nodes) do
	if nodedef.groups and nodedef.groups.technic_chest then
		-- Match found, add to registration list
		table.insert(nodes, nodename)
	end
end

-- Meta getters / setters considering nil values
local function get_int(meta, key) local value = meta:get(key) return value and tonumber(value) end
local function set_int(meta, key, value) if value then meta:set_int(key, value) end end
local function set_string(meta, key, value) if value then meta:set_string(key, value) end end

return {
	name = 'technic_chest',
	nodes = nodes,
	tooldef = {
		group = 'container',
		protection_bypass_read = "interact",
		before_write = function(nodedef, pos, player)
			-- FIXME: Supply missing protected/locked arguments or reimplement protection checking here
			return technic.chests.change_allowed(pos, player)
		end,
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local owner = meta:get("owner")
			-- Allow reading key_lock_secret only by chest owner
			local key_lock_secret = owner == player:get_player_name() and meta:get("key_lock_secret")
			local infotext = meta:get("infotext")
			local nicename = infotext or minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				-- Information/interface
				color = get_int(meta, "color"),
				sort_mode = get_int(meta, "sort_mode"),
				autosort = get_int(meta, "autosort"),
				-- Security
				owner = owner,
				key_lock_secret = key_lock_secret,
				-- Pipeworks
				splitstacks = get_int(meta, "splitstacks"),
				-- Digilines
				channel = meta:get("channel"),
				put = get_int(meta, "send_put"),
				take = get_int(meta, "send_take"),
				inject = get_int(meta, "send_inject"),
				pull = get_int(meta, "send_pull"),
				overflow = get_int(meta, "send_overflow"),
			}
		end,
		paste = function(node, pos, player, data)
			local meta = minetest.get_meta(pos)
			-- Information/interface
			set_int(meta, "color", data.color)
			set_int(meta, "sort_mode", data.sort_mode)
			set_int(meta, "autosort", data.autosort)
			-- Security
			set_string(meta, "key_lock_secret", data.secret)
			-- Pipeworks
			set_int(meta, "splitstacks", data.splitstacks)
			-- Digilines
			--set_string(meta, "channel", data.channel)
			set_int(meta, "send_put", data.put)
			set_int(meta, "send_take", data.take)
			set_int(meta, "send_inject", data.inject)
			set_int(meta, "send_pull", data.pull)
			set_int(meta, "send_overflow", data.overflow)
		end,
	}
}
