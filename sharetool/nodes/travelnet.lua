--
-- Register travelnet for sharetool
--

local definition = {
	name = 'travelnet',
	nodes = {
		'travelnet:travelnet',
		'locked_travelnet:travelnet',
		'travelnet:travelnet_private',
		'travelnet:elevator',
	},
	group = 'shared travelnet',
}

local travelnet_nodes = {}
for _,name in ipairs(definition.nodes) do
	travelnet_nodes[name] = true
end

-- get namespace defined at sharetool init.lua
local ns = metatool.ns('sharetool')

local function is_valid_pos(pos)
	return type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" and type(pos.z) == "number"
end

local function get_node(pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then
		local vm = VoxelManip()
		vm:read_from_map(pos, pos)
		node = minetest.get_node_or_nil(pos)
	end
	return node
end

local E_SUCCESS = 0
local E_METADATA = 1
local E_DATABASE = 2
local E_NODENAME = 3
local E_DUPLICATE = 4
local E_TIMESTAMP = 5
local E_POSITION = 6
local E_ENGINE = 7
local function add_problem(t, data, code, description)
	table.insert(t.problems, {
		is_valid_pos(data.pos) and metatool.util.pos_to_string(data.pos) or "?",
		data.station or "?", data.network or "?", data.owner or "?", description,
	})
	table.insert(t.problems_data, {
		code = code, pos = data.pos,
		station = data.station, network = data.network, owner = data.owner,
		netref = data.owner and data.network and travelnet.targets[data.owner][data.network],
	})
end

local function check_station_node(t, owner, network, station, data)
	if type(data) == "table" and is_valid_pos(data.pos) then
		local stdata = { pos = data.pos, owner = owner, network = network, station = station }
		local meta = minetest.get_meta(stdata.pos)
		local metaowner = meta:get("owner")
		local metanetwork = meta:get("station_network")
		local metastation = meta:get("station_name")
		if owner ~= metaowner then
			add_problem(t, stdata, E_METADATA, "Meta owner: " .. tostring(metaowner))
		end
		if metaowner and not ns.player_exists(metaowner) then
			add_problem(t, stdata, E_METADATA, "Meta owner account not found")
		end
		if network ~= metanetwork then
			add_problem(t, stdata, E_METADATA, "Meta network: " .. tostring(metanetwork))
		end
		if station ~= metastation then
			add_problem(t, stdata, E_METADATA, "Meta station: " .. tostring(metastation))
		end
		local node = get_node(stdata.pos)
		if node and not travelnet_nodes[node.name] then
			add_problem(t, stdata, E_NODENAME, "Wrong node: " .. tostring(node.name))
		elseif not node then
			add_problem(t, stdata, E_ENGINE, "Could not load node for position")
		end
	end
end

local function check_station_data(t, owner, network, station, data)
	if type(data) ~= "table" then
		local stdata = { owner = owner, network = network, station = station }
		add_problem(t, stdata, E_DATABASE, "Invalid data type: " .. type(data))
		return
	end
	local stdata = { pos = data.pos, owner = owner, network = network, station = station }
	if type(data.timestamp) ~= "number" then
		add_problem(t, stdata, E_TIMESTAMP, "Invalid timestamp type: " .. type(data.timestamp))
	end
	if type(data.pos) ~= "table" then
		add_problem(t, stdata, E_POSITION, "Invalid pos type: " .. type(data.pos))
	elseif not is_valid_pos(data.pos) then
		add_problem(t, stdata, E_POSITION,
			("Invalid pos axis type %s,%s,%s"):format(type(data.pos.x), type(data.pos.y), type(data.pos.z))
		)
	end
end

local function find_duplicates(t, stdata)
	local netref = travelnet.targets[stdata.owner][stdata.network]
	local checked = {}
	for station, data in pairs(netref) do
		if type(data) == "table" and is_valid_pos(data.pos) then
			local id = minetest.hash_node_position(data.pos)
			if checked[id] then
				add_problem(t,
					{ pos = data.pos, owner = stdata.owner, network = stdata.network, station = station },
					E_DUPLICATE, "Duplicate station: " .. checked[id]
				)
			else
				checked[id] = station
			end
		end
	end
end

local function find_invalid_nodes(t, stdata)
	local netref = travelnet.targets[stdata.owner][stdata.network]
	for station, data in pairs(netref) do
		check_station_data(t, stdata.owner, stdata.network, station, data)
		if type(data) == "table" and is_valid_pos(data.pos) then
			check_station_node(t, stdata.owner, stdata.network, station, data)
		end
	end
end

local function find_travelnet_from_db(pos)
	for owner, networks in pairs(travelnet.targets) do
		for network, stations in pairs(networks) do
			for station, data in pairs(stations) do
				local spos = data.pos
				if is_valid_pos(spos) and pos.x == spos.x and pos.y == spos.y and pos.z == spos.z then
					-- First match found, return it
					return owner, network, station
				end
			end
		end
	end
end

local function find_problems(pos)
	local results = { problems = {}, problems_data = {} }
	local meta = minetest.get_meta(pos)
	local owner = meta:get("owner")
	local network = meta:get("station_network")
	local station = meta:get("station_name")
	local stdata = { pos = pos, owner = owner, network = network, station = station }
	if not ns.player_exists(owner) then
		add_problem(results, stdata, E_ENGINE, "Owner account not found")
	end
	if type(travelnet.targets) ~= "table" then
		add_problem(results, stdata, E_DATABASE, "Everything is broken, contact nerds")
	elseif not owner then
		add_problem(results, stdata, E_METADATA, "Invalid owner meta")
	elseif type(travelnet.targets[owner]) ~= "table" then
		add_problem(results, stdata, E_DATABASE, "All networks missing")
	elseif not network then
		add_problem(results, stdata, E_METADATA, "Invalid network meta")
	elseif type(travelnet.targets[owner][network]) ~= "table" then
		add_problem(results, stdata, E_DATABASE, "Network not found")
	else
		find_duplicates(results, stdata)
		find_invalid_nodes(results, stdata)
	end
	return results
end

metatool.form.register_form("sharetool:validate-travelnet", {
	on_create = function(player, data)
		local error_count = 0
		for _, problem in ipairs(data.problems_data) do
			if problem.code ~= E_SUCCESS then
				error_count = error_count + 1
			end
		end
		local form = metatool.form.Form({
			width = 10,
			height = 8,
		}):raw(
			("label[0.2,0.7;Network validation for %s owned by %s %s]")
			:format(data.network, data.owner, error_count > 0 and "failed" or "passed")
		):table({
			name = "problems", label = "Problems found:",
			y = 2, h = 5,
			columns = {"pos", "station", "net", "owner", "problem"},
			values = data.problems
		}):button({
			label = "Remove invalid", name = "rm_invalid",
			y = 7, h = 0.8, xidx = 1, xcount = 3,
		}):button({
			label = "Remove duplicates", name = "rm_duplicates",
			y = 7, h = 0.8, xidx = 2, xcount = 3,
		}):button({
			label = "Cancel", name = "cancel", exit = true,
			y = 7, h = 0.8, xidx = 3, xcount = 3,
		})
		return form
	end,
	on_receive = function(player, fields, data)
		if fields.rm_invalid and data.problems_data then
			for index, problem in ipairs(data.problems_data) do
				if problem.code == E_NODENAME and problem.netref and problem.station then
					-- Remove stations without valid node from database
					problem.netref[problem.station] = nil
					-- Update problems data, mark problem as fixed
					problem.code = E_SUCCESS
					data.problems[index][5] = "FIXED: invalid node"
				end
			end
			return false
		elseif fields.rm_duplicates and data.problems_data then
			for index, problem in ipairs(data.problems_data) do
				if problem.code == E_DUPLICATE and problem.netref and problem.station then
					-- Remove stations without valid node from database
					problem.netref[problem.station] = nil
					-- Update problems data, mark problem as fixed
					problem.code = E_SUCCESS
					data.problems[index][5] = "FIXED: duplicate station"
				end
			end
			return false
		end
	end,
})

metatool.form.register_form("sharetool:transfer-travelnet", {
	on_create = function(player, data)
		local form = metatool.form.Form({
			width = 8,
			height = 4.5,
		}):raw(
			("label[0.2,0.7;Transfer travelnet ownership at %s owned by %s]")
			:format(metatool.util.pos_to_string(data.pos), data.owner)
		):raw(
			("label[0.2,1.4;Does not mark travelnet as shared]")
			:format(metatool.util.pos_to_string(data.pos), data.owner)
		):field({
			name = "owner", label = "New owner:", default = ns.shared_account,
			x = 1, y = 2.1, w = 3.9, h = 0.8
		}):button({
			label = "Transfer", name = "transfer",
			y = 3.5, h = 0.8, xidx = 1, xcount = 3,
		}):button({
			label = "Validate", name = "validate",
			y = 3.5, h = 0.8, xidx = 2, xcount = 3,
		}):button({
			label = "Cancel", name = "cancel", exit = true,
			y = 3.5, h = 0.8, xidx = 3, xcount = 3,
		})
		return form
	end,
	on_receive = function(player, fields, data)
		if fields.transfer and fields.owner then
			local name = player:get_player_name()
			if not ns.player_exists(fields.owner) then
				minetest.chat_send_player(name, ("Player %s not found, transfer failed"):format(fields.owner or "?"))
				return false
			end
			-- All checks passed, transfer ownership
			if ns:set_travelnet_owner(data.pos, player, fields.owner) then
				minetest.chat_send_player(name,
					("Ownership transfer completed, travelnet is now owned by %s"):format(fields.owner)
				)
			end
		elseif fields.validate then
			local problems = find_problems(data.pos)
			metatool.form.show(player, "sharetool:validate-travelnet", {
				pos = data.pos,
				node = data.node,
				owner = data.owner,
				network = data.network,
				station = data.station,
				problems = problems.problems,
				problems_data = problems.problems_data,
			})
		end
		return true
	end,
})

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
	if ns:can_bypass(pos, player, 'owner') or metatool.before_read(self, pos, player, true) then
		-- Player is allowed to bypass protections or operate in area
		return true
	end
	return false
end

function definition:copy(node, pos, player)
	-- Copy function does not really copy anything here
	-- but instead it will claim ownership of pointed
	-- node and mark it as shared node.

	-- Change ownership to player and mark as shared node
	local success = ns:set_travelnet_owner(pos, player, player:get_player_name())
	if success then
		ns.mark_shared(minetest.get_meta(pos))
	end
	return {
		success = success,
		description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
	}
end

function definition:paste(node, pos, player, data)
	-- Paste function does not really paste anything here
	-- but instead it will restore ownership of pointed
	-- node and mark it as shared node

	-- Change ownership to shared account and mark as shared node
	local success = ns:set_travelnet_owner(pos, player)
	if success then
		ns.mark_shared(minetest.get_meta(pos))
	end
	return {
		success = success,
		description = string.format("Claimed ownership of %s at %s", node.name, minetest.pos_to_string(pos))
	}
end

function definition:info(node, pos, player, itemstack)
	local meta = minetest.get_meta(pos)
	local owner = meta:get("owner")
	local network = meta:get("station_network")
	local station = meta:get("station_name")
	if not owner or not network or not station then
		-- Either metadata is broken or travelnet is not yet configured
		owner, network, station = find_travelnet_from_db(pos)
	end
	if owner and network and station then
		metatool.form.show(player, "sharetool:transfer-travelnet", {
			pos = pos,
			node = node,
			owner = owner,
			network = network,
			station = station,
		})
	else
		minetest.chat_send_player(player:get_player_name(),
			("Station data for %s in network %s owned by %s not found, is this travelnet configured properly?")
			:format(station or "?", network or "?", owner or "?")
		)
	end
end

return definition
