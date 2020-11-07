--
-- Global namespace metatool contains core functions and stored data
--

local S = metatool.S

-- Metatool registered tools
metatool.tools = {}

-- Metatool privileged tools
metatool.privileged_tools = {}

local transform_tool_name = function(name, mtprefix)
	local parts = name:gsub('\\s',''):split(':')
	if #parts > 2 or #parts < 1 then
		print(S('Invalid metatool name %s', name))
		return
	elseif #parts == 2 then
		-- this will strip leading colon
		return parts[1] .. ':' .. parts[2]
	elseif #parts == 1 and parts[1] ~= 'metatool' then
		return (mtprefix and ':' or '') .. 'metatool:' .. parts[1]
	else
		print(S('Invalid metatool name %s', name))
		return
	end
end

local register_privileged_tool = function(toolname, definition)
	print(S("Registering %s as privileged tool", toolname))
	metatool.privileged_tools[toolname] = definition
end

local remove_uncraftable_tool = function(player, tooldef)
	if not tooldef.recipe then
		-- take away tools that have no recipe
		local inv = player:get_inventory()
		local lists = inv:get_lists()
		local ref = ItemStack(tooldef.itemname)
		local rm = ItemStack(string.format('%s %d', tooldef.itemname, 99))
		for list,_ in pairs(lists) do
			-- look for at least single tool
			while inv:contains_item(list, ref, false) do
				-- take away 99 stacks at once
				inv:remove_item(list, rm)
			end
		end
		minetest.chat_send_player(
			player:get_player_name(),
			S('Privileged tools removed from inventory: %s', tooldef.itemname)
		)
		-- If calling through on_use empty itemstack must be returned
		return ItemStack()
	end
end

local register_metatool_item = function(itemname, definition)

	if not itemname then return end

	local description = definition.description or "Weird surprise MetaTool, let's roll the dice..."
	local texture = definition.texture or 'metatool_wand.png'
	local craft_count = definition.craft_count or 1
	local stack_max = definition.stack_max or 99
	local groups
	if not definition.recipe then
		groups = { not_in_creative_inventory = 1 }
	end

	craft_count = craft_count > stack_max and stack_max or craft_count

	minetest.register_craftitem(itemname, {
		description = description,
		inventory_image = texture,
		groups = groups,
		stack_max = stack_max,
		wield_image = texture,
		wield_scale = { x = 0.8, y = 1, z = 0.8 },
		liquids_pointable = definition.liquids_pointable,
		on_use = function(...)
			return metatool:on_use(definition.itemname, unpack({...}))
		end,
	})

	if definition.privs then
		register_privileged_tool(definition.itemname, definition)
		if not definition.recipe then
			metatool.chat.register_command_give()
		end
	end

	minetest.register_craft({
		type = "shapeless",
		output = string.format('%s %d', definition.itemname, 1),
		recipe = { definition.itemname }
	})

	if definition.recipe then
		minetest.register_craft({
			output = string.format('%s %d', definition.itemname, craft_count),
			recipe = definition.recipe
		})
	end

	return definition.itemname
end

local separate_stack = function(itemstack)
	if itemstack:get_count() > 1 then
		local toolname = itemstack:get_name()
		local separated = ItemStack(toolname)
		separated:set_count(1)
		itemstack:take_item(1)
		return itemstack, separated
	end
	return itemstack, false
end

local return_itemstack = function(player, itemstack, separated)
	if separated then
		-- stack was separated, try to recombine
		local meta1 = itemstack:get_meta()
		local meta2 = separated:get_meta()
		if meta1:equals(meta2) then
			-- stacks can be recombinined, do it
			itemstack:set_count(itemstack:get_count() + 1)
		else
			-- stacks cannot be recombined, give or drop new stack
			local inv = player:get_inventory()
			if inv:room_for_item("main", separated) then
				-- item fits to inventory
				inv:add_item("main", separated)
			else
				-- item will not fit to inventory
				minetest.item_drop(separated, player, player:get_pos())
			end
		end
	end
end

local validate_tool_definition = function(tooldef)
	local function F(key)
		local res = type(tooldef[key]) == 'function'
		if not res then print(string.format('%s missing function %s', tooldef.itemname, key)) end
		return res
	end
	return tooldef and F('on_read_node') and F('on_write_node')
end

--luacheck: ignore unused argument self

metatool.tool = function(toolname)
	local name = transform_tool_name(toolname)
	if name and metatool.tools[name] then
		return metatool.tools[name]
	end
end

-- Create or retrieve tool namespace, sorry.. might seem bit hacky
metatool.ns = function(self, data)
	if type(self) == 'string' then
		-- metatool.ns('mytool') / retrieve namespace
		local tool = metatool.tool(self)
		if tool then
			return tool.namespace
		end
		print(S('Invalid or nonexistent namespace requested: %s', self))
		return
	elseif type(self) == 'table' and self.name then
		-- mytool:ns({mydata}) / create namespace
		print(S('Namespace created for: %s', self.name))
		self.namespace = data
		return
	end
	print('metatool.ns called with invalid arguments')
end

