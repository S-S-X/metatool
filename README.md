## What metatool? And why?

Metatool Minetest mod provides API for registering metadata manipulation tools and other tools primarily focused on special node data operations.

## How to use metatool:tubetool

Tubetool is made available for cloning pipeworks node configurations like sorting tube configuration.
Other registered metatool tools might work in similar way allowing to copy data from one node to another.

#### Copy configuration from pipeworks node

Hold wand in your hand and point node that you want to copy configuration from, hold special or sneak button and left click on node to copy settings.
Chat will display confirmation message when configuration is copied to wand.

#### Apply copied configuration to pipeworks node

Hold wand containing desired configuation in you hand and point node that you want apply settings to.
Left click with wand to apply new settings, chat will display confirmation message when settings are applied to pointed node.

## How to add supported nodes

Example to add support for technic:injector

```
local definition = {
	group = "technic injector",
	copy = function(node, pos, player)
		-- add code for copying data from pointed injector node
		-- for example get some metadata and store it in wand memory
		-- also set some nice description of wand
		local meta = minetest.get_meta(pos)
		return {
			description = "This wand has some injector data",
			myvalue = meta:get_string("owner")
		}
	end,
	paste = function(node, pos, player, data)
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", data.myvalue)
	end,
}
```

Supply above definition for tool, mytool variable is returned from metatool:register_tool method

```
mytool:load_node_definition(definition)
```

or by fully qualified tool name

```
metatool:register_node("metatool:tubetool", definition)
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

## Registered nodes included with tubetool

In nodes subdirectory there is few predefined pipeworks components.

## Minetest protection checks

Protection checks are done automatically for all wand uses, node registration does not need any protection checks.
Wand cannot be used to read settings from protected nodes and it cannot be used to write settings to protected nodes.
