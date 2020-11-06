--
-- Register lua controller for Magic pen
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
local lpadcut = function(s, c, n)
	return (c:rep(n - #s) .. s):sub(math.max(0, #s - n + 1), #s + 1)
end

local nodenameprefix = "mesecons_luacontroller:luacontroller"

-- lua controller, 16 different nodes
local nodes = {}
for i=0,15 do
	table.insert(nodes, nodenameprefix .. lpadcut(d2b(i), '0', 4))
end
table.insert(nodes, nodenameprefix .. '_burnt')

--luacheck: ignore unused argument node player
return {
	name = 'luacontroller',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			return {
				description = string.format("Lua controller at %s", minetest.pos_to_string(pos)),
				content = meta:get_string("code"),
			}
		end,
		paste = function(node, pos, player, data)
			-- restore settings and update lua controller, no api available
			local meta = minetest.get_meta(pos)
			local fields = {
				program = 1,
				code = data.content,
			}
			local nodedef = minetest.registered_nodes[node.name]
			nodedef.on_receive_fields(pos, "", fields, player)
		end,
	}
}