metatool.check_privs = function(player, privs)
	local success,_ = minetest.check_player_privs(player, privs)
	return success
end

metatool.is_protected = function(pos, player, privs, no_violation_record)
	if privs and (metatool.check_privs(player, privs)) then
		-- player is allowed to bypass protection checks
		return false
	end
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		if not no_violation_record then
			-- node is protected record violation
			minetest.record_protection_violation(pos, name)
		end
		return true
	end
	return false
end

metatool.before_info = function(nodedef, pos, player, no_violation_record)
	if metatool.is_protected(pos, player, nodedef.protection_bypass_info, no_violation_record) then
		return false
	end
	return true
end

metatool.before_read = function(nodedef, pos, player, no_violation_record)
	if metatool.is_protected(pos, player, nodedef.protection_bypass_read, no_violation_record) then
		return false
	end
	return true
end

metatool.before_write = function(nodedef, pos, player, no_violation_record)
	if metatool.is_protected(pos, player, nodedef.protection_bypass_write, no_violation_record) then
		return false
	end
	return true
end

-- Called when registered tool is used
metatool.on_use = function(self, toolname, itemstack, player, pointed_thing)

	local tool = self.tools[toolname]
	if not player or not tool then return end

	if type(player) ~= 'userdata' then
		-- if tool has machine_use_priv and player has it allow using tool even if player is not userdata (fake player)
		local machine_use_priv = tool.settings.machine_use_priv
		if not machine_use_priv or not metatool.check_privs(player, machine_use_priv) then
			return
		end
	end

	if self.privileged_tools[toolname] then
		if not metatool.check_privs(player, tool.privs) then
			minetest.chat_send_player(player:get_player_name(), 'You are not allowed to use this tool.')
			return remove_uncraftable_tool(player, tool)
		end
	end

	local node, pos, nodedef = metatool:get_node(tool, player, pointed_thing)
	if not node then
		return
	end

	local controls = player:get_player_control()

	if controls.aux1 or controls.sneak then
		local use_info = controls.sneak and (tool.on_read_info or nodedef.info)
		if use_info and nodedef.before_info(nodedef, pos, player) then
			-- Execute on_read_node when tool is used on node and sneak is held
			if tool.on_read_info then
				-- Tool info method defined, call through it and let it handle nodes
				tool.on_read_info(tool, player, pointed_thing, node, pos, nodedef, itemstack)
			else
				-- Only node definition had info method available, use it directly
				nodedef.info(node, pos, player, itemstack)
			end
		elseif not use_info and nodedef.before_read(nodedef, pos, player) then
			-- Execute on_read_node when tool is used on node and special or sneak is held
			local data, group, description = tool.on_read_node(tool, player, pointed_thing, node, pos, nodedef)
			local separated
			itemstack, separated = separate_stack(itemstack)
			metatool.write_data(separated or itemstack, {data=data,group=group}, description)
			-- if stack was separated give missing items to player
			return_itemstack(player, itemstack, separated)
		end
	else
		if nodedef.before_write(nodedef, pos, player) then
			local data = metatool.read_data(itemstack)
			if tool.allow_use_empty or type(data) == 'table' then
				-- Execute on_write_node when tool is used on node and tool contains data
				local tooldata
				local group
				if type(data) == 'table' then
					tooldata = data.data
					group = data.group
				end
				tool.on_write_node(tool, tooldata, group, player, pointed_thing, node, pos, nodedef)
			else
				minetest.chat_send_player(
					player:get_player_name(),
					'no data stored in this wand, sneak+use or special+use to record data.'
				)
			end
		end
	end

	return itemstack
end

-- Common node loading method for tools
metatool.load_node_definition = function(self, def)
	if self == metatool then
		-- Could go full OOP and actually check for tool object.. sorry about that
		print('metatool:load_node invalid method call, requires tool context')
		return
	end
	if not def or type(def) ~= 'table' then
		print(string.format(
			'metatool:%s error in %s:load_node_definition invalid definition type: %s',
			self.name, self.name, type(def)
		))
		return
	end
	if type(def.tooldef) ~= 'table' then
		print(string.format(
			'metatool:%s error in %s:load_node_definition invalid `tooldef` type: %s',
			self.name, self.name, type(def.tooldef)
		))
		return
	end
	local nodedef_name
	if type(def.nodes) == 'table' and #def.nodes > 0 then
		nodedef_name = def.nodes[1]
		for _,nodename in ipairs(def.nodes) do
			metatool:register_node(self.name, nodename, def.tooldef)
		end
	elseif type(def.nodes) == 'string' then
		nodedef_name = def.nodes
		metatool:register_node(self.name, def.nodes, def.tooldef)
	else
		print(string.format(
			'metatool:%s error in %s:load_node_definition invalid `nodes` type: %s',
			self.name, self.name, type(def.nodes)
		))
		return
	end
	metatool.merge_node_settings(self.name, def.name or nodedef_name, def.tooldef)
end

