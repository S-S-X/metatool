--
-- Register fallback node handler (wildcard node) for tubetool
--

local ns = metatool.ns('tubetool')

local definition = {
	name = '*',
	nodes = '*',
	group = '*',
}

function definition:before_read() return false end
function definition:before_write() return false end
function definition:before_info() return true end
function definition:copy() end
function definition:paste() end

function definition:info(node, pos, player, itemstack)
	-- Display teleport tubes form if tool has teleport tube data
	local tooldata = metatool.read_data(itemstack)
	if not tooldata or tooldata.group ~= 'teleport tube' then return end
	if not ns.pipeworks_tptube_api_check(player) then return end

	local channel = tooldata.data.channel
	if not channel or channel == "" then
		minetest.chat_send_player(
			player:get_player_name(),
			'Invalid channel, impossible to list connected tubes.'
		)
		return
	end
	local tubes = ns.get_teleport_tubes(channel, pos)
	metatool.form.show(player, 'tubetool:teleport_tube_list', {pos = pos, channel = channel, tubes = tubes})
end

return definition
