--
-- Register travelnet for Magic pen
--

local function fmt_station(name, data, include_coords)
	if type(name) ~= "string" then
		name = "<invalid station data>"
	end
	if include_coords then
		local p = data.pos
		if type(p) ~= "table" then
			return ("Station %s at <invalid pos>"):format(name)
		end
		return ("Station %s at %d,%d,%d"):format(name, p.x, p.y, p.z)
	end
	return name
end

local function collect_stations(t, network, include_coords, is_elevator)
	-- directly edit supplied table t
	if is_elevator then
		for stname,stdata in pairs(network) do
			-- elevation included for sorting
			table.insert(t, {-stdata.pos.y, fmt_station(stname, stdata, include_coords)})
		end
	else
		for stname,stdata in pairs(network) do
			-- stname included for sorting
			table.insert(t, {stdata.timestamp, fmt_station(stname, stdata, include_coords)})
		end
	end
	-- sort table based on y location or timestamp
	table.sort(t, function(a,b)
		return a[1] < b[1]
	end);
	-- drop sorting data
	for i=1, #t do
		t[i] = t[i][2]
	end
end

local definition = {
	name = 'travelnet',
	nodes = {
		'travelnet:travelnet',
		'travelnet:travelnet_red',
		'travelnet:travelnet_blue',
		'travelnet:travelnet_green',
		'travelnet:travelnet_black',
		'travelnet:travelnet_white',
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
		collect_stations(stations, travelnet.targets[owner][network], include_coords, node.name == "travelnet:elevator")
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
