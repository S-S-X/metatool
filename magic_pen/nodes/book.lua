--
-- Register books for Magic pen
-- https://gitlab.com/VanessaE/homedecor_modpack/-/tree/master/homedecor_books
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

return {
	name = 'book',
	nodes = nodes,
	tooldef = {
		group = 'text',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			return {
				description = ("%s at %s"):format(node.name, minetest.pos_to_string(pos)),
				source = meta:get("owner"),
				title = meta:get("title"),
				content = meta:get("text"),
			}
		end,
		--luacheck: ignore unused argument data
		paste = function(node, pos, player, data)
			local meta = minetest.get_meta(pos)
			if data.title then
				meta:set_string("title", data.title)
				meta:set_string("infotext", data.title)
			end
			if data.content then
				meta:set_string("text", data.content)
			end
		end,
	}
}
