--
-- Global namespace metatool contains core functions and stored data
--

local S = string.format

local transform_tool_name = function(name)
	local parts = name:gsub('\\s',''):split(':')
	if #parts > 2 or #parts < 1 then
		print(S('Invalid metatool name %s', name))
		return
	elseif #parts == 2 then
		-- this will strip leading colon
		return parts[1] .. parts[2]
	elseif #parts == 1 and parts[1] ~= 'metatool' then
		return ':metatool:' .. parts[1]
	else
		print(S('Invalid metatool name %s', name))
		return
	end
end

local register_metatool_item = function(name, definition)

	local itemname = transform_tool_name(name)
	if not itemname then return end
	local itemname_clean = itemname:gsub('^:', '')

	local description = definition.description or "Weird surprise MetaTool, let's roll the dice..."
	local texture = definition.texture or 'metatool_wand.png'
	local liquids_pointable = definition.liquids_pointable == nil and false or definition.liquids_pointable
	local craft_count = definition.craft_count or 1
	local stack_max = definition.stack_max or 99
	craft_count = craft_count > stack_max and stack_max or craft_count

	minetest.register_craftitem(itemname, {
		description = description,
		inventory_image = texture,
		groups = {},
		stack_max = stack_max,
		wield_image = texture,
		wield_scale = { x = 0.8, y = 1, z = 0.8 },
		liquids_pointable = liquids_pointable,
		on_use = function(...)
			return metatool:on_use(itemname_clean, unpack({...}))
		end,
	})

	minetest.register_craft({
		output = string.format('%s %d', itemname_clean, craft_count),
		recipe = definition.recipe
	})

	minetest.register_craft({
		type = "shapeless",
		output = string.format('%s %d', itemname_clean, 1),
		recipe = { itemname_clean }
	})

	return itemname_clean
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

local validate_tool_definition = function(definition)
	local function F(key)
		local res = type(definition[key]) == 'function'
		if not res then print(string.format('missing function %s', key)) end
		return res
	end
	local function T(key)
		local res = type(definition[key]) == 'table'
		if not res then print(string.format('missing function %s', key)) end
		return res
	end
	return F('on_read_node') and F('on_write_node') and T('recipe')
end

--luacheck: ignore unused argument self
metatool = {
	-- Metatool registered tools
	tools = {},

	-- Called when registered tool is used
	on_use = function(self, toolname, itemstack, player, pointed_thing)
		if not player or type(player) == 'table' then
			return
		end

		local tooldef = self.tools[toolname]

		local node, pos = metatool:get_node(tooldef, player, pointed_thing)
		if not node then
			return
		end

		local controls = player:get_player_control()
		if controls.aux1 or controls.sneak then
			-- Execute on_read_node when tool is used on node and special or sneak is held
			local data, group, description = tooldef.itemdef.on_read_node(tooldef, player, pointed_thing, node, pos)
			local separated
			itemstack, separated = separate_stack(itemstack)
			metatool.write_data(separated or itemstack, {data=data,group=group}, description)
			-- if stack was separated give missing items to player
			return_itemstack(player, itemstack, separated)
		else
			local data = metatool.read_data(itemstack)
			if type(data) == 'table' then
				-- Execute on_write_node when tool is used on node and tool contains data
				tooldef.itemdef.on_write_node(tooldef, data.data, data.group, player, pointed_thing, node, pos)
			else
				minetest.chat_send_player(
					player:get_player_name(),
					'no data stored in this wand, sneak+use or special+use to record data.'
				)
			end
		end

		return itemstack
	end,

	-- Common node loading method for tools
	load_node_definition = function(self, def)
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
		if type(def.nodes) == 'table' then
			for _,nodename in ipairs(def.nodes) do
				metatool:register_node(self.name, nodename, def.tooldef)
			end
		elseif type(def.nodes) == 'string' then
			metatool:register_node(self.name, def.nodes, def.tooldef)
		else
			print(string.format(
				'metatool:%s error in %s:load_node_definition invalid `nodes` type: %s',
				self.name, self.name, type(def.nodes)
			))
			return
		end
	end,

	register_tool = function(self, name, definition)
		if not self.tools[name] then
			if type(definition) ~= 'table' then
				print(S('metatool:register_tool invalid definition, must be table but was %s', type(definition)))
			elseif validate_tool_definition(definition) then
				local itemname = register_metatool_item(name, definition)
				if not itemname then
					print(S('metatool:register_tool tool registration failed for "%s".', name))
				end
				self.tools[itemname] = {
					itemdef = definition,
					name = itemname,
					nice_name = definition.name or name,
					nodes = {},
					load_node_definition = metatool.load_node_definition,
					copy = metatool.copy,
					paste = metatool.paste,
				}
				print(S('metatool:register_tool registered tool "%s".', itemname))
				return self.tools[itemname]
			else
				print('metatool:register_tool invalid tool definition, missing required values.')
			end
		else
			print(S('metatool:register_tool not registering tool %s because it is already registered.', name))
		end
	end,

	register_node = function(self, tool, name, definition, override)
		local tooldef = self.tools[tool]
		if override or not tooldef.nodes[name] then
			if type(definition) ~= 'table' then
				print(S('metatool:register_node invalid definition, must be table but was %s', type(definition)))
			elseif not definition.group then
				print('metatool:register_node invalid definition, group must be defined.')
			elseif not minetest.registered_nodes[name] then
				print(S('metatool:register_node node %s not registered for minetest, skipping registration.', name))
			elseif type(definition.copy) == 'function' and type(definition.paste) == 'function' then
				tooldef.nodes[name] = definition
				print(S('metatool:register_node registered %s for tool %s with group %s.', name, tool, definition.group))
			else
				print(S('metatool:register_node invalid definition for %s: copy or paste function not defined.', name))
			end
		else
			print(S('metatool:register_node not registering node %s because it is already registered.', name))
		end
	end,

	get_node = function(self, tool, player, pointed_thing)
		if not player or type(player) == 'table' or not pointed_thing then
			-- not valid player or fake player, fake player is not supported (yet)
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

		if minetest.is_protected(pos, name) then
			-- node is protected
			minetest.record_protection_violation(pos, name)
			return
		end

		local definition = tool.nodes[node.name]
		if not definition then
			-- node is not registered for metatool
			minetest.chat_send_player(name, S('%s cannot be used on %s', tool.nice_name, node.name))
			return
		end

		return node, pos
	end,

	-- Save data for tool and update tool description
	write_data = function(itemstack, data, description)
		if not itemstack then
			return
		end

		local meta = itemstack:get_meta()
		local datastring = minetest.serialize(data)
		description = string.format('%s (%s)', (description or 'No description'), data.group)
		meta:set_string('data', datastring)
		meta:set_string('description', description)
	end,

	-- Return data stored with tool
	read_data = function(itemstack)
		if not itemstack then
			return
		end

		local meta = itemstack:get_meta()
		local datastring = meta:get_string('data')
		return minetest.deserialize(datastring)
	end,

	copy = function(self, node, pos, player)
		local definition = self.nodes[node.name]
		if definition then
			minetest.chat_send_player(player:get_player_name(), S('copying data for group %s', definition.group))
			return definition.copy(node, pos, player), definition.group
		end
	end,

	paste = function(self, node, pos, player, data, group)
		local definition = self.nodes[node.name]
		if definition.group ~= group then
			minetest.chat_send_player(
				player:get_player_name(),
				S('metatool wand contains data for %s, cannot apply for %s', group, definition.group)
			)
			return
		end
		if definition and data then
			return definition.paste(node, pos, player, data)
		end
	end,

}
