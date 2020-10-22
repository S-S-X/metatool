--
-- tubetool:wand is in game tool that allows cloning pipeworks node data
--

local recipe = {
	{ '', '', 'default:mese_crystal' },
	{ '', 'mesecons_luacontroller:luacontroller0000', '' },
	{ 'default:obsidian_shard', '', '' }
}

--luacheck: ignore unused argument tooldef player pointed_thing node pos
local tool = metatool:register_tool('luatool', {
	description = 'LuaTool',
	name = 'LuaTool',
	texture = 'luatool_wand.png',
	recipe = recipe,
	settings = {
		machine_use_priv = 'server'
	},
	on_read_node = function(tooldef, player, pointed_thing, node, pos)
		local data, group = tooldef:copy(node, pos, player)
		local description = type(data) == 'table' and data.description or ('Data from ' .. minetest.pos_to_string(pos))
		return data, group, description
	end,
	on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos)
		tooldef:paste(node, pos, player, data, group)
	end,
})

local function find_luatool_stack(player, refstack)
	local inv = player:get_inventory()
	local invsize = inv:get_size('main')
	local name = refstack:get_name()
	local count = refstack:get_count()
	local meta = refstack:get_meta()
	local invindex, invstack
	for i=1,invsize do
		local stack = inv:get_stack('main', i)
		if stack:get_count() == count and stack:get_name() == name and stack:get_meta():equals(meta) then
			-- This item stack seems very similar to one that were used originally, use this
			invindex = i
			invstack = stack
			break
		end
	end
	return inv, invindex, invstack
end

-- lua controller / lua tube mem inspection form
metatool.form.register_form(
	'luatool:mem_inspector',
	function(player, data)
		local raw_mem = minetest.deserialize(data.mem)
		local fmt_mem = dump(raw_mem)
		return "formspec_version[3]size[10,12;]label[0.1,0.5;" ..
			"Memory contents for " .. minetest.formspec_escape(data.name) .. "]" ..
			"button_exit[0,11;5,1;save;Save for programming]" ..
			"button_exit[5,11;5,1;exit;Exit]" ..
			"textarea[0,1;10,10;mem;;" .. minetest.formspec_escape(fmt_mem) .. "]"
	end,
	function(player, fields, data)
		if fields.save and fields.quit then
			local itemstack = data.itemstack
			if not itemstack then
				minetest.chat_send_player(player:get_player_name(), 'Could not save device memory contents.')
				return
			end
			local inv, index, stack = find_luatool_stack(player, itemstack)
			if stack then
				local tooldata = metatool.read_data(stack) or {data={},group=data.group}
				local description = nil
				if not tooldata.data.mem_stored then
					if tooldata.data.code then
						description = stack:get_meta():get_string('description') .. " with memory"
					else
						description = "CPU memory contents"
					end
				end
				tooldata.data.mem = data.mem
				tooldata.data.mem_stored = true
				metatool.write_data(stack, tooldata, description)
				inv:set_stack('main', index, stack)
				minetest.chat_send_player(
					player:get_player_name(),
					'Device memory contents stored in tool memory.'
				)
			else
				minetest.chat_send_player(player:get_player_name(), 'Could not save device memory contents.')
			end
		end
	end
)

tool:ns({
	info = function(node, pos, player, itemstack, group)
		local meta = minetest.get_meta(pos)
		local mem = meta:get_string('lc_memory')
		metatool.form.show(player, 'luatool:mem_inspector', {
			group = group, -- tool storage group for stack manipulation
			itemstack = itemstack, -- tool itemstack
			name = "CPU at " .. minetest.pos_to_string(pos),
			mem = mem,
		})
	end,
})

-- nodes
local modpath = minetest.get_modpath('luatool')
tool:load_node_definition(dofile(modpath .. '/nodes/luatube.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/luacontroller.lua'))
tool:load_node_definition(dofile(modpath .. '/nodes/microcontroller.lua'))
