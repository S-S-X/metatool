--
-- Register vacuum tube for tubetool
--

TODO: Register injectors for tubetool

-- sand tubes
for i=1,8 do
	tubetool:register_node("pipeworks:sand_tube_" .. i, tooldef)
end
