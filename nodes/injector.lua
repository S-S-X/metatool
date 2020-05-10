--
-- Register injectors for tubetool
--

-- TODO: Register injectors for tubetool

--luacheck: ignore unused argument node player
local tooldef = {
	group = 'injector',

	copy = function(node, pos, player)
		-- return data required for replicating this tube settings
		return { description = 'Not implemented' }
	end,

	paste = function(node, pos, player, data)
	end,
}

tubetool:register_node('pipeworks:injector', tooldef)
