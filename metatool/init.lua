--[[
	Metatool provides API to register tools used for
	manipulating node metadata through copy/paste methods.
--]]

-- initialize namespace and core functions
metatool = {
	configuration_file = minetest.get_worldpath() .. '/metatool.cfg',
	export_default_config = false,
	modpath = minetest.get_modpath('metatool'),
	S = string.format
}
dofile(metatool.modpath .. '/settings.lua')
dofile(metatool.modpath .. '/api.lua')
dofile(metatool.modpath .. '/command.lua')

print('[OK] MetaTool loaded')
