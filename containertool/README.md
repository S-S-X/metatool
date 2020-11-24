## Container tool basics

Container tool is made available for copying container settings from one node to another.
For example it can be used to copy settings from one container to another.

#### Copy settings from compatible nodes

Hold tool in your hand and point node that you want to copy settings from, hold special or sneak button and left click on node to copy settings.
Chat will display confirmation message when settings is copied into tool memory.

#### Apply copied settings to compatible nodes

Hold tool containing desired settings in you hand and point node that you want apply settings to.
Left click with tool to apply new settings, chat will display confirmation message when settings is applied to pointed node.

## Nodes compatible with Container tool

r = ability to read
w = ability to write

* technic chests (r/w)
* technic self contained injector (r/w)
* technic machines with inventory (r/w)
* default wooden chests (r/w)
* more_chests:shared (r/w)
* digilines:chest (r/w)

## Minetest protection checks (default settings)

Protection checks are done automatically for all tool uses, node registration does not need any protection checks.
Tool can be used to read settings from protected nodes but it cannot be used to write settings to protected nodes.

## Configuration

Container tool configuration keys with default values (where * is any containertool node):

```
metatool:containertool:nodes:*:protection_bypass_read = interact
```
