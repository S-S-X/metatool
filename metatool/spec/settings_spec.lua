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
fixture("metatool")

require("settings")

describe("Metatool settings file loading", function()

	it("Returns top level configuration value", function()
		local value = metatool.settings("metatool:testtool1", "privs")
		assert.same("test_testtool1_privs", value)
	end)

	it("Returns top level configuration value without prefix", function()
		local value = metatool.settings("testtool1", "privs")
		assert.same("test_testtool1_privs", value)
	end)

	it("Returns configuration values as table", function()
		local expected = {
			privs = "test_testtool1_privs",
			shared_account = "test_testtool1_shared_account",
		}
		local value = metatool.settings("testtool1")
		assert.same(expected, value)
	end)

	it("testtool1 configuration as table", function()
		local expected = {
			shared_account = "test_testtool1_shared_account",
			privs = "test_testtool1_privs",
		}
		local value = metatool.settings("testtool1")
		assert.same(expected, value)
	end)

	it("testtool2 configuration as table", function()
		local expected = {
			privs = "test_testtool2_privs",
			extra_config_key = "testtool2_extra_config_value",
			nodes = {
				testnode2 = {
					protection_bypass_write = "testtool2_testnode2_bypass_write",
					protection_bypass_info = "testtool2_testnode2_bypass_info",
					protection_bypass_read = "testtool2_testnode2_bypass_read",
				},
			},
		}
		local value = metatool.settings("testtool2")
		assert.same(expected, value)
	end)

	it("testtool3 configuration as table", function()
		local expected = {
			configuration1 = "testtool3_configuration1_value",
		}
		local value = metatool.settings("testtool3")
		assert.same(expected, value)
	end)

end)

--[[
TODO: Add tests for merge functions

metatool.merge_node_settings = function(toolname, nodename, nodedef)

metatool.merge_tool_settings = function(toolname, tooldef)
--]]
