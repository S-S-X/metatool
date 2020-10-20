--
-- Register fallback node handler (wildcard node) for tubetool
--

local ns = metatool.ns('tubetool')

--luacheck: ignore unused argument node player
return {
	name = '*',
	nodes = '*',
	tooldef = {
		group = '*',

		before_read = function() return false end,
		before_write = function() return false end,
		before_info = function() return true end,
		copy = function() end,
		paste = function() end,

		info = function(node, pos, player, itemstack)
			-- Display teleport tubes form if tool has teleport tube data
			local tooldata = metatool.read_data(itemstack)
			if not tooldata or tooldata.group ~= 'teleport tube' then return end
			if not ns.pipeworks_tptube_api_check(player) then return end

			local channel = tooldata.data.channel
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

	}
}
