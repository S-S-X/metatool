--
-- Register teleport tubes for sharetool
--

if not pipeworks or not pipeworks.tptube or not pipeworks.tptube.set_tube or not pipeworks.tptube.update_meta then
	minetest.log("error", "loading teleport tubes for sharetool failed, update your pipeworks mod")
	return
end

local S = metatool.S
local getdesc = metatool.util.description --(pos, node, meta)
local pipeworks_translator = minetest.get_translator("pipeworks")

-- get namespace defined at sharetool init.lua
local ns = metatool.ns('sharetool')

local nodenameprefix = "pipeworks:teleport_tube_"

-- teleport tubes
local nodes = {}
for i=1,10 do
	table.insert(nodes, nodenameprefix .. i)
end

local definition = {
	name = 'teleport-tube',
	nodes = nodes,
	group = 'teleport-tube',
}

function definition:before_read(pos, player)
	if ns:can_bypass(pos, player, 'owner') or metatool.before_read(self, pos, player, true) then
		-- Player is allowed to bypass protections or operate in area
		return true
	end
	return false
end

function definition:before_write(pos, player)
	if ns:can_bypass(pos, player, 'owner') or metatool.before_write(self, pos, player, true) then
		-- Player is allowed to bypass protections or operate in area
		return true
	end
	return false
end

local function explode_teleport_tube_channel(channel)
	-- Return channel, owner, type. Owner can be nil. Type can be nil, ; or :
	local a, b, c = channel:match("^([^:;]+)([:;])(.*)$")
	a = a ~= "" and a or nil
	b = b ~= "" and b or nil
	if b then
		return a,b,c
	end
	-- No match for owner and mode
	return nil,nil,channel
end

local function transfer_to(newowner, node, pos, player)
	local meta = minetest.get_meta(pos)
	local raw_channel = meta:get("channel")
	if raw_channel then
		local owner, mode, channel = explode_teleport_tube_channel(raw_channel)
		if not owner or not mode then
			return
		end

		channel = newowner .. mode .. channel
		if channel == raw_channel then
			return {
				success = false,
				description = S("%s is already owner of %s", newowner, getdesc(pos, node, meta))
			}
		end

		-- Change channel ownership and mark as shared node
		local receive = meta:get_int("can_receive")
		meta:set_string("channel", channel)
		pipeworks.tptube.update_meta(meta, receive == 1)
		pipeworks.tptube.set_tube(pos, channel, receive)
		local cr_description = (receive == 1) and "sending and receiving" or "sending"
		meta:set_string("infotext", pipeworks_translator("Teleportation Tube @1 on '@2'", cr_description, channel))

		ns.mark_shared(meta)
		return { success = true }
	end
end

function definition:copy(node, pos, player)
	-- Copy function does not really copy anything here
	-- but instead it will claim ownership of pointed
	-- node and mark it as shared node
	return transfer_to(player:get_player_name(), node, pos, player) or { success = false }
end

function definition:paste(node, pos, player, data)
	-- Paste function does not really paste anything here
	-- but instead it will restore ownership of pointed
	-- node and mark it as shared node
	return transfer_to(ns.shared_account, node, pos, player) or { success = false }
end

return definition
