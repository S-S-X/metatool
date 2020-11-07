--
-- Register Digistuff Touchscreen for Magic pen
--

local function add_field(t, f)
	for k,v in pairs(f) do
		if type(v) == "table" then
			add_field(t, v)
		else
			table.insert(t, tostring(k).."="..tostring(v))
		end
	end
end

--luacheck: ignore unused argument node player
return {
	name = 'touchscreen',
	nodes = "digistuff:touchscreen",
	tooldef = {
		group = 'text',
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local data = minetest.deserialize(meta:get_string("data"))
			local content = {}
			if type(data) == "table" then
				for _,field in ipairs(data) do
					add_field(content, field)
				end
			end
			local nicename = minetest.registered_nodes[node.name].description or node.name
			return {
				description = ("%s at %s"):format(nicename, minetest.pos_to_string(pos)),
				content = table.concat(content, "\n"),
			}
		end,
	}
}
