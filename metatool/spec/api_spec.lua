--[[
	Metatool settings parser unit tests for busted.
	Execute busted at metatool source directory.

	TODO: Add more configuration files for different situations:
		- Only default configuration
		- Configuration only for single tool
		- Metatool core/API configuration
		- No configuration, empty file
		- No configuration, not even empty file
--]]
dofile("spec/mineunit/init.lua")

mineunit("core")
mineunit("player")
mineunit("protection")

fixture("metatool")
sourcefile("util")
sourcefile("settings")
sourcefile("command")
sourcefile("api")

local UnprotectedPos = {x=-123,y=-123,z=-123}
local ProtectedPos = {x=123,y=123,z=123}
mineunit:protect(ProtectedPos, "dummy")

describe("Metatool API protection", function()

	it("metatool.is_protected bypass privileges", function()
		local value = metatool.is_protected(ProtectedPos, Player(), "test_priv", true)
		assert.equals(false, value)
	end)

	it("metatool.is_protected no bypass privileges", function()
		local value = metatool.is_protected(ProtectedPos, Player(), "test_priv2", true)
		assert.equals(true, value)
	end)

	it("metatool.is_protected bypass privileges, unprotected", function()
		local value = metatool.is_protected(UnprotectedPos, Player(), "test_priv", true)
		assert.equals(false, value)
	end)

	it("metatool.is_protected no bypass privileges, unprotected", function()
		local value = metatool.is_protected(UnprotectedPos, Player(), "test_priv2", true)
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
			on_read_node = function(self, player, pointed_thing, node, pos, nodedef)
				local data, group = nodedef:copy(node, pos, player)
				return data, group, "on_read_node description"
			end,
			on_write_node = function(self, data, group, player, pointed_thing, node, pos, nodedef)
				nodedef:paste(node, pos, player, data, group)
			end,
		}
		local tool = metatool:register_tool('testtool0', definition)

		assert.is_table(tool)
		assert.equals("metatool:testtool0", tool.name)

		assert.is_table(tool)
		assert.equals(definition.description, tool.description)
		assert.equals(definition.name, tool.nice_name)
		assert.equals(definition.on_read_node, tool.on_read_node)
		assert.equals(definition.on_write_node, tool.on_write_node)

		-- Test configurable tool attributes
		assert.is_nil(tool.privs)
		assert.same({}, tool.settings)

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
			settings = {
				machine_use_priv = "server"
			},
			on_read_node = function(self, player, pointed_thing, node, pos, nodedef)
				local data, group = nodedef:copy(node, pos, player)
				return data, group, "on_read_node description"
			end,
			on_write_node = function(self, data, group, player, pointed_thing, node, pos, nodedef)
				nodedef:paste(node, pos, player, data, group)
			end,
		}
		local tool = metatool:register_tool('testtool2', definition)

		assert.is_table(tool)
		assert.equals("metatool:testtool2", tool.name)

		assert.is_table(tool)
		assert.equals(definition.description, tool.description)
		assert.equals(definition.name, tool.nice_name)
		assert.equals(definition.on_read_node, tool.on_read_node)
		assert.equals(definition.on_write_node, tool.on_write_node)

		-- Test configurable tool attributes
		assert.equals("test_testtool2_privs", tool.privs)
		local expected_settings = {
			extra_config_key = "testtool2_extra_config_value",
			machine_use_priv = "server",
		}
		assert.same(expected_settings, tool.settings)

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
		assert.is_table(tool)

		local definition = {
			name = 'testnode1',
			nodes = {
				"testnode1",
				"nonexistent1",
				"testnode2",
				"nonexistent2",
			},
			group = 'test node',
			protection_bypass_write = "default_bypass_write_priv",
		}
		function definition:copy(node, pos, player)
			print("nodedef copy callback executed")
		end
		function definition:paste(node, pos, player, data)
			print("nodedef paste callback executed")
		end
		tool:load_node_definition(definition)

		assert.is_table(tool.nodes)
		assert.is_table(tool.nodes.testnode1)
		assert.is_table(tool.nodes.testnode2)
		assert.is_nil(tool.nodes.nonexistent1)
		assert.is_nil(tool.nodes.nonexistent2)

		assert.is_function(tool.nodes.testnode1.before_read)
		assert.is_function(tool.nodes.testnode2.before_write)

		assert.equals(definition.copy, tool.nodes.testnode1.copy)
		assert.equals(definition.paste, tool.nodes.testnode2.paste)
		assert.equals("default_bypass_write_priv", definition.protection_bypass_write)

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
		assert.is_table(tool)

		local definition = {
			name = 'testnode2',
			nodes = {
				"testnode1",
				"nonexistent1",
				"testnode2",
				"nonexistent2",
			},
			group = 'test node 2',
			protection_bypass_write = "default_bypass_write_priv",
		}
		function definition:copy(node, pos, player)
			print("testnode2 copy callback executed")
			local meta = minetest.get_meta(pos)
			local value = meta:get_string("test")
			--assert.equals("node2meta", value)
			return { description = "after copy description", testvalue = value }
		end
		function definition:paste(node, pos, player, data)
			print("testnode2 paste callback executed")
			local meta = minetest.get_meta(pos)
			meta:set_string("test", data.testvalue)
		end
		tool:load_node_definition(definition)

		assert.is_table(tool.nodes)
		assert.is_table(tool.nodes.testnode1)
		assert.is_table(tool.nodes.testnode2)
		assert.is_nil(tool.nodes.nonexistent1)
		assert.is_nil(tool.nodes.nonexistent2)

		assert.is_function(tool.nodes.testnode1.before_read)
		assert.is_function(tool.nodes.testnode2.before_write)

		assert.equals(definition.copy, tool.nodes.testnode1.copy)
		assert.equals(definition.paste, tool.nodes.testnode2.paste)
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

	it("Register node with extended configuration", function()
		local tool = metatool.tool("testtool2")
		assert.is_table(tool)
		assert.equals("metatool:testtool2", tool.name)
		assert.is_table(tool)

		local definition = {
			name = 'testnode3',
			nodes = "testnode3",
			group = 'test node 3',
			protection_bypass_read = "default_bypass_read_priv",
			settings = {
				allow_doing_x = true,
				message_for_y = "test y message",
				boolean_test1 = true,
				boolean_test2 = true,
				boolean_test3 = true,
				number_test1 = 0,
				number_test2 = 0,
			},
		}
		function definition:copy(node, pos, player)
			print("testnode3 copy callback executed")
			local meta = minetest.get_meta(pos)
			return { description = "after copy description", testvalue = meta:get("test") }
		end
		function definition:paste(node, pos, player, data)
			print("testnode3 paste callback executed")
			local meta = minetest.get_meta(pos)
			meta:set_string("test", data.testvalue)
		end
		tool:load_node_definition(definition)

		assert.is_table(tool.nodes)
		assert.is_table(tool.nodes.testnode1)
		assert.is_table(tool.nodes.testnode2)
		assert.is_table(tool.nodes.testnode3)

		assert.is_function(tool.nodes.testnode3.before_read)
		assert.is_function(tool.nodes.testnode3.before_write)

		assert.not_equals(definition.copy, tool.nodes.testnode1.copy)
		assert.equals(definition.copy, tool.nodes.testnode3.copy)
		assert.equals(definition.paste, tool.nodes.testnode3.paste)
		assert.equals("testtool2_testnode2_bypass_write", tool.nodes.testnode1.protection_bypass_write)
		assert.equals("testtool2_testnode2_bypass_write", tool.nodes.testnode2.protection_bypass_write)
		assert.is_nil(tool.nodes.testnode3.protection_bypass_write)
		assert.equals("default_bypass_read_priv", tool.nodes.testnode3.protection_bypass_read)
		assert.equals("default_bypass_read_priv", tool.nodes.testnode3.settings.protection_bypass_read)
		assert.equals(true, tool.nodes.testnode3.settings.allow_doing_x)
		assert.equals("test y message", tool.nodes.testnode3.settings.message_for_y)
		assert.is_nil(tool.nodes.testnode3.message_for_y)

		local expected_settings = {
			protection_bypass_read = "default_bypass_read_priv",
			allow_doing_x = true,
			message_for_y = "test y message",
			boolean_test1 = false,
			boolean_test2 = true,
			boolean_test3 = false,
			number_test1 = 42,
			number_test2 = 0,
		}
		assert.same(expected_settings, tool.nodes.testnode3.settings)

	end)

