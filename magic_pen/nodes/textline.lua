--
-- Register textline for Magic pen
--

local definition = {
	name = 'textline',
	nodes = "textline:text",
	group = 'text',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	return {
		description = ("Textline at %s"):format(minetest.pos_to_string(pos)),
		content = meta:get("text"),
	}
end

return definition
