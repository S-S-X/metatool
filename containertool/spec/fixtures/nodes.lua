minetest.register_node(":technic:test_chest", {
	description = "Technic chest",
	groups = {
		snappy = 2, choppy = 2, oddly_breakable_by_hand = 2,
		tubedevice = 1, tubedevice_receiver = 1, technic_chest = 1,
	},
	on_receive_fields = function(...) print(...) end,
	on_skeleton_key_use = function(...) print(...) end,
	tube = {
		input_inventory = "main",
	},
})

local function set_injector_formspec(pos)
	local meta = minetest.get_meta(pos)
	local formspec = "fs_helpers_cycling:1:splitstacks"
	formspec = formspec.."button[0,1;4,1;mode_stack;"..S("Itemwise").."]"
	formspec = formspec.."button[4,1;4,1;enable;"..S("Disabled").."]"
	meta:set_string("formspec", formspec)
end

minetest.register_node(":technic:injector", {
	description = "Self-Contained Injector",
	groups = {snappy=2, choppy=2, oddly_breakable_by_hand=2, tubedevice=1, tubedevice_receiver=1},
	tube = {
		can_insert = function(...)end,
		insert_object = function(...)end,
		connect_sides = {left=1, right=1, back=1, top=1, bottom=1},
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Self-Contained Injector")
		meta:set_string("mode", "single items")
		--meta:get_inventory():set_size("main", 16)
		--minetest.get_node_timer(pos):start(1)
		set_injector_formspec(pos)
	end,
	on_receive_fields = function(...) print(...) end,
})

drawers = {}
