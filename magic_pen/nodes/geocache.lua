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

local definition = {
	name = 'geocache',
	nodes = "geocache:block",
	group = 'text',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local source = meta:get("owner")
	local title
	if player:get_player_name() == source then
		title = ("Geocache at %d,%d,%d"):format(pos.x,pos.y,pos.z)
	else
		local spos = scramble(pos)
		title = ("Geocache near %d,%d,%d"):format(spos.x,spos.y,spos.z)
	end
	return {
		description = title,
		source = source,
		title = title,
		content = meta:get("log"),
	}
end

return definition
