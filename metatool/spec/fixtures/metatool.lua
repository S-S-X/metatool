
_G.metatool = {}
_G.metatool.S = string.format
_G.metatool.configuration_file = fixture_path("metatool.cfg")

_G.Settings = function(fname)
	local settings = {
		_data = {},
		set = function(...)end,
		write = function(...)end,
		to_table = function(self)
			local result = {}
			for k,v in pairs(self._data) do
				result[k] = v
			end
			return result
		end,
	}
	file = assert(io.open(fname, "r"))
	for line in file:lines() do
		for key, value in string.gmatch(line, "([^= ]+) *= *(.-)$") do
			settings._data[key] = value
		end
	end
	return settings
end

minetest.register_node("testnode1", {})
minetest.register_node("testnode2", {})
minetest.register_node("testnode3", {})
