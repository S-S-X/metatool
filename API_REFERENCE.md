### Metatool namespace keys for internal use, these should not be used directly

```
metatool.configuration_file
metatool.export_default_config
metatool.modpath
metatool.S
metatool.tools
metatool.privileged_tools
```

### Metatool API methods

`metatool.settings = function(toolname, key)`
Return settings for tool, either `nil`, `table` or value as string.

`metatool.merge_tool_settings   = function(name, tooldef)`
Internal method to merge settings and push merged settings into tool definition.
Do not use directly, will be called through `metatool:register_tool`.

`metatool.check_privs           = function(player, privs)`
Check if player has privs, return boolean.

`metatool.is_protected          = function(pos, player, privs, no_violation_record)`
Check if position is protected.

`metatool.before_read           = function(nodedef, pos, player, no_violation_record)`
Default `before_read` method for registered nodes

`metatool.before_write          = function(nodedef, pos, player, no_violation_record)`
Default `before_write` method for registered nodes.

`metatool.write_data            = function(itemstack, data, description)`
Write tool metadata.

`metatool.read_data             = function(itemstack)`
Read and return tool metadata.

`metatool:on_use                = function(self, toolname, itemstack, player, pointed_thing)`
Default `on_use` method for registered tools.

`metatool:register_tool         = function(self, name, definition)`
Tool registration method, returns tool definition assembly.

`metatool:register_node         = function(self, toolname, name, definition, override)`
Node registration method, this method will probably change or will be removed in future.
Do not use directly, instead use `tool:load_node_definition`.

`metatool:get_node              = function(self, tool, player, pointed_thing)`
Get node from world, checks node compatibility and protections.
Returns either `nil` or indexed table containing node, pos, definition.

`metatool:copy                  = function(self, node, pos, player)`
Wrappper that does simple checks and calls node definition `copy` method.

`metatool:paste                 = function(self, node, pos, player, data, group)`
Wrappper that does simple checks and calls node definition `paste` method.

### Metatool API methods for registered tools

`tool:load_node_definition      = function(self, def)`
Loads new node definition for registered tool.
