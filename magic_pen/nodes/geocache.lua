--
-- Register geocache for Magic pen
--

local function scramble(pos)
	return {
		x = pos.x + math.random(0,200) - 100,
		y = pos.y + math.random(0,200) - 100,
		z = pos.z + math.random(0,200) - 100,
	}
end

return {
	name = 'geocache',
	nodes = "geocache:block",
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local spos = scramble(pos)
			return {
				description = ("Geocache at %s"):format(node.name, minetest.pos_to_string(pos)),
				source = meta:get("owner"),
				title = ("Geocache near %d,%d,%d"):format(spos.x,spos.y,spos.z),
				content = meta:get("log"),
			}
		end,
	}
}
