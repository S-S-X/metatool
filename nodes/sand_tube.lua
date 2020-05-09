--
-- Register vacuum tube for tubetool
--

-- TODO: Register vacuum tubes for tubetool

--luacheck: ignore unused argument node player
local tooldef = {
	copy = function(node, pos, player)
		-- return data required for replicating this tube settings
		return { description = 'Not implemented' }
	end,

	paste = function(node, pos, player, data)
	end,
}

-- sand tubes
for i=1,8 do
	tubetool:register_node("pipeworks:sand_tube_" .. i, tooldef)
end
