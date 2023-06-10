--
-- Register lua controller for luatool
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

local nodenameprefixes = {
	"mesecons_luacontroller:luacontroller",
	"mooncontroller:mooncontroller"
}

local nodes = {}
for _, prefix in ipairs(nodenameprefixes) do
	-- lua/moon controller, 16 different nodes
	for i=0,15 do
		table.insert(nodes, prefix .. lpadcut(d2b(i), '0', 4))
	end
	table.insert(nodes, prefix .. '_burnt')
end

local ns = metatool.ns('luatool')

local definition = {
	name = 'luacontroller',
	nodes = nodes,
	group = 'lua controller',
	protection_bypass_read = "interact",
}

function definition:info(node, pos, player, itemstack)
	local meta = minetest.get_meta(pos)
	local mem = meta:get_string("lc_memory")
	return ns.info(pos, player, itemstack, mem, "lua controller")
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	-- get and store lua code
	local code = meta:get_string("code")

	-- return data required for replicating this controller settings
	return {
		description = string.format("Lua controller at %s", minetest.pos_to_string(pos)),
		code = code,
	}
end

function definition:paste(node, pos, player, data)
	-- restore settings and update lua controller, no api available
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
