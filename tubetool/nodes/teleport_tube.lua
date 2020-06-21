--
-- Register teleport tube for tubetool
--

local S = metatool.S

local nodenameprefix = "pipeworks:teleport_tube_"

--luacheck: ignore unused argument node player
-- teleport tubes
local nodes = {}
for i=1,10 do
	table.insert(nodes, nodenameprefix .. i)
end

local tp_tube_form_index = {}

metatool.form.register_form(
	'tubetool:teleport_tube_list',
	function(player, data)
		local list = ""
		for _,tube in ipairs(data.tubes) do
			list = list .. ",1" ..
				"," .. math.floor(vector.distance(tube.pos, data.pos)) .. "m" ..
				"," .. minetest.formspec_escape(string.format("%d,%d,%d",tube.pos.x,tube.pos.y,tube.pos.z)) ..
				"," .. (tube.can_receive and "yes" or "no")
		end
		return "formspec_version[3]size[8,10;]label[0.1,0.5;" ..
			"Found " .. #data.tubes .. " teleport tubes, channel: " ..
			minetest.formspec_escape(data.channel) .. "]" ..
			"button_exit[0,9;4,1;wp;Waypoint]" ..
			"button_exit[4,9;4,1;exit;Exit]" ..
			"tablecolumns[indent;text,width=15;text,width=15;text,align=center]" ..
			"table[0,1;8,8;items;1,Distance,Location,Receive" .. list .. ";]"
	end,
	function(player, fields, data)
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
)

return {
	nodes = nodes,
	tooldef = {
		group = 'teleport tube',

		info = function(node, pos, player)
			if not pipeworks.tptube or not pipeworks.tptube.get_db then
				minetest.chat_send_player(
					player:get_player_name(),
					'Installed pipeworks version does not have required tptube.get_db function.'
				)
				return
			end
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
		end,

		copy = function(node, pos, player)
			local meta = minetest.get_meta(pos)

			-- get and store channel and receive setting
			local channel = meta:get_string("channel")
			local receive = meta:get_int("can_receive")

			-- return data required for replicating this tube settings
			return {
				description = string.format("Channel: %s Receive: %d", channel, receive),
				channel = channel,
				receive = receive,
			}
		end,

		paste = function(node, pos, player, data)
			-- restore settings and update tube, no api available
			local fields = {
				channel = data.channel,
				['cr' .. data.receive] = data.receive,
			}
			local nodedef = minetest.registered_nodes[node.name]
			nodedef.on_receive_fields(pos, "", fields, player)
		end,
	}
}
