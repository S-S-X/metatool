exclude_files = {
	"**/spec/**",
}

files["**/nodes/*.lua"] = { ignore = {"212"} }

globals = {
	"metatool",
	"travelnet",
}

read_globals = {
	-- Engine
	"minetest",
	"vector",
	"ItemStack",
	"Settings",
	"dump",
	-- Mods
	"default",
	"pipeworks",
	"technic",
	"signs",
	"signs_api",
	"signs_lib",
	"display_api",
}
