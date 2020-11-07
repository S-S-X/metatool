exclude_files = {
	"**/spec/**",
}

files["**/nodes/*.lua"] = { ignore = {"212"} }

globals = {
	"metatool",
        "travelnet",
}

read_globals = {
	"minetest",
	"default",
	"pipeworks",
	"vector",
	"ItemStack",
	"Settings",
	"dump",
	"signs",
	"signs_api",
	"signs_lib",
	"display_api",
}
