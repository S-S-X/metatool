--[[
	Metatool provides API to register tools used for
	manipulating node metadata through copy/paste methods.
--]]

-- initialize namespace and core functions
metatool = {
	S = string.format
}
dofile(minetest.get_modpath('metatool') .. '/api.lua')
dofile(minetest.get_modpath('metatool') .. '/command.lua')

print('[OK] MetaTool loaded')
