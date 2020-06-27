--
-- Register sorting tube for tubetool
--

local o2b_lookup = {
	['0'] = '000',
	['1'] = '001',
	['2'] = '010',
	['3'] = '011',
	['4'] = '100',
	['5'] = '101',
	['6'] = '110',
	['7'] = '111',
}
local o2b = function(o)
	return o:gsub('.', o2b_lookup)
end
local d2b = function(d)
	return o2b(string.format('%o', d))
end
local lpad = function(s, c, n)
	return c:rep(n - #s) .. s
end

local nodenameprefix = "pipeworks:mese_tube_"
local inv_size = 6
local nodes = {}

-- mese tubes, 64 different nodes
for i=0,63 do
	table.insert(nodes, nodenameprefix .. lpad(d2b(i), '0', 6))
end

--luacheck: ignore unused argument node player
return {
	name = 'mese_tube',
	nodes = nodes,
	tooldef = {
		group = 'sorting tube',
		protection_bypass_read = "interact",
		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			-- get and store direction bits
			local enabled = {}
			for i=1,6 do
				table.insert(enabled, meta:get_int("l"..i.."s"))
			end

			-- get and store inventories data
			local inv_data = {}
			local itemcount = 0
			for i=1,6 do
				table.insert(inv_data, {})
				for slot=1,inv_size do
					local stack = inv:get_stack("line" .. i, slot)
					local item
					if not stack:is_empty() then
						item = stack:get_name()
						itemcount = itemcount + 1
					end
					-- add item or empty, do not care about count because sorting tube also does not care
					table.insert(inv_data[i], item or "")
				end
			end

			-- return data required for replicating this tube settings
			return {
				description = string.format("Items: %d States: %s", itemcount, table.concat(enabled, ",")),
				enabled = enabled,
				inventory = inv_data,
			}
		end,

		paste = function(node, pos, player, data)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()

			-- restore direction bits
			for index,value in ipairs(data.enabled) do
				meta:set_int("l" .. index .. "s", value)
			end

			-- restore inventories data
			for index,slots in ipairs(data.inventory) do
				for slotidx,item in ipairs(slots) do
					inv:set_stack("line" .. index, slotidx, ItemStack(item))
				end
			end

			-- update tube formspec, this seems to be cleanest solution
			local nodedef = minetest.registered_nodes[node.name]
			nodedef.on_receive_fields(pos, "", {}, player)
		end,
	}
}
