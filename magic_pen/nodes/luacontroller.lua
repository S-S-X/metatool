--
-- Register lua controller and lua tube for Magic pen
--

local o2b_lookup = {
	['0'] = '000',
	['1'] = '001',
	['2'] = '010',
	['3'] = '011',
	['4'] = '100',
	['5'] = '101',
	['6'] = '110',
	['7'] = '111',
}
local o2b = function(o)
	return o:gsub('.', o2b_lookup)
end
local d2b = function(d)
	return o2b(string.format('%o', d))
end
local lpad = function(s, c, n)
	return c:rep(n - #s) .. s
end
local lpadcut = function(s, c, n)
	return lpad(s,c,n):sub(math.max(0, #s - n + 1), #s + 1)
end

local nodes = {}

-- lua controller, 16 different nodes
for i=0,15 do
	table.insert(nodes, "mesecons_luacontroller:luacontroller" .. lpadcut(d2b(i), '0', 4))
end
table.insert(nodes, "mesecons_luacontroller:luacontroller_burnt")

-- lua tubes, 64 different nodes
for i=0,63 do
	table.insert(nodes, "pipeworks:lua_tube" .. lpad(d2b(i), '0', 6))
end
table.insert(nodes, "pipeworks:lua_tube_burnt")

local truncate = metatool.ns('magic_pen').truncate

local function parse_comments(content)
	if type(content) ~= "string" then return end
	local m = content:gmatch("[^\r\n]+")
	local line = m()
	local title, author
	while line and (line:find("^%s*%-%-[%s%p]*[%a%d]") or line:find("^%s*$")) do
		if not title then
			title = truncate(
				line:gmatch("[Dd][Ee][Ss][Cc]%a*[%s]*%p[%s%p]*([%a%d][%a%d%p%s]+)")()
				or line:gmatch("[Tt][Ii][Tt][Ll][Ee][%s]*%p[%s%p]*([%a%d][%a%d%p%s]+)")(), 80)
		end
		if not author then
			author = truncate(line:gmatch("[Aa][Uu][Tt][Hh][Oo][Rr][%s]*%p[%s%p]*([%a%d][%a%d%p%s]+)")(), 80)
		end
		if title and author then break end
		line = m()
	end
	return title, author
end

local definition = {
	name = 'luacontroller',
	nodes = nodes,
	group = 'text',
	protection_bypass_read = "interact",
}

function definition:copy(node, pos, player)
	local meta = minetest.get_meta(pos)
	local content = meta:get_string("code")
	local title, author = parse_comments(content)
	local nicename = minetest.registered_nodes[node.name].description or node.name
	local description = title
		and ("%s: %s"):format(nicename, title)
		or ("%s at %s"):format(nicename, minetest.pos_to_string(pos))
	return {
		description = description,
		content = content,
		title = title,
		source = author,
	}
end
function definition:paste(node, pos, player, data)
	local content = data.content
	local title, author = parse_comments(content)
	if not author and data.source then
		content = ("-- Author: %s\n%s"):format(data.source, content)
	end
	if not title and data.title then
		content = ("-- Description: %s\n%s"):format(data.title, content)
	end
	local fields = {
		program = 1,
		code = content,
	}
	local nodedef = minetest.registered_nodes[node.name]
	nodedef.on_receive_fields(pos, "", fields, player)
end

return definition
