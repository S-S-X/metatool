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

require("settings")
require("command")
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
		local tool = { ns = metatool.ns, name = 'invalid' }
		local value = tool:ns("invalid", {
			testkey = "testvalue"
		})
		assert.is_nil(metatool:ns("testns"))
	end)

	it("Get nonexistent namespace", function()
		assert.is_nil(metatool.ns("nonexistent"))
	end)

	it("Create tool namespace", function()
		-- FIXME: Hack to get fake tool available, replace with real tool
		local tool = { ns = metatool.ns, name = 'mytool' }
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

describe("Metatool API tool registration", function()

	it("Register tool default configuration", function()
		-- Tool registration
		local definition = {
			description = 'UnitTestTool Description',
			name = 'UnitTestTool',
			texture = 'utt.png',
			recipe = {{'air'},{'air'},{'air'}},
			on_read_node = function(tooldef, player, pointed_thing, node, pos)
				local data, group = tooldef:copy(node, pos, player)
				return data, group, "on_read_node description"
			end,
			on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos)
				tooldef:paste(node, pos, player, data, group)
			end,
		}
		local tool = metatool:register_tool('testtool0', definition)

		assert.is_table(tool)
		assert.equals("metatool:testtool0", tool.name)

		assert.is_table(tool.itemdef)
		assert.equals(definition.description, tool.itemdef.description)
		assert.equals(definition.name, tool.itemdef.name)
		assert.equals(definition.on_read_node, tool.itemdef.on_read_node)
		assert.equals(definition.on_write_node, tool.itemdef.on_write_node)

		-- Test configurable tool attributes
		assert.is_nil(tool.itemdef.privs)
		assert.same({}, tool.itemdef.settings)

		-- Namespace creation
		local mult = function(a,b) return a * b end
		tool:ns({ k1 = "v1", fn = mult })

		-- Retrieve namespace and and execute tests
		local ns = metatool.ns("testtool0")
		assert.same({ k1 = "v1", fn = mult }, ns)
		assert.equals(8, ns.fn(2,4))
	end)

	it("Register tool with configuration", function()
		-- Tool registration
		local definition = {
			description = 'UnitTestTool Description',
			name = 'UnitTestTool',
			texture = 'utt.png',
			recipe = {{'air'},{'air'},{'air'}},
			on_read_node = function(tooldef, player, pointed_thing, node, pos)
				local data, group = tooldef:copy(node, pos, player)
				return data, group, "on_read_node description"
			end,
			on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos)
				tooldef:paste(node, pos, player, data, group)
			end,
		}
		local tool = metatool:register_tool('testtool2', definition)

		assert.is_table(tool)
		assert.equals("metatool:testtool2", tool.name)

		assert.is_table(tool.itemdef)
		assert.equals(definition.description, tool.itemdef.description)
		assert.equals(definition.name, tool.itemdef.name)
		assert.equals(definition.on_read_node, tool.itemdef.on_read_node)
		assert.equals(definition.on_write_node, tool.itemdef.on_write_node)

		-- Test configurable tool attributes
		assert.equals("test_testtool2_privs", tool.itemdef.privs)
		local expected_settings = {
			extra_config_key = "testtool2_extra_config_value",
		}
		assert.same(expected_settings, tool.itemdef.settings)

		-- Namespace creation
		local sum = function(a,b) return a + b end
		tool:ns({ k1 = "v1", fn = sum })

		-- Retrieve namespace and and execute tests
		local ns = metatool.ns("testtool2")
		assert.same({ k1 = "v1", fn = sum }, ns)
		assert.equals(9, ns.fn(2,7))
	end)

end)

