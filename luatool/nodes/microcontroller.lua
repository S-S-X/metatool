--
-- Register mesecons microcontroller for luatool
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

local nodenameprefix = "mesecons_microcontroller:microcontroller"

-- microcontroller, 16 different nodes
local nodes = {}
for i=0,15 do
	table.insert(nodes, nodenameprefix .. lpadcut(d2b(i), '0', 4))
end

local nodedef = {
	group = 'microcontroller',
	protection_bypass_read = "interact",
}

function nodedef:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	-- get and store lua code
	local code = meta:get_string("code")

	-- return data required for replicating this controller settings
	return {
		description = string.format("Microcontroller at %s", minetest.pos_to_string(pos)),
		code = code,
	}
end

function nodedef:paste(node, pos, player, data)
	-- restore settings and update tube, no api available
	local fields = {
		code = data.code,
	}
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", fields, player)
end

return {
	name = 'microcontroller',
	nodes = nodes,
	tooldef = nodedef,
}
