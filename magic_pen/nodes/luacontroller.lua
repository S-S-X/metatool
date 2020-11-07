--
-- Register lua controller and lua tube for Magic pen
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
local lpadcut = function(s, c, n)
	return lpad(s,c,n):sub(math.max(0, #s - n + 1), #s + 1)
end

local nodes = {}

-- lua controller, 16 different nodes
for i=0,15 do
	table.insert(nodes, "mesecons_luacontroller:luacontroller" .. lpadcut(d2b(i), '0', 4))
end
table.insert(nodes, "mesecons_luacontroller:luacontroller_burnt")

-- lua tubes, 64 different nodes
for i=0,63 do
	table.insert(nodes, "pipeworks:lua_tube" .. lpad(d2b(i), '0', 6))
end
table.insert(nodes, "pipeworks:lua_tube_burnt")

return {
	name = 'luacontroller',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = meta:get_string("code"),
			}
		end,
		paste = function(node, pos, player, data)
			local content = data.content
			if data.source then
				content = ("-- Author: %s\n%s"):format(data.source, content)
			end
			if data.title then
				content = ("-- Description: %s\n%s"):format(data.title, content)
			end
			local fields = {
				program = 1,
				code = content,
			}
			local nodedef = minetest.registered_nodes[node.name]
			nodedef.on_receive_fields(pos, "", fields, player)
		end,
	}
}
