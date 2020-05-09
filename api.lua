--
-- Global namespace tubetool contains core functions and stored data
--

tubetool = {
	nodes = {},
	register_node = function(self, name, definition, override)
		if override or not self.nodes[name] then
			if type(definition.copy) == 'function' and type(definition.paste) == 'function' then
				self.nodes[name] = definition
				print(string.format('tubetool:register_node registered %s', name))
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
			return definition.copy(node, pos, player)
		end
	end,

	paste = function(self, node, pos, player, data)
		local definition = self.nodes[node.name]
		if definition and data then
			return definition.paste(node, pos, player, data)
		end
	end,

}
