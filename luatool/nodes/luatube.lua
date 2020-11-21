--
-- Register lua tube for luatool
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

local ns = metatool.ns('luatool')

local definition = {
	name = 'luatube',
	nodes = nodes,
	group = 'lua tube',
	protection_bypass_read = "interact",
}

function definition:info(node, pos, player, itemstack)
	return ns.info(node, pos, player, itemstack, 'lua tube')
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	-- get and store lua code
	local code = meta:get_string("code")

	-- return data required for replicating this tube settings
	return {
		description = string.format("Lua tube at %s", minetest.pos_to_string(pos)),
		code = code,
	}
end

function definition:paste(node, pos, player, data)
	-- restore settings and update tube, no api available
	local meta = minetest.get_meta(pos)
	if data.mem_stored then
		meta:set_string("lc_memory", data.mem)
	end
	local fields = {
		program = 1,
		code = data.code or meta:get_string("code"),
	}
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", fields, player)
end

return definition
