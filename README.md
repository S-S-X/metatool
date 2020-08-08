![luacheck](https://github.com/S-S-X/metatool/workflows/luacheck/badge.svg)
![busted](https://github.com/S-S-X/metatool/workflows/busted/badge.svg)
[![ContentDB](https://content.minetest.net/packages/-SX-/metatool/shields/downloads/)](https://content.minetest.net/packages/-SX-/metatool/)

## What metatool? And why?

Metatool Minetest mod provides API for registering metadata manipulation tools and other tools primarily focused on special node data operations.

## How to use tools

Basic functionality for tools come as two primary functions: copy and paste.

* Special+left click for copy function.
* Left click for paste function.
* Sneak+left click for optional "info" function which might not be available for all nodes.
  If third function is not implemented then sneak+left click triggers copy function.

Privileged tools without recipe will be given by using special `/metatool:give` command.
* `/metatool:give` does not require `give` privs.
* `/metatool:give` without arguments will list tools player can get.
* Each tool can have custom required privilege, for example sharetool requires `ban` by default.

For more complete and tool specific documentation go see README.md files in subdirectories.

* Metatool API [API_REFERENCE.md](API_REFERENCE.md)
* Luatool [luatool/README.md](luatool/README.md)
* Tubetool [tubetool/README.md](tubetool/README.md)
* Sharetool [sharetool/README.md](sharetool/README.md)

## How to add supported nodes for tools

Example to add support for technic:injector

```
local definition = {
	name = "sci",
	nodes = "technic:injector",
	tooldef = {
		group = "technic injector",
		copy = function(node, pos, player)
			-- Get some metadata from injector node and store it within
			-- tool memory and also set new nice description for tool.
			local meta = minetest.get_meta(pos)
			return {
				description = "This wand has some injector data",
				myvalue = meta:get_string("owner")
			}
		end,

		paste = function(node, pos, player, data)
			-- Restore SCI metatdata from tool memory
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", data.myvalue)
		end,
	}
}
```

Supply above definition for tool, mytool variable is returned from metatool:register_tool method

```
mytool:load_node_definition(definition)
```

That's all, now you can use tubetool wand to copy/paste metadata owner value from one injector to another.

## API methods

### Tool API methods (where `mytool` is registered tool)

`mytool:load_node_definition(definition)`

### Tool definition callback methods

Callback `on_read_info(tooldef, player, pointed_thing, node, pos, nodedef)`

Example definition:
```
	on_read_info = function(tooldef, player, pointed_thing, node, pos, nodedef)
		tooldef:info(node, pos, player)
	end,
```

Callback `data, group, description = on_read_node(tooldef, player, pointed_thing, node, pos, nodedef)`

Example definition:
```
	on_read_node = function(tooldef, player, pointed_thing, node, pos, nodedef)
		local data, group = tooldef:copy(node, pos, player)
		local description = type(data) == 'table' and data.description or ('Data from ' .. minetest.pos_to_string(pos))
		return data, group, description
	end,
```

Callback `on_write_node(tooldef, data, group, player, pointed_thing, node, pos, nodedef)`

Example definition:
```
	on_write_node = function(tooldef, data, group, player, pointed_thing, node, pos, nodedef)
		tooldef:paste(node, pos, player, data, group)
	end,
```

### Node definition callback methods (see above technic:injector example)

Callback `data = copy(node, pos, player)`

Example definition:
```
	copy = function(node, pos, player)
		return { description = "new description", myvalue = "any value" }
	end,
```

Callback `paste(node, pos, player, data)`

Example definition:
```
	paste = function(node, pos, player, data)
		print("Used on " .. node.name .. " by " .. player:get_player_name())
	end,
```

Parameter `protection_bypass_info = "privilege1,privilege2"`
Bypass all info protection checks when using tool if player has listed privs.

Parameter `protection_bypass_read = "privilege1,privilege2"`
Bypass all read protection checks when using tool if player has listed privs.

Parameter `protection_bypass_write = { "privilege1,privilege2" }`
Bypass all write protection checks when using tool if player has listed privs.

Callback `allowed = before_info(nodedef, pos, player)`
Executed before node info is called, this method can override all protection checks.
Above protection_bypass_info parameters might not work if this is overridden.

Callback `allowed = before_read(nodedef, pos, player)`
Executed before node reading is called, this method can override all protection checks.
Above protection_bypass_read parameters might not work if this is overridden.

Callback `allowed = before_write(nodedef, pos, player)`
Executed before node reading is called, this method can override all protection checks.
Above protection_bypass_write parameters might not work if this is overridden.

### Metatool API methods (commonly used)

`mytool = metatool:register_tool(name, definition)`

`metatool:register_node(definition)`

### Metatool API methods (for special needs)

`node, pos, nodedef = metatool:get_node(tool, player, pointed_thing)`

`metatool.write_data(itemstack, data, description)`

`data = metatool.read_data = function(itemstack)`

`data = metatool:copy(node, pos, player)`

`metatool:paste(node, pos, player, data, group)`

## Minetest protection checks

Protection checks are done automatically for all tool uses, node registration does not need any protection checks.
By default tools cannot be used to read data from protected nodes and cannot be used to write data to protected nodes.

Tools can override protection settings and also configuration can be used to override default protection behavior.
