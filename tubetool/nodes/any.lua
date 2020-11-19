--
-- Register fallback node handler (wildcard node) for tubetool
--

local ns = metatool.ns('tubetool')

local nodedef = {
	group = '*',
}

function nodedef:before_read() return false end
function nodedef:before_write() return false end
function nodedef:before_info() return true end
function nodedef:copy() end
function nodedef:paste() end

function nodedef:info(node, pos, player, itemstack)
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
end

return {
	name = '*',
	nodes = '*',
	tooldef = nodedef,
}
