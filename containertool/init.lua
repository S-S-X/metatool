--
-- metatool:containertool is in game tool that allows cloning container configuration
--

local tool = metatool:register_tool('containertool', {
	description = 'Container tool',
	name = 'Container tool',
	texture = 'containertool.png',
	recipe = {
		{ '', '', 'default:mese_crystal' },
		{ '', 'default:chest', '' },
		{ 'default:skeleton_key', '', '' }
	},
	settings = {
		copy_key_lock_secret = true,
		copy_digiline_channel = false,
	},
})

local function has_digiline(name)
	local nodedef = minetest.registered_nodes[name]
	return nodedef and nodedef.digiline and nodedef.digiline.receptor
end

local function has_key_lock(name)
	local nodedef = minetest.registered_nodes[name]
	return nodedef and type(nodedef.on_skeleton_key_use) == "function"
end

local function is_tubedevice(name, pos)
	local nodedef = minetest.registered_nodes[name]
	if nodedef and nodedef.groups and nodedef.groups.tubedevice_receiver then
		if nodedef.tube and (not pos or nodedef.tube.input_inventory) then
			return true
		elseif pos then
			local formspec = minetest.get_meta(pos):get("formspec")
			return formspec and formspec:find("fs_helpers_cycling:%d+:splitstacks")
		end
	end
end

local function description(meta, node, pos)
	local nicename = meta:get("infotext") or minetest.registered_nodes[node.name].description or node.name
	return ("%s at %s"):format(nicename, minetest.pos_to_string(pos))
end

local function get_digiline_channel(meta, node)
	if tool.settings.copy_digiline_channel and has_digiline(node.name) then
		return meta:get_string("channel")
	end
end

local function get_key_lock_secret(meta, player, owner)
	if tool.settings.copy_key_lock_secret and player:get_player_name() == owner then
		return meta:get("key_lock_secret")
	end
end

local function get_splitstacks(meta, node, pos)
	return is_tubedevice(node.name, pos) and meta:get_int("splitstacks")
end

tool:ns({
	description = description,
	is_tubedevice = is_tubedevice,
	has_digiline = has_digiline,
	get_digiline_channel = get_digiline_channel,
	get_common_attributes = function(meta, node, pos, player)
		local owner = meta:get("owner")
		return {
			description = description(meta, node, pos),
			owner = owner,
			key_lock_secret = get_key_lock_secret(meta, player, owner),
			channel = get_digiline_channel(meta, node),
			splitstacks = get_splitstacks(meta, node),
		}
	end,
	set_digiline_meta = function(meta, data, node)
		if has_digiline(node.name) then
			for key, value in pairs(data) do
				if key ~= "channel" or tool.settings.copy_digiline_channel then
					if type(value) == "string" then
						meta:set_string(key, value)
					elseif type(value) == "number" then
						meta:set_int(key, value)
					end
				end
			end
		end
	end,
	set_key_lock_secret = function(meta, data, node)
		if tool.settings.copy_key_lock_secret and data.key_lock_secret and has_key_lock(node.name) then
			meta:set_string("key_lock_secret", data.key_lock_secret)
		end
	end,
	set_splitstacks = function(meta, data, node, pos)
		if type(data.splitstacks) == "number" and is_tubedevice(node.name, pos) then
			meta:set_int("splitstacks", data.splitstacks)
		end
	end,
	get_int = function(meta, key)
		local value = meta:get(key)
		return value and tonumber(value)
	end,
	set_int = function(meta, key, value)
		if value then meta:set_int(key, value) end
	end,
	set_string = function (meta, key, value)
		if value then meta:set_string(key, value) end
	end,
})

-- nodes
local modpath = minetest.get_modpath('containertool')
tool:load_node_definition(dofile(modpath .. '/nodes/technic_chests.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/technic_injector.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/more_chests_shared.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/digilines_chest.lua'))

-- Register after everything else, default behavior for nodes that seems to be compatible
minetest.register_on_mods_loaded(function()
	tool:load_node_definition(dofile(modpath .. '/nodes/common_defaults.lua'))
end)
