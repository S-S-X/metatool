--
-- Register lua tube for Magic pen
--

local o2b_lookup = {
	['0'] = '000',
	['1'] = '001',
	['2'] = '010',
	['3'] = '011',
	['4'] = '100',
	['5'] = '101',
	['6'] = '110',
	['7'] = '111',
}
local o2b = function(o)
	return o:gsub('.', o2b_lookup)
end
local d2b = function(d)
	return o2b(string.format('%o', d))
end
local lpad = function(s, c, n)
	return c:rep(n - #s) .. s
end

local nodenameprefix = "pipeworks:lua_tube"

-- lua tubes, 64 different nodes
local nodes = {}
for i=0,63 do
	table.insert(nodes, nodenameprefix .. lpad(d2b(i), '0', 6))
end
table.insert(nodes, nodenameprefix .. '_burnt')

--luacheck: ignore unused argument node player
return {
	name = 'luatube',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			return {
				description = string.format("Lua tube at %s", minetest.pos_to_string(pos)),
				content = meta:get_string("code"),
			}
		end,
	}
}
