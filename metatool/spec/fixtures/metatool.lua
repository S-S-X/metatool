
mineunit:set_modpath("metatool", "../metatool")

_G.metatool = {}
_G.metatool.S = string.format
_G.metatool.configuration_file = fixture_path("metatool.cfg")

minetest.register_node(":testnode1", {})
minetest.register_node(":testnode2", {})
minetest.register_node(":testnode3", {})
