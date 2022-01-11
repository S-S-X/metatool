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
fixture("pipeworks")

sourcefile("../metatool/init")
sourcefile("init")

mineunit:mods_loaded()

local TOOL_NAME = "metatool:tubetool"

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

describe("Tool helper methods", function()

	local ns = metatool.ns("tubetool")

	describe("explode_teleport_tube_channel", function()

		local function test_explode(channel, expect_owner, expect_mode, expect_channel)
			local owner, mode, channel = ns.explode_teleport_tube_channel(channel)
			assert.equals(expect_owner, owner)
			assert.equals(expect_mode, mode)
			assert.equals(expect_channel, channel)
		end

		it("considers foo: as owned",    function() test_explode("foo:",    "foo", ":", "") end)
		it("considers foo; as owned",    function() test_explode("foo;",    "foo", ";", "") end)
		it("considers foo:: as owned",   function() test_explode("foo::",   "foo", ":", ":") end)
		it("considers foo;; as owned",   function() test_explode("foo;;",   "foo", ";", ";") end)
		it("considers foo:bar as owned", function() test_explode("foo:bar", "foo", ":", "bar") end)
		it("considers foo;bar as owned", function() test_explode("foo;bar", "foo", ";", "bar") end)
		it("considers foo as public",    function() test_explode("foo",     nil,   nil, "foo") end)
		it("considers :foo as public",   function() test_explode(":foo",    nil,   nil, ":foo") end)
		it("considers ;foo as public",   function() test_explode(";foo",    nil,   nil, ";foo") end)
		it("considers ;:foo as public",  function() test_explode(";:foo",   nil,   nil, ";:foo") end)
		it("considers ;;foo as public",  function() test_explode(";;foo",   nil,   nil, ";;foo") end)
		it("considers : as public",      function() test_explode(":",       nil,   nil, ":") end)
		it("considers ; as public",      function() test_explode(";",       nil,   nil, ";") end)
		it("considers ;: as public",     function() test_explode(";:",      nil,   nil, ";:") end)
		it("considers ;; as public",     function() test_explode(";;",      nil,   nil, ";;") end)

	end)

	describe("allow_teleport_tube_info", function()

		local p1 = Player("p1", {})
		local p2 = Player("p2", { interact = true })
		local p3 = Player("p3", { interact = true, protection_bypass = true })

		local function test_allow(player, channel, expect_result)
			local result = ns.allow_teleport_tube_info(player, channel)
			assert.equals(expect_result, result)
		end

		it("allows public for p1",       function() test_allow(p1, "pubch", true) end)
		it("allows public for p2",       function() test_allow(p2, "pubch", true) end)
		it("allows public for p3",       function() test_allow(p3, "pubch", true) end)

		it("allows receiver for owner",  function() test_allow(p1, "p1;ch", true) end)
		it("allows receiver for others", function() test_allow(p2, "p1;ch", true) end)
		it("allows receiver for bypass", function() test_allow(p3, "p1;ch", true) end)

		it("allows private for owner",   function() test_allow(p1, "p1:ch", true) end)
		it("denies private for others",  function() test_allow(p2, "p1:ch", false) end)
		it("allows private for bypass",  function() test_allow(p3, "p1:ch", true) end)

	end)

	describe("get_teleport_tubes", function()

		it("returns 0 tubes", function()
			local tubes = ns.get_teleport_tubes("nonexistent", {x=3,y=1,z=1})
			assert.equals(0, #tubes)
		end)

		it("returns 1 tubes", function()
			local tubes = ns.get_teleport_tubes("SX:private", {x=3,y=1,z=1})
			assert.equals(1, #tubes)
		end)

		it("returns 3 tubes", function()
			local tubes = ns.get_teleport_tubes("public", {x=3,y=1,z=1})
			assert.equals(3, #tubes)
		end)

	end)

end)

describe("Tool behavior", function()

	describe("use on teleport tube", function()

		it("write with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing({x=1,y=1,z=1})

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
			local pointed_thing = get_pointed_thing({x=1,y=1,z=1})

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
			local pointed_thing = get_pointed_thing({x=0,y=0,z=0})

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
			local pointed_thing = get_pointed_thing({x=2,y=1,z=1})

			-- Use tool to write metadata
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, pointed_thing)

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

	end)

	describe("node read operation", function()

		it("allows using tool with privileges", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()
			local pointed_thing = get_pointed_thing({x=2,y=1,z=1})

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

	end)

	describe("teleport tube info operation", function()

		it("copy channel and display formspec for stored channel", function()
			local player = Player("Sam", { ban = true })
			local tool_stack = get_tool_itemstack(TOOL_NAME)
			local count = tool_stack:get_count()

			-- Use tool to copy metadata from pointed node
			spy.on(metatool.form, "show")
			player:_set_player_control_state("aux1", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, get_pointed_thing({x=2,y=1,z=1}))
			player:_reset_player_controls()
			assert.spy(metatool.form.show).called(0)

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("sneak", true)
			local return_stack = metatool:on_use(TOOL_NAME, tool_stack, player, get_pointed_thing({x=0,y=0,z=0}))
			player:_reset_player_controls()
			assert.spy(metatool.form.show).called(1)

			-- Verify that returned stack is not modified
			if return_stack ~= nil then
				assert.is_ItemStack(return_stack)
				assert.equals(count, return_stack:get_count())
				assert.equals(TOOL_NAME, return_stack:get_name())
			end
		end)

	end)

end)
