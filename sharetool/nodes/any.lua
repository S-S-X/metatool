--
-- Register fallback node handler (wildcard node) for sharetool
--

-- Radius for operation, area is cube and side length is RADIUS * 2 + 1
local RADIUS = 5

local ns = metatool.ns("sharetool")

local get_meta = minetest.get_meta
local get_node = minetest.get_node

local function is_area_protected(pos, radius, name)
	-- Check middle point (pointless?) and corners
	local checkpos = {
		pos,
		vector.add(pos, {x= radius,y= radius,z= radius}),
		vector.add(pos, {x= radius,y= radius,z=-radius}),
		vector.add(pos, {x= radius,y=-radius,z= radius}),
		vector.add(pos, {x= radius,y=-radius,z=-radius}),
		vector.add(pos, {x=-radius,y= radius,z= radius}),
		vector.add(pos, {x=-radius,y= radius,z=-radius}),
		vector.add(pos, {x=-radius,y=-radius,z= radius}),
		vector.add(pos, {x=-radius,y=-radius,z=-radius}),
	}
	for _,v in ipairs(checkpos) do
		if minetest.is_protected(v, name) then
			return true
		end
	end
	return false
end

local travelnet_nodes = {
	['travelnet:travelnet'] = 1,
	['locked_travelnet:travelnet'] = 1,
	['travelnet:travelnet_private'] = 1,
	['travelnet:elevator'] = 1,
}
local function transfer_nodes(pos1, pos2, owner, player)
	local newplayer = {
		get_player_name = function() return owner end
	}
	for x=pos1.x,pos2.x,1 do
		for y=pos1.y,pos2.y,1 do
			for z=pos1.z,pos2.z,1 do
				local pos = {x=x,y=y,z=z}
				local meta = get_meta(pos)
				if meta:get("owner") then
					local nodename = get_node(pos).name
					local nodedef = minetest.registered_nodes[nodename]
					if nodedef and nodedef.groups and nodedef.groups.technic_chest then
						pcall(function()nodedef.after_place_node(pos, newplayer)end)
					elseif travelnet_nodes[nodename] then
						ns:set_travelnet_owner(pos, player, owner)
					else
						meta:set_string("owner", owner)
					end
				end
			end
		end
	end
end

local function area_in_area(a, b)
	return a.pos1.x >= b.pos1.x and a.pos2.x <= b.pos2.x
		and a.pos1.y >= b.pos1.y and a.pos2.y <= b.pos2.y
		and a.pos1.z >= b.pos1.z and a.pos2.z <= b.pos2.z
end

metatool.form.register_form("sharetool:transfer-ownership", {
	on_create = function(player, data)
		local form = metatool.form.Form({
			width = 10,
			height = 10.6,
		}):raw(
			("label[0.2,0.7;Transfer node/area ownership %d,%d,%d radius %d]")
			:format(data.pos.x, data.pos.y, data.pos.z, RADIUS)
		):table({
			name = "owners", label = "Node owners:",
			y = 1, h = 4, yidx = 1, ycount = 2,
			columns = {"node", "pos", "owner"},
			values = data.owners
		}):table({
			name = "areas", label = "Protection areas:",
			y = 1, h = 4, yidx = 2, ycount = 2,
			columns = {"id", "owner", "name"},
			values = data.areas
		}):field({
			name = "owner", label = "New owner:", default = ns.shared_account,
			x = 6, y = 0.5, w = 3.9, h = 0.8
		}):button({
			label = "Transfer", name = "transfer", exit = true,
			y = 9, h = 0.8, xidx = 1, xcount = 2,
		}):button({
			label = "Cancel", name = "cancel", exit = true,
			y = 9, h = 0.8, xidx = 2, xcount = 2,
		})
		return form:render()
	end,
	on_receive = function(player, fields, data)
		if not player or not fields or not data then
			return
		end
		local tool = metatool.tool("sharetool")
		if not metatool.check_privs(player, tool.privs) then
			minetest.chat_send_player(player:get_player_name(), 'You are not allowed to use this tool.')
			return
		end
		if fields.transfer and fields.owner then
			local name = player:get_player_name()
			if not fields.owner or not ns.player_exists(fields.owner) then
				minetest.chat_send_player(player:get_player_name(),
					("Player %s not found, transfer failed"):format(fields.owner or "?")
				)
				return
			end
			if is_area_protected(data.pos, RADIUS, name) then
				minetest.chat_send_player(player:get_player_name(), "Area is protected, transfer failed")
				return
			end
			-- All checks passed, transfer ownership
			local minpos = vector.subtract(data.pos, RADIUS)
			local maxpos = vector.add(data.pos, RADIUS)
			transfer_nodes(minpos, maxpos, fields.owner, player)
			for id,area in pairs(areas and areas:getAreasIntersectingArea(minpos, maxpos)) do
				if area_in_area(area, {pos1 = minpos, pos2 = maxpos}) then
					-- Do not care about possible failures here, let it finish also in case of problems
					-- Problems with area transfer will be reported through chat messages
					ns:set_area_owner(id, fields.owner, player)
				end
			end
			minetest.chat_send_player(player:get_player_name(),
				("Ownership transfer completed, area is now owned by %s"):format(fields.owner)
			)
		end
	end,
})

local definition = {
	name = '*',
	nodes = '*',
	group = '*',
}

function definition:before_read() return false end
function definition:before_write() return false end
-- Use default protection check
--function definition:before_info(pos, player) return true end
function definition:copy() end
function definition:paste() end

function definition:info(node, pos, player, itemstack)
	local minpos = vector.subtract(pos, RADIUS)
	local maxpos = vector.add(pos, RADIUS)
	local arealist = {}
	for id,area in pairs(areas and areas:getAreasIntersectingArea(minpos, maxpos)) do
		if area_in_area(area, {pos1 = minpos, pos2 = maxpos}) then
			table.insert(arealist, {id, area.owner, area.name})
		end
	end
	local owners = {}
	for x=minpos.x,maxpos.x,1 do
		for y=minpos.y,maxpos.y,1 do
			for z=minpos.z,maxpos.z,1 do
				local cpos = {x=x,y=y,z=z}
				local name = get_node(cpos).name
				local owner = get_meta(cpos):get("owner")
				if owner then
					table.insert(owners, {name, ("%d,%d,%d"):format(cpos.x, cpos.y, cpos.z), owner})
				end
			end
		end
	end
	metatool.form.show(player, "sharetool:transfer-ownership", {
		pos = pos,
		owners = owners,
		areas = arealist,
	})
end

return definition
