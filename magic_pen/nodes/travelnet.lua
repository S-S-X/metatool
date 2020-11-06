--
-- Register travelnet for Magic pen
--

--luacheck: ignore unused argument node player
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
			return {
				description = "NOT IMPLEMENTED",
				content = "NOT IMPLEMENTED",
			}
		end,
	}
}
