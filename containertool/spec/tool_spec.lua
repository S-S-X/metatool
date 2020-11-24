--[[
	Regression tests for container tool
--]]
dofile("../spec/mineunit/init.lua")

mineunit:set_modpath("containertool", ".")

mineunit("core")
mineunit("player")
mineunit("protection")
mineunit("default/functions")

_G.S = _G.S or function(s) return s end

fixture("metatool")
fixture("technic")
fixture("nodes")

sourcefile("../metatool/init")
sourcefile("init")

mineunit:mods_loaded()

local TOOL_NAME = "metatool:containertool"

local P = {
	protected_chest      = {x=0, y=0, z=0},
	unprotected_chest    = {x=0, y=1, z=0},
	protected_injector   = {x=0, y=2, z=0},
	unprotected_injector = {x=0, y=3, z=0},
	owned_chest          = {x=0, y=4, z=0},
}

world.layout({
	{P.protected_chest,      "technic:test_chest"},
	{P.unprotected_chest,    "technic:test_chest"},
	{P.protected_injector,   "technic:injector"},
	{P.unprotected_injector, "technic:injector"},
	{P.owned_chest,          "technic:test_chest"},
})
mineunit:protect(P.protected_chest, "dummy")
mineunit:protect(P.protected_injector, "dummy")

local player = Player("SX", {interact=1})
local player2 = Player("dummy", {interact=1})

local function get_pointed_thing(pos)
	return {
		type = "node",
		above = {x=pos.x,y=pos.y+1,z=pos.z}, -- Pointing from above to downwards,
		under = {x=pos.x,y=pos.y,z=pos.z}, -- crosshair at protected node surface
	}
end

local function get_tool_itemstack(name, data)
	local stack = ItemStack(name)
	if data then
		metatool.write_data(stack, data)
	end
	return stack
end

