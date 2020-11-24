--
-- Register travelnet for Magic pen
--

local function fmt_station(name, data, include_coords)
	if include_coords then
		local p = data.pos
		return ("Station %s at %d,%d,%d"):format(name, p.x, p.y, p.z)
	end
	return name
end

local definition = {
	name = 'travelnet',
	nodes = {
		'travelnet:travelnet',
		'locked_travelnet:travelnet',
		'travelnet:travelnet_private',
		'travelnet:elevator',
	},
	group = 'text',
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get("owner")
	local include_coords = player:get_player_name() == owner
	local network = meta:get("station_network")
	local stations = {}
	if owner and network and travelnet.targets[owner] and travelnet.targets[owner][network] then
		for stname,stdata in pairs(travelnet.targets[owner][network]) do
			table.insert(stations, fmt_station(stname, stdata, include_coords))
		end
	else
		table.insert(stations, fmt_station(meta:get("station_name"), {pos=pos}, include_coords))
	end
	local nicename = minetest.registered_nodes[node.name].description or node.name
	return {
		description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
		content = table.concat(stations, "\n"),
		title = network,
		source = owner,
	}
end

return definition
