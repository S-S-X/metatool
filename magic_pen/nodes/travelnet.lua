--
-- Register travelnet for Magic pen
--

return {
	name = 'travelnet',
	nodes = {
		'travelnet:travelnet',
		'locked_travelnet:travelnet',
		'travelnet:travelnet_private',
		'travelnet:elevator',
	},
	tooldef = {
		group = 'text',
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = meta:get( "station_name" ),
				title = meta:get_string( "station_network" ),
				source = meta:get( "owner" ),
			}
		end,
	}
}
