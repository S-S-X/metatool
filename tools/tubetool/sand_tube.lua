--
-- Register vacuum tube for tubetool
--

-- TODO: Register vacuum tubes for tubetool

--luacheck: ignore unused argument node player
local tooldef = {
	group = 'vacuum tube',

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

-- sand tubes
for i=1,8 do
	metatool:register_node("pipeworks:sand_tube_" .. i, tooldef)
end
