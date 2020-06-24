
_G.core = {}
_G.minetest = {}

fixture("minetest/misc_helpers")

_G.minetest.registered_nodes = {}

_G.minetest.chat_send_player = function(name, text)
	-- TODO: Collect chat messages so that those can be included in tests
end

_G.minetest.register_craftitem = function(...)
	-- noop
end

_G.minetest.register_craft = function(...)
	-- noop
end

_G.minetest.item_drop = function(...)
	-- noop
end

_G.minetest.get_pointed_thing_position = function(pointed_thing)
	return { x = 123, y = 123, z = 123 }
end