end)

describe("Tool behavior", function()

	world.layout({
		{{x=123,y=123,z=123}, "testnode1"},
		{{x=123,y=124,z=123}, "testnode1"},
	})
	local worldmeta_node1 = minetest.get_meta({x=123,y=123,z=123})
	local worldmeta_node2 = minetest.get_meta({x=123,y=124,z=123})

	local player = Player("SX", {server=1,test_testtool2_privs=1,test_priv=1})

	describe("node write operation", function()

		it("protects nodes from write", function()
			worldmeta_node1:set_string("test", "node1meta")
			worldmeta_node2:set_string("test", "node2meta")
			local use_stack = ItemStack("metatool:testtool2")
			local count = use_stack:get_count()
			local pointed_thing = {
				type = "node",
				above = {x=123,y=124,z=123}, -- Pointing from above to downwards,
				under = {x=123,y=123,z=123}, -- crosshair at protected node surface
			}
			local out_stack = metatool:on_use("metatool:testtool2", use_stack, player, pointed_thing)
			-- Verify that returned stack is not modified
			assert.equals(true, out_stack == nil or (out_stack == use_stack and count == out_stack:get_count()))
		end)

		it("writes unprotected nodes", function()
			worldmeta_node1:set_string("test", "node1meta")
			worldmeta_node2:set_string("test", "node2meta")
			local use_stack = ItemStack("metatool:testtool2")
			metatool.write_data(use_stack,{data={testvalue="write test"},group="test node"})
			local pointed_thing = {
				type = "node",
				above = {x=123,y=125,z=123}, -- Pointing from above to downwards,
				under = {x=123,y=124,z=123}, -- crosshair at protected node surface
			}
			local out_stack = metatool:on_use("metatool:testtool2", use_stack, player, pointed_thing)
			-- Verify that returned stack is not modified
			assert.equals(true, out_stack == nil or (out_stack == use_stack and count == out_stack:get_count()))
			local meta = use_stack:get_meta()
			assert.not_nil(meta)
			local worldmeta = minetest.get_meta({x=123,y=124,z=123})
			assert.equals("write test", worldmeta:get("test"))
		end)

		it("reads unprotected nodes", function()
			worldmeta_node1:set_string("test", "node1meta")
			worldmeta_node2:set_string("test", "node2meta")
			local use_stack = ItemStack("metatool:testtool2")
			local pointed_thing = {
				type = "node",
				above = {x=123,y=125,z=123}, -- Pointing from above to downwards,
				under = {x=123,y=124,z=123}, -- crosshair at protected node surface
			}

			-- Use tool to copy metadata from pointed node
			player:_set_player_control_state("aux1", true)
			local out_stack = metatool:on_use("metatool:testtool2", use_stack, player, pointed_thing)
			player:_reset_player_controls()

			-- Check results
			assert.not_nil(out_stack)
			assert.equals("on_read_node description", out_stack:get_description("description"))
			local data = out_stack:get_meta():get("data")
			assert.is_string(data)
			data = minetest.deserialize(data)
			assert.is_table(data)
			assert.is_table(data.data)
			assert.equals("node2meta", data.data.testvalue)
			-- TODO: Check if data was written, currently this only verifies no crash
		end)

	end)

end)

--[[
TODO: Add tests for merge functions

metatool.merge_node_settings = function(toolname, nodename, nodedef)

metatool.merge_tool_settings = function(toolname, tooldef)
--]]
