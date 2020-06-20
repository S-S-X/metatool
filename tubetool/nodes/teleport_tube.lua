--
-- Register teleport tube for tubetool
--

local nodenameprefix = "pipeworks:teleport_tube_"

--luacheck: ignore unused argument node player
-- teleport tubes
local nodes = {}
for i=1,10 do
	table.insert(nodes, nodenameprefix .. i)
end

metatool.form.register_form(
	'tubetool:teleport_tube_list',
	function(player, data)
		local player_pos = player:get_pos()
		local list = ""
		for _,tube in ipairs(data.tubes) do
			list = list ..
				"," .. math.floor(vector.distance(tube.pos, player_pos)) .. "m" ..
				"," .. minetest.formspec_escape(string.format("%d,%d,%d",tube.pos.x,tube.pos.y,tube.pos.z)) ..
				",   " .. (tube.can_receive and "yes" or "no")
		end
		local header = minetest.formspec_escape(data.channel) .. ", total " .. #data.tubes .. " tubes]"
		return "size[8,10;]" ..
			"label[0,0;Teleport tubes on channel " .. header ..
			"button_exit[4,9;4,1;exit;Exit]" ..
			"tablecolumns[text;text;text]" ..
			"table[0,0.5;7.7,8.5;items;Distance            ,Coords            ,Receive" .. list .. ";]"
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
			metatool.form.show(player, 'tubetool:teleport_tube_list', {channel = channel, tubes = tubes})
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
