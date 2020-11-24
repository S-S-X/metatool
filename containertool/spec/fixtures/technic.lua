
mineunit:set_modpath("technic", "spec/fixtures")

technic = {}
technic.chests = {}
technic.chests.colors = {
	{"black", S("Black")},
	{"blue", S("Blue")},
	{"brown", S("Brown")},
	{"cyan", S("Cyan")},
	{"dark_green", S("Dark Green")},
	{"dark_grey", S("Dark Grey")},
	{"green", S("Green")},
	{"grey", S("Grey")},
	{"magenta", S("Magenta")},
	{"orange", S("Orange")},
	{"pink", S("Pink")},
	{"red", S("Red")},
	{"violet", S("Violet")},
	{"white", S("White")},
	{"yellow", S("Yellow")},
}

function technic.chests.change_allowed(pos, player, owned, protected)
	if owned then
		if minetest.is_player(player) and not default.can_interact_with_node(player, pos) then
			return false
		end
	elseif protected then
		if minetest.is_protected(pos, player:get_player_name()) then
			return false
		end
	end
	return true
end
