--[[
	Metatool settings parser, should be loaded
	before initializing any other functionality.
--]]

local S = metatool.S

local settings = Settings(metatool.configuration_file)

local settings_data = settings:to_table()

local parsed_settings = {}

-- Parse tool specific configuration keys
local parsekey = function(key)
	local parts = key:gsub('\\s',''):split(':')
	if #parts == 2 then
		-- Core API settings metatool:settingname
		return parts[1], parts[2]
	end
	-- Tool settings metatool:whatevertool:settingname
	return parts[1] .. ':' .. parts[2], parts[3]
end

-- Build tool specific configuration keys
local makekey = function(toolname, key)
	return string.format('%s:%s', toolname, key)
end

local get_toolname = function(name)
	local parts = name:gsub('\\s',''):split(':')
	if #parts < 1 or #parts > 2 then
		return
	end
	return 'metatool:' .. parts[#parts]
end

-- Parse settings to table structure where settings for metatool API
-- and settings for registered tools stay isolated from each other.
for rawkey, value in pairs(settings_data) do
	local toolname, key = parsekey(rawkey)
	if not parsed_settings[toolname] then
		parsed_settings[toolname] = {}
	end
	parsed_settings[toolname][key] = value
end

metatool.settings = function(toolname, key)
	-- TODO: Make copy of settings table before returning to protect against modification.
	-- Settings are intended to be read only.
	-- Return nil if key does not exist and return whole settings table if key is nil.
	local name = get_toolname(toolname)

	if parsed_settings[name] then
		if key then
			return parsed_settings[name][key]
		end
		return parsed_settings[name]
	end
end

metatool.merge_tool_settings = function(toolname, tooldef)
	-- Merges default setting values for tool using tooldef.settings table.
	-- Should be called once during tool registration, assuming settings_data is kept
	-- unchanged multiple calls wont do anything useful as settings are already merged.
	local name = get_toolname(toolname)
	print(S('metatool.merge_tool_settings merging settings for tool %s', name))

	if parsed_settings[name]  == nil then
		-- No settings loaded for this tool, create empty settings table:
		parsed_settings[name] = {}
	end

	if type(tooldef.settings) == 'table' then
		-- Merge default tool settings
		for key, value in pairs(tooldef.settings) do
			-- Key is not set, get default value from tooldef.settings
			if parsed_settings[name][key] == nil then
				parsed_settings[name][key] = value
				-- Export default configuration to settings file
				if metatool.export_default_config then
					settings:set(makekey(name, key), value)
				end
			end
		end
	end
	tooldef.settings = parsed_settings[name]
	if metatool.export_default_config then
		settings:write()
	end
end
