--
-- Register books for Magic pen
--

-- books
local nodes = {}

local bookcolors = {
	"red",
	"green",
	"blue",
	"violet",
	"grey",
	"brown"
}

for _, color in ipairs(bookcolors) do
	table.insert(nodes, string.format("homedecor:book_%s", color))
	table.insert(nodes, string.format("homedecor:book_open_%s", color))
end
table.insert(nodes, "homedecor:book")
table.insert(nodes, "homedecor:book_open")

--luacheck: ignore unused argument node player
return {
	name = 'book',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			return {
				description = ("%s at %s"):format(node.name, minetest.position_to_string(pos)),
				source = meta:get_string("owner"),
				title = meta:get_string("title"),
				content = meta:get_string("text"),
			}
		end,
		--luacheck: ignore unused argument data
		paste = function(node, pos, player, data)
			local meta = minetest.get_meta(pos)
			meta:set_string("title", data.title or "")
			meta:set_string("text", data.content or "")
		end,
	}
}
