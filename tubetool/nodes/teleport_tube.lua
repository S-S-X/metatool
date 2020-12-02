--
-- Register teleport tube for tubetool
--

local S = metatool.S

local nodenameprefix = "pipeworks:teleport_tube_"

-- teleport tubes
local nodes = {}
for i=1,10 do
	table.insert(nodes, nodenameprefix .. i)
end

local ns = metatool.ns('tubetool')

local tp_tube_form_index = {}

metatool.form.register_form('tubetool:teleport_tube_list', {
	on_create = function(player, data)
		local list = ""
		for _,tube in ipairs(data.tubes) do
			list = list .. ",1" ..
				"," .. math.floor(vector.distance(tube.pos, data.pos)) .. "m" ..
				"," .. minetest.formspec_escape(string.format("%d,%d,%d",tube.pos.x,tube.pos.y,tube.pos.z)) ..
				"," .. (tube.can_receive and "yes" or "no")
		end
		local form = metatool.form.Form({ width = 8, height = 10 })
		form:raw("label[0.1,0.5;" ..
			"Found " .. #data.tubes .. " teleport tubes, channel: " ..
			minetest.formspec_escape(data.channel) .. "]" ..
			"button_exit[0,9;4,1;wp;Waypoint]" ..
			"button_exit[4,9;4,1;exit;Exit]" ..
			"tablecolumns[indent;text,width=15;text,width=15;text,align=center]" ..
			"table[0,1;8,8;items;1,Distance,Location,Receive" .. list .. ";]")
		return form
	end,
	on_receive = function(player, fields, data)
		local name = player:get_player_name()
		local evt = minetest.explode_table_event(fields.items)
		if tp_tube_form_index[name] and (evt.type == "DCL" or (fields.wp and fields.quit)) then
			local tube = data.tubes[tp_tube_form_index[name]]
			local id = player:hud_add({
				hud_elem_type = "waypoint",
				name = S("%s\n\nReceive: %s", data.channel, tube.can_receive and "yes" or "no"),
				text = "m",
				number = 0xE0B020,
				world_pos = tube.pos
			})
			minetest.after(60, function() if player then player:hud_remove(id) end end)
		elseif evt.type == "CHG" or evt.type == "DCL" then
			tp_tube_form_index[name] = evt.row > 1 and evt.row - 1 or nil
		end
	end
})

local definition = {
	name = 'teleport_tube',
	nodes = nodes,
	group = "teleport tube",
	protection_bypass_read = "interact",
}

function definition:info(node, pos, player)
	if not ns.pipeworks_tptube_api_check(player) then return end
	local meta = minetest.get_meta(pos)
	local channel = meta:get_string("channel")
	if channel == "" then
		minetest.chat_send_player(
			player:get_player_name(),
			'Invalid channel, impossible to list connected tubes.'
		)
		return
	end
	local db = pipeworks.tptube.get_db()
	local tubes = {}
	for hash,data in pairs(db) do
		if data.channel == channel then
			table.insert(tubes, {
				pos = minetest.get_position_from_hash(hash),
				can_receive = data.cr == 1,
			})
		end
	end
	metatool.form.show(player, 'tubetool:teleport_tube_list', {pos = pos, channel = channel, tubes = tubes})
end

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)

	-- get and store channel and receive setting
	local channel = meta:get_string("channel")
	local receive = meta:get_int("can_receive")
	local description
	if channel == "" then
		description = "Teleport tube configuration cleaner"
	else
		description = meta:get_string("infotext")
	end

	-- return data required for replicating this tube settings
	return {
		description = description,
		channel = channel,
		receive = receive,
	}
end

function definition:paste(node, pos, player, data)
	-- restore settings and update tube, no api available
	local fields = {
		channel = data.channel,
		["cr" .. data.receive] = data.receive,
	}
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", fields, player)
end

return definition
