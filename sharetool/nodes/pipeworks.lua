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

function definition:before_info(pos, player)
	if ns:can_bypass(pos, player, 'owner') or metatool.before_info(self, pos, player, true) then
		-- Player is allowed to bypass protections or operate in area
		return true
	end
	return false
end

local function truth2int(value)
	if not tonumber(value) and type(value) == "string" then
		value = value:lower()
		return (value:find("ye[ps]") or value:find("tru")) and 1 or 0
	end
	return value and tonumber(value) ~= 0 and 1 or 0
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

local function set_channel(pos, meta, channel, receive)
	meta:set_string("channel", channel)
	-- new api wont set meta for can_receive so we need to set it here
	meta:set_int("can_receive", receive)
	-- old api requires second update_meta arg and sets meta, also required for new api but ignores second arg
	pipeworks.tptube.update_meta(meta, receive == 1)
	pipeworks.tptube.set_tube(pos, channel, receive)
	if not pipeworks.tptube.update_tube then
		-- old api wont set infotext, if it seems like old api then do it here
		local cr_description = (receive == 1) and "sending and receiving" or "sending"
		meta:set_string("infotext", pipeworks_translator("Teleportation Tube @1 on '@2'", cr_description, channel))
	end
	ns.mark_shared(meta)
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
		set_channel(pos, meta, channel, meta:get_int("can_receive"))

		return { success = true }
	end
end

metatool.form.register_form("sharetool:teleport-tube", {
	on_create = function(player, data)
		return metatool.form.Form({
			width = 10,
			height = 3.2,
		}):label({
			label = getdesc(data.pos), x = 0.2, y = 0.4,
		}):field({
			name = "channel", label = "New channel: " .. (data.msg or ""), default = data.channel,
			y = 1.2, h = 0.8, xidx = 1, xcount = 2
		}):field({
			name = "receive", label = "Receive: (truthy value)", default = data.receive,
			y = 1.2, h = 0.8, xidx = 2, xcount = 2
		}):button({
			label = "Update", name = "update",
			y = 2.2, h = 0.8, xidx = 1, xcount = 3,
		}):button({
			label = "Transfer", name = "transfer",
			y = 2.2, h = 0.8, xidx = 2, xcount = 3,
		}):button({
			label = "Close", name = "cancel", exit = true,
			y = 2.2, h = 0.8, xidx = 3, xcount = 3,
		})
	end,
	on_receive = function(player, fields, data)
		data.msg = nil
		if fields.update or fields.transfer or fields.key_enter_field then
			local name = player:get_player_name()
			local owner, mode, channel = explode_teleport_tube_channel(fields.channel)
			data.receive = truth2int(fields.receive)

			if not owner or not mode then
				-- Allow directly setting any public channel or private shared if transfering
				if fields.transfer then
					-- Use most restricted channel when adding owner without channel type information
					channel = ns.shared_account .. ":" .. channel
				end
			elseif fields.transfer then
				-- Swap owner between current player and shared account
				channel = (owner == ns.shared_account and name or ns.shared_account) .. mode .. channel
			else
				channel = owner .. mode .. channel
			end

			if not owner or owner == name or owner == ns.shared_account then
				-- Change channel ownership and mark as shared node
				set_channel(data.pos, minetest.get_meta(data.pos), channel, data.receive)
			else
				data.msg = "public, shared or yourself allowed"
			end

			data.channel = channel
			return false
		end
	end,
})

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

function definition:info(node, pos, player)
	local meta = minetest.get_meta(pos)
	metatool.form.show(player, "sharetool:teleport-tube", {
		pos = pos,
		channel = meta:get_string("channel"),
		receive = meta:get_int("can_receive"),
	})
end

return definition
