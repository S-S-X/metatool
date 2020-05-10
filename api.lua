--
-- Global namespace tubetool contains core functions and stored data
--

tubetool = {
	nodes = {},
	register_node = function(self, name, definition, override)
		if override or not self.nodes[name] then
			if type(definition) ~= 'table' then
				print(string.format('tubetool:register_node invalid definition, must be table but was %s', type(definition)))
			elseif not definition.group then
				print('tubetool:register_node invalid definition, group must be defined')
			elseif not minetest.registered_nodes[name] then
				print(string.format('tubetool:register_node node %s not registered for minetest, skipping registration.', name))
			elseif type(definition.copy) == 'function' and type(definition.paste) == 'function' then
				self.nodes[name] = definition
				print(string.format('tubetool:register_node registered %s for group %s', name, definition.group))
			else
				print('tubetool:register_node invalid definition, copy or paste function not defined')
			end
		else
			print(string.format('tubetool:register_node not registering %s because it is already registered.', name))
		end
	end,

	get_node = function(self, player, pointed_thing)
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

		local definition = self.nodes[node.name]
		if not definition then
			-- node is not registered for tubetool
			return
		end

		return node, pos
	end,

	copy = function(self, node, pos, player)
		local definition = self.nodes[node.name]
		if definition then
			minetest.chat_send_player(player:get_player_name(), string.format('copying data for group %s', definition.group))
			return definition.copy(node, pos, player), definition.group
		end
	end,

	paste = function(self, node, pos, player, data, group)
		local definition = self.nodes[node.name]
		if definition.group ~= group then
			minetest.chat_send_player(
				player:get_player_name(),
				string.format('tubetool wand contains data for %s, cannot apply for %s', group, definition.group)
			)
			return
		end
		if definition and data then
			minetest.chat_send_player(player:get_player_name(), string.format('applying data for group %s', definition.group))
			return definition.paste(node, pos, player, data)
		end
	end,

}
