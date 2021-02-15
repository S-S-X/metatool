--
-- Register digistuff ram for luatool
--

local ns = metatool.ns('luatool')

local definition = {
	name = 'memory',
	nodes = {
		"digistuff:ram",
		"digistuff:eeprom",
	},
	group = 'memory',
	protection_bypass_read = "interact",
}

function definition:info(node, pos, player, itemstack)
	local meta = minetest.get_meta(pos)
	local mem = {}
	local fields = meta:to_table().fields or {}
	for key, data in pairs(fields) do
		if key:find("^data") then
			mem[key] = data
		end
	end
	return ns.info(pos, player, itemstack, mem, 'memory', true)
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local mem = {}
	local fields = meta:to_table().fields
	if type(fields) == "table" then
		for key, data in pairs(fields) do
			if key:find("^data") then
				mem[key] = data
			end
		end
		if next(mem) then
			return {
				description = string.format("%s at %s", node.name, minetest.pos_to_string(pos)),
				mem = mem,
			}
		end
	end
end

function definition:paste(node, pos, player, data)
	if data.mem then
		local meta = minetest.get_meta(pos)
		for key, value in pairs(data.mem) do
			meta:set_string(key, value)
		end
	end
end

return definition
