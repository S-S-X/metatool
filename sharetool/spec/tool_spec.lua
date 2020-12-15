--[[
	Regression tests for sharetool
--]]
dofile("../metatool/spec/mineunit/init.lua")

mineunit:set_modpath("sharetool", ".")

mineunit("core")
mineunit("player")
mineunit("protection")
mineunit("default/functions")

fixture("metatool")

sourcefile("../metatool/init")
sourcefile("init")

mineunit:mods_loaded()

local TOOL_NAME = "metatool:sharetool"

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

describe("Tool behavior", function()

	local tooldata

	describe("node write operation", function()

		it("does not crash", function()
			local tool_stack = get_tool_itemstack(TOOL_NAME, tooldata)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing()

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is not modified
			assert.equals(true, return_stack == nil or (return_stack == tool_stack and count == return_stack:get_count()))
		end)

	end)

	describe("node read operation", function()

		it("does not crash", function()
			local player = Player()
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local pointed_thing = get_pointed_thing()

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Verify that returned stack is not modified
			assert.equals(true, return_stack == nil or (return_stack == tool_stack and count == return_stack:get_count()))
		end)

	end)

end)
