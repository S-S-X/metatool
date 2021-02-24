--
-- Register fallback node handler (wildcard node) for sharetool
--

-- Default radius for operation, area is cube and side length is RADIUS * 2 + 1
local RADIUS = 5

local ns = metatool.ns("sharetool")

local get_meta = minetest.get_meta
local get_node = minetest.get_node

local definition = {
	name = '*',
	nodes = '*',
	group = '*',
}

local function is_area_protected(pos, radius, player)
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
	for _,cpos in ipairs(checkpos) do
		if not definition:before_info(cpos, player) then
			return true
		end
	end
	return false
end

local travelnet_nodes = {
	['travelnet:travelnet'] = 1,
	['travelnet:travelnet_red'] = 1,
	['travelnet:travelnet_blue'] = 1,
	['travelnet:travelnet_green'] = 1,
	['travelnet:travelnet_black'] = 1,
	['travelnet:travelnet_white'] = 1,
	['locked_travelnet:travelnet'] = 1,
	['travelnet:travelnet_private'] = 1,
	['travelnet:elevator'] = 1,
}
local function transfer_nodes(pos1, pos2, owner, player)
	local newplayer = {
		get_player_name = function() return owner end
	}
	for _,pos in ipairs(minetest.find_nodes_with_meta(pos1, pos2)) do
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

local function get_areas(minpos, maxpos)
	local results = {}
	for id,area in pairs(areas and areas:getAreasIntersectingArea(minpos, maxpos)) do
		if metatool.util.area_in_area(area, {pos1 = minpos, pos2 = maxpos}) then
			table.insert(results, {id, area.owner, area.name})
		end
	end
	return results
end

local function get_owners(minpos, maxpos)
	local results = {}
	for _,pos in ipairs(minetest.find_nodes_with_meta(minpos, maxpos)) do
		local name = get_node(pos).name
		local owner = get_meta(pos):get("owner")
		if owner then
			table.insert(results, {name, ("%d,%d,%d"):format(pos.x, pos.y, pos.z), owner})
		end
	end
	return results
end

local function get_operation_radius(radius)
	radius = tonumber(radius)
	if not radius then
		return RADIUS, false
	end
	local max_radius = metatool.settings("sharetool", "max_radius") or RADIUS
	return math.min(max_radius, math.max(0, math.floor(radius))), ((radius >= 0) and (radius <= max_radius))
end

metatool.form.register_form("sharetool:transfer-ownership", {
	on_create = function(player, data)
		local max_radius = metatool.settings("sharetool", "max_radius") or RADIUS
		local radius = data.radius or RADIUS
		local msg = data.msg or ""
		local default = data.default or ns.shared_account
		local form = metatool.form.Form({
			width = 10,
			height = 11,
		}):raw(
			("label[0.2,0.5;Transfer node/area ownership %d,%d,%d radius %d]")
			:format(data.pos.x, data.pos.y, data.pos.z, radius)
		):field({
			name = "owner", label = "New owner: " .. msg, default = default,
			y = 1, h = 0.8, xidx = 1, xcount = 2
		}):field({
			name = "radius", label = "Radius: (max " .. max_radius .. ")" , default = radius,
			y = 1, h = 0.8, xidx = 2, xcount = 2
		}):table({
			name = "owners", label = "Node owners:",
			y = 2, h = 4, yidx = 1, ycount = 2,
			columns = {"node", "pos", "owner"},
			values = data.owners
		}):table({
			name = "areas", label = "Protection areas:",
			y = 2, h = 4, yidx = 2, ycount = 2,
			columns = {"id", "owner", "name"},
			values = data.areas
		}):button({
			label = "Transfer", name = "transfer",
			y = 10.2, h = 0.8, xidx = 1, xcount = 3,
		}):button({
			label = "Reload", name = "reload",
			y = 10.2, h = 0.8, xidx = 2, xcount = 3,
		}):button({
			label = "Close", name = "cancel", exit = true,
			y = 10.2, h = 0.8, xidx = 3, xcount = 3,
		})
		return form
	end,
	on_receive = function(player, fields, data)
		data.msg = nil
		if fields.radius and (fields.reload or fields.transfer) then
			data.default = fields.owner
			local radius, valid_radius = get_operation_radius(fields.radius)
			local minpos = vector.subtract(data.pos, radius)
			local maxpos = vector.add(data.pos, radius)
			local name = player:get_player_name()
			if not fields.owner or not ns.player_exists(fields.owner) then
				minetest.chat_send_player(name,
					("Player %s not found, transfer failed"):format(fields.owner or "?")
				)
				data.msg = "Player not found!"
			elseif not valid_radius then
				radius = RADIUS
				minetest.chat_send_player(name, "Invalid or too large radius, transfer failed")
			elseif is_area_protected(data.pos, radius, player) then
				minetest.chat_send_player(name, "Area is protected, transfer failed")
			elseif fields.transfer then
				-- All checks passed, transfer ownership
				transfer_nodes(minpos, maxpos, fields.owner, player)
				for id,area in pairs(areas and areas:getAreasIntersectingArea(minpos, maxpos)) do
					if metatool.util.area_in_area(area, {pos1 = minpos, pos2 = maxpos}) then
						-- Do not care about possible failures here, let it finish also in case of problems
						-- Problems with area transfer will be reported through chat messages
						ns:set_area_owner(id, fields.owner, player)
					end
				end
				-- Confirmation, update form table data
				minetest.chat_send_player(name,
					("Ownership transfer completed, area is now owned by %s"):format(fields.owner)
				)
			end
			data.radius = radius
			data.owners = get_owners(minpos, maxpos)
			data.areas = get_areas(minpos, maxpos)
			return false
		end
	end,
})

function definition:before_read() return false end
function definition:before_write() return false end
-- Use default protection check
--function definition:before_info(pos, player) return true end
function definition:copy() end
function definition:paste() end

function definition:info(node, pos, player, itemstack)
	local minpos = vector.subtract(pos, RADIUS)
	local maxpos = vector.add(pos, RADIUS)
	metatool.form.show(player, "sharetool:transfer-ownership", {
		pos = pos,
		owners = get_owners(minpos, maxpos),
		areas = get_areas(minpos, maxpos),
	})
end

return definition
