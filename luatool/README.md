## Luatool basics

Luatool is made available for copying code from one node to another.
For example it can be used to copy code from one luacontroller to another.

#### Copy configuration from pipeworks node

Hold tool in your hand and point node that you want to copy code from, hold special or sneak button and left click on node to copy code.
Chat will display confirmation message when code is copied into tool memory.

#### Apply copied configuration to pipeworks node

Hold tool containing desired code in you hand and point node that you want apply code to.
Left click with tool to apply new settings, chat will display confirmation message when code is applied to pointed node.

## Nodes compatible with luatool

* mesecons_luacontroller:luacontroller
* mesecons_microcontroller:microcontroller
* pipeworks:lua_tube

## Minetest protection checks (default settings)

Protection checks are done automatically for all tool uses, node registration does not need any protection checks.
Tool can be used to read code from protected nodes but it cannot be used to write code to protected nodes.

## Configuration

Luatool configuration keys with default values:

```
metatool:luatool:nodes:luacontroller:protection_bypass_read = interact
metatool:luatool:nodes:microcontroller:protection_bypass_read = interact
metatool:luatool:nodes:luatube:protection_bypass_read = interact
```

Luatool configuration keys without any default values:

```
metatool:luatool:privs
metatool:luatool:nodes:luacontroller:protection_bypass_write
metatool:luatool:nodes:microcontroller:protection_bypass_write
metatool:luatool:nodes:luatube:protection_bypass_write
```