describe("Metatool API node registration", function()

	it("Register node default configuration", function()
		local tool = metatool.tool("testtool0")
		assert.is_table(tool)
		assert.equals("metatool:testtool0", tool.name)
		assert.is_table(tool.itemdef)

		local definition = {
			name = 'testnode1',
			nodes = {
				"testnode1",
				"nonexistent1",
				"testnode2",
				"nonexistent2",
			},
			tooldef = {
				group = 'test node',
				protection_bypass_write = "default_bypass_write_priv",
				copy = function(node, pos, player)
					print("nodedef copy callback executed")
				end,
				paste = function(node, pos, player, data)
					print("nodedef paste callback executed")
				end,
			}
		}
		tool:load_node_definition(definition)

		assert.is_table(tool.nodes)
		assert.is_table(tool.nodes.testnode1)
		assert.is_table(tool.nodes.testnode2)
		assert.is_nil(tool.nodes.nonexistent1)
		assert.is_nil(tool.nodes.nonexistent2)

		assert.is_function(tool.nodes.testnode1.before_read)
		assert.is_function(tool.nodes.testnode2.before_write)

		assert.equals(definition.tooldef.copy, tool.nodes.testnode1.copy)
		assert.equals(definition.tooldef.paste, tool.nodes.testnode2.paste)
		assert.equals("default_bypass_write_priv", definition.tooldef.protection_bypass_write)

		local expected_settings = {
			protection_bypass_write = "default_bypass_write_priv"
		}
		assert.same(expected_settings, tool.nodes.testnode1.settings)
		assert.same(expected_settings, tool.nodes.testnode2.settings)

	end)

	it("Register node with configuration", function()
		local tool = metatool.tool("testtool2")
		assert.is_table(tool)
		assert.equals("metatool:testtool2", tool.name)
		assert.is_table(tool.itemdef)

		local definition = {
			name = 'testnode2',
			nodes = {
				"testnode1",
				"nonexistent1",
				"testnode2",
				"nonexistent2",
			},
			tooldef = {
				group = 'test node',
				protection_bypass_write = "default_bypass_write_priv",
				copy = function(node, pos, player)
					print("nodedef copy callback executed")
				end,
				paste = function(node, pos, player, data)
					print("nodedef paste callback executed")
				end,
			}
		}
		tool:load_node_definition(definition)

		assert.is_table(tool.nodes)
		assert.is_table(tool.nodes.testnode1)
		assert.is_table(tool.nodes.testnode2)
		assert.is_nil(tool.nodes.nonexistent1)
		assert.is_nil(tool.nodes.nonexistent2)

		assert.is_function(tool.nodes.testnode1.before_read)
		assert.is_function(tool.nodes.testnode2.before_write)

		assert.equals(definition.tooldef.copy, tool.nodes.testnode1.copy)
		assert.equals(definition.tooldef.paste, tool.nodes.testnode2.paste)
		assert.equals("testtool2_testnode2_bypass_write", tool.nodes.testnode1.protection_bypass_write)
		assert.equals("testtool2_testnode2_bypass_write", tool.nodes.testnode2.protection_bypass_write)
		assert.equals("testtool2_testnode2_bypass_info", tool.nodes.testnode1.protection_bypass_info)
		assert.equals("testtool2_testnode2_bypass_info", tool.nodes.testnode2.protection_bypass_info)
		assert.equals("testtool2_testnode2_bypass_read", tool.nodes.testnode1.protection_bypass_read)
		assert.equals("testtool2_testnode2_bypass_read", tool.nodes.testnode2.protection_bypass_read)

		local expected_settings = {
			protection_bypass_write = "testtool2_testnode2_bypass_write",
			protection_bypass_info = "testtool2_testnode2_bypass_info",
			protection_bypass_read = "testtool2_testnode2_bypass_read",
		}
		assert.same(expected_settings, tool.nodes.testnode1.settings)
		assert.same(expected_settings, tool.nodes.testnode2.settings)

	end)

end)

--[[
TODO: Add tests for merge functions

metatool.merge_node_settings = function(toolname, nodename, nodedef)

metatool.merge_tool_settings = function(toolname, tooldef)
--]]
