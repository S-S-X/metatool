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

package.path = "../?.lua;spec/fixtures/?.lua;spec/helpers/?.lua;" .. package.path

require("settings_globals")
require("misc_helpers")
require("settings")

describe("metatool_settings", function()

	it("Returns top level configuration value", function()
		local value = metatool.settings("metatool:sharetool", "privs")
		assert.same("test_sharetool_privs", value)
	end)

	it("Returns top level configuration value without prefix", function()
		local value = metatool.settings("sharetool", "privs")
		assert.same("test_sharetool_privs", value)
	end)

	it("Returns configuration values as table", function()
		local expected = {
			privs = "test_sharetool_privs",
			shared_account = "test_sharetool_shared_account",
		}
		local value = metatool.settings("sharetool")
		assert.same(expected, value)
	end)

	it("sharetool configuration as table", function()
		local expected = {
			shared_account = "test_sharetool_shared_account",
			privs = "test_sharetool_privs",
		}
		local value = metatool.settings("sharetool")
		assert.same(expected, value)
	end)

	it("tubetool configuration as table", function()
		local expected = {
			privs = "test_tubetool_privs",
			extra_config_key = "tubetool_extra_config_value",
			nodes = {
				mese_tube = {
					protection_bypass_write = "tubetool_mese_tube_bypass_write",
					protection_bypass_info = "tubetool_mese_tube_bypass_info",
					protection_bypass_read = "tubetool_mese_tube_bypass_read",
				},
			},
		}
		local value = metatool.settings("tubetool")
		assert.same(expected, value)
	end)

	it("luatool configuration as table", function()
		local expected = {
			configuration1 = "luatool_configuration1_value",
		}
		local value = metatool.settings("luatool")
		assert.same(expected, value)
	end)

end)

--[[
TODO: Add tests for merge functions

metatool.merge_node_settings = function(toolname, nodename, nodedef)

metatool.merge_tool_settings = function(toolname, tooldef)
--]]