metatool.register_tool = function(self, name, definition)
	local itemname = transform_tool_name(name, true)
	local itemname_clean = itemname:gsub('^:', '')
	if not self.tools[itemname_clean] then
		if type(definition) ~= 'table' then
			print(S('metatool:register_tool invalid definition, must be table but was %s', type(definition)))
			return
		end
		definition.itemname = itemname_clean
		if validate_tool_definition(definition) then
			metatool.merge_tool_settings(itemname_clean, definition)
			if not register_metatool_item(itemname, definition) then
				print(S('metatool:register_tool tool registration failed for "%s".', name))
				return
			end
			-- TODO: Keep just 2 of these: name, itemname and nice_name.
			-- Maybe remove nice_name, use name for fancy definition.name and itemname for itemname_clean.
			-- TODO: Keep everything given in original definition and then just override all keys used by API.
			self.tools[itemname_clean] = {
				name = itemname_clean,
				itemname = itemname_clean,
				nice_name = definition.name or name,
				description = definition.description,
				allow_use_empty = definition.allow_use_empty,
				privs = definition.privs,
				settings = definition.settings,
				recipe = definition.recipe,
				ns = metatool.ns,
				load_node_definition = metatool.load_node_definition,
				nodes = {},
				copy = metatool.copy,
				paste = metatool.paste,
				on_read_node = definition.on_read_node,
				on_write_node = definition.on_write_node,
			}
			print(S('metatool:register_tool registered tool "%s".', itemname_clean))
			return self.tools[itemname_clean]
		else
			print('metatool:register_tool invalid tool definition, missing required values.')
		end
	else
		print(S('metatool:register_tool not registering tool %s because it is already registered.', name))
	end
end

metatool.register_node = function(self, toolname, name, definition, override)
	local tooldef = self.tools[toolname]
	if override or not tooldef.nodes[name] then
		if type(definition) ~= 'table' then
			print(S('metatool:register_node invalid definition, must be table but was %s', type(definition)))
		elseif not definition.group then
			print('metatool:register_node invalid definition, group must be defined.')
		elseif name ~= '*' and not minetest.registered_nodes[name] then
			print(S('metatool:register_node node %s not registered for minetest, skipping registration.', name))
		elseif type(definition.copy) == 'function' or type(definition.paste) == 'function' then
			if type(definition.before_info) ~= 'function' then
				definition.before_info = metatool.before_info
			end
			if type(definition.before_read) ~= 'function' then
				definition.before_read = metatool.before_read
			end
			if type(definition.before_write) ~= 'function' then
				definition.before_write = metatool.before_write
			end
			tooldef.nodes[name] = definition
			print(S('metatool:register_node registered %s for tool %s with group %s.', name, toolname, definition.group))
		else
			print(S('metatool:register_node invalid definition for %s: copy or paste function not defined.', name))
		end
	else
		print(S('metatool:register_node not registering node %s because it is already registered.', name))
	end
end

metatool.get_node = function(self, tool, player, pointed_thing)
	if not player or not pointed_thing then
		-- not valid player or pointed_thing
		return
	end

	local name = player:get_player_name()
	if not name or name == '' then
		-- could not get real player name
		return
	end

	local pos = minetest.get_pointed_thing_position(pointed_thing)
	if not pos then
		-- could not get definite position
		minetest.chat_send_player(name, S('%s could not get valid position', tool.nice_name))
		return
	end

	local node = minetest.get_node_or_nil(pos)
	if not node then
		-- could not get valid node
		return
	end

	local definition = tool.nodes[node.name] or tool.nodes['*']
	if not definition then
		-- node is not registered for metatool
		minetest.chat_send_player(name, S('%s cannot be used on %s', tool.nice_name, node.name))
		return
	end

	return node, pos, definition
end

-- Save data for tool and update tool description
metatool.write_data = function(itemstack, data, description)
	if not itemstack then
		return
	end

	local meta = itemstack:get_meta()
	if data.data or data.group then
		local datastring = minetest.serialize(data)
		meta:set_string('data', datastring)
	end
	if description then
		meta:set_string('description', description)
	end
end

-- Return data stored with tool
metatool.read_data = function(itemstack)
	if not itemstack then
		return
	end

	local meta = itemstack:get_meta()
	local datastring = meta:get_string('data')
	return minetest.deserialize(datastring)
end

-- TODO: Remove metatool.info, metatool.copy and metatool.paste and
-- update tools to call these directly using nodedef event
-- handler argument provided through metatool.on_use.
metatool.info = function(self, node, pos, player)
	local definition = self.nodes[node.name] or self.nodes['*']
	if definition then
		definition.info(node, pos, player)
	end
end

metatool.copy = function(self, node, pos, player)
	local definition = self.nodes[node.name] or self.nodes['*']
	if definition and type(definition.copy) == "function" then
		minetest.chat_send_player(player:get_player_name(), S('copying data for group %s', definition.group))
		return definition.copy(node, pos, player), definition.group
	end
end

metatool.paste = function(self, node, pos, player, data, group)
	local definition = self.nodes[node.name] or self.nodes['*']
	if data and definition and definition.group == group and type(definition.paste) == "function" then
		return definition.paste(node, pos, player, data)
	else
		minetest.chat_send_player(
			player:get_player_name(),
			S('metatool wand contains data for %s, cannot apply for %s', group, definition.group)
		)
	end
end
