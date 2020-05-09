--[[
	Tubetool allows cloning pipeworks tube settings.
--]]

local basedir = minetest.get_modpath('tubetool')

-- namespace and core functions
dofile(basedir .. '/api.lua')

-- tubetool:wand
dofile(basedir .. '/tool.lua')

-- nodes
dofile(basedir .. '/nodes/mese_tube.lua')
--dofile(basedir .. '/nodes/teleport_tube.lua')
--dofile(basedir .. '/nodes/sand_tube.lua')
--dofile(basedir .. '/nodes/injector.lua')

print('[tubetool] loaded')
