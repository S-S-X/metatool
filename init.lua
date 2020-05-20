--[[
	Tubetool allows cloning pipeworks tube settings.
--]]

-- initialize namespace and core functions
dofile(minetest.get_modpath('metatool') .. '/api.lua')
local function tool(name) dofile(string.format('%s/tools/%s.lua', metatool.basedir, name)) end

--
-- Load tools provided by metatool mod using tool('toolname') function.
-- 
-- For externally defined tools use API method metatool:register_tool(...) directly.
--

-- tubetool:wand
tool('tubetool')

print('[OK] MetaTool loaded')