describe("Tool behavior", function()

	local tooldata
	before_each(function()
		local worldmeta_node0 = minetest.get_meta(P.protected_chest)
		worldmeta_node0:set_string("owner", "dummy")
		worldmeta_node0:set_string("mineunit_test_meta", "not changed 0")
		worldmeta_node0:set_string("key_lock_secret", "key_lock_secret 0")
		worldmeta_node0:set_int("splitstacks", 100)
		local worldmeta_node1 = minetest.get_meta(P.unprotected_chest)
		worldmeta_node1:set_string("owner", "SX")
		worldmeta_node1:set_string("mineunit_test_meta", "not changed 1")
		worldmeta_node1:set_string("key_lock_secret", "key_lock_secret 1")
		worldmeta_node1:set_int("splitstacks", 101)
		local worldmeta_node2 = minetest.get_meta(P.protected_injector)
		worldmeta_node2:set_string("owner", "dummy")
		worldmeta_node2:set_string("mineunit_test_meta", "not changed 2")
		worldmeta_node2:set_int("splitstacks", 102)
		local worldmeta_node3 = minetest.get_meta(P.unprotected_injector)
		worldmeta_node3:set_string("owner", "SX")
		worldmeta_node3:set_string("mineunit_test_meta", "not changed 3")
		worldmeta_node3:set_int("splitstacks", 103)
		local worldmeta_node4 = minetest.get_meta(P.owned_chest)
		worldmeta_node4:set_string("owner", "dummy")
		worldmeta_node4:set_string("mineunit_test_meta", "not changed 4")
		worldmeta_node4:set_string("key_lock_secret", "key_lock_secret 4")
		worldmeta_node4:set_int("splitstacks", 104)
		tooldata = {
			data = {
				key_lock_secret = "test value",
				splitstacks = 42
			},
			group="container"
		}
	end)

	describe("node write operation", function()

		it("protects nodes from write", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME, tooldata)
			local count = tool_stack:get_count()
			local target = table.copy(P.protected_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is not modified
			assert.equals(true, return_stack == nil or (return_stack == tool_stack and count == return_stack:get_count()))

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 0", worldmeta:get("mineunit_test_meta"))
			assert.equals("key_lock_secret 0", worldmeta:get("key_lock_secret"))
			assert.equals(100, worldmeta:get_int("splitstacks"))
		end)

		it("writes unprotected nodes", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME, tooldata)
			local count = tool_stack:get_count()
			local target = table.copy(P.unprotected_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is not modified
			assert.equals(true, return_stack == nil or (return_stack == tool_stack and count == return_stack:get_count()))
			local meta = tool_stack:get_meta()
			assert.not_nil(meta)

			-- Check if world metadata was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 1", worldmeta:get("mineunit_test_meta"))
			assert.equals("test value", worldmeta:get("key_lock_secret"))
			assert.equals(42, worldmeta:get_int("splitstacks"))
		end)

		it("protects owned nodes from write", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME, tooldata)
			local count = tool_stack:get_count()
			local target = table.copy(P.owned_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is not modified
			assert.equals(true, return_stack == nil or (return_stack == tool_stack and count == return_stack:get_count()))

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 4", worldmeta:get("mineunit_test_meta"))
			assert.equals("key_lock_secret 4", worldmeta:get("key_lock_secret"))
			assert.equals(104, worldmeta:get_int("splitstacks"))
		end)

		it("writes owned nodes", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME, tooldata)
			local count = tool_stack:get_count()
			local target = table.copy(P.owned_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player2, pointed_thing)

			-- Verify that returned stack is not modified
			assert.equals(true, return_stack == nil or (return_stack == tool_stack and count == return_stack:get_count()))

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 4", worldmeta:get("mineunit_test_meta"))
			assert.equals("test value", worldmeta:get("key_lock_secret"))
			assert.equals(42, worldmeta:get_int("splitstacks"))
		end)

	end)

	describe("node read operation", function()

		it("reads protected nodes", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local target = table.copy(P.protected_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Check returned tool stack
			assert.not_nil(return_stack)
			assert.equals("Technic chest at (0,0,0)", return_stack:get_description())

			-- Check tool data
			local data = return_stack:get_meta():get("data")
			assert.is_string(data)
			data = minetest.deserialize(data)
			assert.is_table(data)
			assert.is_table(data.data)
			-- Protected value
			assert.is_nil(data.data.key_lock_secret)
			-- Unprotected values
			assert.equals("dummy", data.data.owner)
			assert.equals(100, data.data.splitstacks)

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 0", worldmeta:get("mineunit_test_meta"))
			assert.equals("key_lock_secret 0", worldmeta:get("key_lock_secret"))
			assert.equals(100, worldmeta:get_int("splitstacks"))
		end)

		it("reads protected common_defaults nodes", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local target = table.copy(P.protected_injector)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Check returned tool stack
			assert.not_nil(return_stack)
			assert.equals("Self-Contained Injector at (0,2,0)", return_stack:get_description())

			-- Check tool data
			local data = return_stack:get_meta():get("data")
			assert.is_string(data)
			data = minetest.deserialize(data)
			assert.is_table(data)
			assert.is_table(data.data)
			-- Protected value
			assert.is_nil(data.data.key_lock_secret)
			-- Unprotected values
			assert.equals("dummy", data.data.owner)
			assert.equals(102, data.data.splitstacks)

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 2", worldmeta:get("mineunit_test_meta"))
			assert.is_nil(worldmeta:get("key_lock_secret"))
			assert.equals(102, worldmeta:get_int("splitstacks"))
		end)

		it("reads unprotected nodes", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local target = table.copy(P.unprotected_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Check returned tool stack
			assert.not_nil(return_stack)
			assert.equals("Technic chest at (0,1,0)", return_stack:get_description())

			-- Check tool data
			local data = return_stack:get_meta():get("data")
			assert.is_string(data)
			data = minetest.deserialize(data)
			assert.is_table(data)
			assert.is_table(data.data)
			assert.equals("key_lock_secret 1", data.data.key_lock_secret)
			assert.equals(101, data.data.splitstacks)

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 1", worldmeta:get("mineunit_test_meta"))
			assert.equals("key_lock_secret 1", worldmeta:get("key_lock_secret"))
			assert.equals(101, worldmeta:get_int("splitstacks"))
		end)

		it("reads unprotected common_defaults nodes", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local target = table.copy(P.unprotected_injector)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Check returned tool stack
			assert.not_nil(return_stack)
			assert.equals("Self-Contained Injector at (0,3,0)", return_stack:get_description())

			-- Check tool data
			local data = return_stack:get_meta():get("data")
			assert.is_string(data)
			data = minetest.deserialize(data)
			assert.is_table(data)
			assert.is_table(data.data)
			assert.is_nil(data.data.key_lock_secret)
			assert.equals(103, data.data.splitstacks)

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 3", worldmeta:get("mineunit_test_meta"))
			assert.is_nil(worldmeta:get("key_lock_secret"))
			assert.equals(103, worldmeta:get_int("splitstacks"))
		end)

		it("reads owned nodes protecting private data", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local target = table.copy(P.owned_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Check returned tool stack
			assert.not_nil(return_stack)
			assert.equals("Technic chest at (0,4,0)", return_stack:get_description())

			-- Check tool data
			local data = return_stack:get_meta():get("data")
			assert.is_string(data)
			data = minetest.deserialize(data)
			assert.is_table(data)
			assert.is_table(data.data)
			-- Protected value
			assert.is_nil(data.data.key_lock_secret)
			-- Unprotected values
			assert.equals("dummy", data.data.owner)
			assert.equals(104, data.data.splitstacks)

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 4", worldmeta:get("mineunit_test_meta"))
			assert.equals("key_lock_secret 4", worldmeta:get("key_lock_secret"))
			assert.equals(104, worldmeta:get_int("splitstacks"))
		end)

		it("reads owned nodes", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local target = table.copy(P.owned_chest)
			local pointed_thing = get_pointed_thing(target)

			-- Use tool to copy metadata from pointed node
			player2:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player2, pointed_thing)
			player2:_reset_player_controls()

			-- Check returned tool stack
			assert.not_nil(return_stack)
			assert.equals("Technic chest at (0,4,0)", return_stack:get_description())

			-- Check tool data
			local data = return_stack:get_meta():get("data")
			assert.is_string(data)
			data = minetest.deserialize(data)
			assert.is_table(data)
			assert.is_table(data.data)
			-- Unprotected values
			assert.equals("key_lock_secret 4", data.data.key_lock_secret)
			assert.equals("dummy", data.data.owner)
			assert.equals(104, data.data.splitstacks)

			-- Check if world metada was written
			local worldmeta = minetest.get_meta(target)
			assert.equals("not changed 4", worldmeta:get("mineunit_test_meta"))
			assert.equals("key_lock_secret 4", worldmeta:get("key_lock_secret"))
			assert.equals(104, worldmeta:get_int("splitstacks"))
		end)

	end)

end)
