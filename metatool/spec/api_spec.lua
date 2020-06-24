--[[
	Metatool settings parser unit tests for busted.
	Execute busted at metatool source directory.

	TODO: Add more configuration files for different situations:
		- Only default configuration
		- Configuration only for single tool
		- Metatool core/API configuration
		- No configuration (empty file)
		- No configuration file at, not even empty file
--]]

dofile("spec/test_helpers.lua")
fixture("minetest")
fixture("minetest/player")
fixture("minetest/protection")
fixture("metatool")

require("api")

describe("Metatool API protection", function()

	it("metatool.is_protected bypass privileges", function()
		local value = metatool.is_protected(ProtectedPos(), Player(), "test_priv", true)
		assert.equals(false, value)
	end)

	it("metatool.is_protected no bypass privileges", function()
		local value = metatool.is_protected(ProtectedPos(), Player(), "test_priv2", true)
		assert.equals(true, value)
	end)

	it("metatool.is_protected bypass privileges, unprotected", function()
		local value = metatool.is_protected(UnprotectedPos(), Player(), "test_priv", true)
		assert.equals(false, value)
	end)

	it("metatool.is_protected no bypass privileges, unprotected", function()
		local value = metatool.is_protected(UnprotectedPos(), Player(), "test_priv2", true)
		assert.equals(false, value)
	end)

end)

describe("Metatool API tool namespace", function()

	it("Create invalid namespace", function()
		local tool = { ns = metatool.ns }
		local value = tool:ns("invalid", {
			testkey = "testvalue"
		})
		assert.is_nil(expected, metatool:ns("testns"))
	end)

	it("Get nonexistent namespace", function()
		assert.is_nil(metatool.ns("nonexistent"))
	end)

	it("Create tool namespace", function()
		-- FIXME: Hack to get fake tool available, replace with real tool
		local tool = { ns = metatool.ns }
		metatool.tools["metatool:mytool"] = tool
		-- Actual tests
		local value = tool:ns({
			testkey = "testvalue"
		})
		local expected = {
			testkey = "testvalue"
		}
		assert.same(expected, metatool.ns("mytool"))
	end)

end)

--[[
TODO: Add tests for merge functions

metatool.merge_node_settings = function(toolname, nodename, nodedef)

metatool.merge_tool_settings = function(toolname, tooldef)
--]]
