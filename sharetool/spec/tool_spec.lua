--[[
	Regression tests for sharetool
--]]
require("mineunit")

mineunit:set_modpath("sharetool", ".")

mineunit("core")
mineunit("player")
mineunit("protection")
mineunit("default/functions")

fixture("metatool")

minetest.register_node(":default:dirt", {})
minetest.register_node(":digiline_global_memory:controller", {})

sourcefile("../metatool/init")
sourcefile("init")

mineunit:mods_loaded()

local TOOL_NAME = "metatool:sharetool"

world.set_node({x=0,y=0,z=0}, "default:dirt")
world.set_node({x=1,y=1,z=1}, "default:dirt")
minetest.get_meta({x=1,y=1,z=1}):set_string("owner", "SX")
world.set_node({x=0,y=1,z=1}, "digiline_global_memory:controller")
minetest.get_meta({x=0,y=1,z=1}):set_string("owner", "SX")

local function get_pointed_thing(pos)
	pos = pos or {x=0,y=0,z=0}
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

local function get_fake_player(privs, controls)
	Player("Sam", privs)
	return {
		get_player_name = function() return "Sam" end,
		get_player_control = function() return controls end,
	}
end

describe("Tool behavior", function()

	describe("use on digiline_global_memory:controller", function()

		it("write with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing({x=0,y=1,z=1})

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

		it("read with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing({x=0,y=1,z=1})

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

		it("info with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing({x=0,y=1,z=1})

			-- Use tool info function with pointed node
			player:_set_player_control_state("sneak", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

	end)

	describe("node write operation", function()

		it("allows using tool with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing()

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

		it("removes tool without privileges", function()
			local player = Player("Sam", { interact = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is empty
			assert.is_ItemStack(return_stack)
			assert.is_true(return_stack:is_empty())
		end)

		it("does not allow fake player to use tool with privileges", function()
			local player = get_fake_player({ ban = true }, {})
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is nil, tool not removed from machine
			assert.is_nil(return_stack)
		end)

		it("does not allow fake player to use tool without privileges", function()
			local player = get_fake_player({ interact = true }, {})
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is nil, tool not removed from machine
			assert.is_nil(return_stack)
		end)

	end)

	describe("node read operation", function()

		it("allows using tool with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

		it("removes tool without privileges", function()
			local player = Player("Sam", { interact = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Verify that returned stack is empty
			assert.is_ItemStack(return_stack)
			assert.is_true(return_stack:is_empty())
		end)

		it("does not allow fake player to use tool with privileges", function()
			local player = get_fake_player({ ban = true }, { aux1 = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is nil, tool not removed from machine
			assert.is_nil(return_stack)
		end)

		it("does not allow fake player to use tool without privileges", function()
			local player = get_fake_player({ interact = true }, { aux1 = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is nil, tool not removed from machine
			assert.is_nil(return_stack)
		end)

	end)

	describe("node info operation", function()

		it("allows using tool with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("sneak", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

		it("removes tool without privileges", function()
			local player = Player("Sam", { interact = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("sneak", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Verify that returned stack is empty
			assert.is_ItemStack(return_stack)
			assert.is_true(return_stack:is_empty())
		end)

		it("does not allow fake player to use tool with privileges", function()
			local player = get_fake_player({ ban = true }, { sneak = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is nil, tool not removed from machine
			assert.is_nil(return_stack)
		end)

		it("does not allow fake player to use tool without privileges", function()
			local player = get_fake_player({ interact = true }, { sneak = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is nil, tool not removed from machine
			assert.is_nil(return_stack)
		end)

	end)

end)
