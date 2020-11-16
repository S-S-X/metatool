--
-- Register technic chests for Container tool
--

-- Collect nodes and on_receive_fields callback functions (no API available)
local nodes = {}
local on_receive_fields = {}
for nodename, nodedef in pairs(minetest.registered_nodes) do
	if nodedef.groups and nodedef.groups.technic_chest then
		-- Match found, add to registration list
		table.insert(nodes, nodename)
		on_receive_fields[nodename] = nodedef.on_receive_fields
	end
end

-- Collect lookup data for colored variants (no API available)
local colornode2basenode = {}
local basenode2colornode = {}
for _, nodename in ipairs(nodes) do
	for i,colordef in ipairs(technic.chests.colors) do
		local color_nodename = nodename .. "_" .. colordef[1]
		local nodedef = minetest.registered_nodes[color_nodename]
		if nodedef and nodedef.groups and nodedef.groups.technic_chest then
			colornode2basenode[color_nodename] = nodename
			if not basenode2colornode[nodename] then basenode2colornode[nodename] = {} end
			-- This can leave holes depending on what colors chest actually uses, always use `pairs` to iterate
			basenode2colornode[nodename][i] = color_nodename
		end
	end
end

-- Meta getters / setters considering nil values
local function get_int(meta, key) local value = meta:get(key) return value and tonumber(value) end
local function set_int(meta, key, value) if value then meta:set_int(key, value) end end
local function set_string(meta, key, value) if value then meta:set_string(key, value) end end

local function set_color(meta, node, pos, color)
	if color then
		local is_color = not not technic.chests.colors[color]
		local newname
		if is_color then
			-- Set color
			newname = basenode2colornode[node.name] and basenode2colornode[node.name][color]
			if not newname then
				local basenode = colornode2basenode[node.name]
				newname = basenode2colornode[basenode] and basenode2colornode[basenode][color]
			end
		else
			-- Remove color
			newname = colornode2basenode[node.name]
		end
		if newname and newname ~= node.name then
			node.name = newname
			minetest.swap_node(pos, node)
			set_string(meta, "color", is_color and color or "")
		end
	end
end

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
			local has_color = not not (basenode2colornode[node.name] or colornode2basenode[node.name])
			-- Allow reading key_lock_secret only by chest owner
			local owner = meta:get("owner")
			local key_lock_secret = owner == player:get_player_name() and meta:get("key_lock_secret")
			local infotext = meta:get("infotext")
			local nicename = infotext or minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				-- Information/interface
				color = get_int(meta, "color") or has_color,
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
			set_color(meta, node, pos, data.color)
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
			on_receive_fields[node.name](pos, nil, {sort = 1}, player)
		end,
	}
}
