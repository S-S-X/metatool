--[[
	Metatool provides API to register tools used for
	manipulating node metadata through copy/paste methods.

	Template configuration file can be generated using default
	settings by setting `export_default_config` to `true`.
	This causes configuration parser to write default configuration
	into file specified by `metatool.configuration_file` key.

	Configuration file is never written by metatool mod unless
	`metatool.export_default_config` is set to `true`.
--]]

-- initialize namespace and core functions
metatool = {
	version_str = "2.0.0",
	version = nil,
	configuration_file = minetest.get_worldpath() .. '/metatool.cfg',
	export_default_config = minetest.settings:get_bool("metatool_export_default_config", true),
	modpath = minetest.get_modpath('metatool'),
	S = string.format
}

local version_matcher = metatool.version_str:gmatch("%d+")
metatool.version = {
	major = tonumber(version_matcher()),
	minor = tonumber(version_matcher()),
	patch = tonumber(version_matcher()),
}
assert(type(metatool.version.major) == "number", "Invalid Metatool version_str major")
assert(type(metatool.version.minor) == "number", "Invalid Metatool version_str minor")
assert(type(metatool.version.patch) == "number", "Invalid Metatool version_str patch")

dofile(metatool.modpath .. '/util.lua')
dofile(metatool.modpath .. '/settings.lua')
dofile(metatool.modpath .. '/api.lua')
dofile(metatool.modpath .. '/command.lua')
dofile(metatool.modpath .. '/formspec.lua')

print('[OK] MetaTool ' .. metatool.version_str .. ' loaded')
