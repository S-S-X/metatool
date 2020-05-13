--
-- Register injectors for tubetool
--

-- TODO: Register injectors for tubetool

--luacheck: ignore unused argument node player
local tooldef = {
	group = 'injector',

	copy = function(node, pos, player)
		-- useless stuff to remove luacheck warnings
		print(type(pos))
		-- return data required for replicating this tube settings
		return { description = 'Not implemented' }
	end,

	paste = function(node, pos, player, data)
		-- useless stuff to remove luacheck warnings
		print(type(pos))
		print(type(data))
	end,
}

tubetool:register_node('pipeworks:injector', tooldef)
