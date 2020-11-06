## Magic pen basics

Magic pen is made available for copying text content from one node to another.
For example it can be used to copy text from one book to another.

#### Copy content from compatible nodes

Hold tool in your hand and point node that you want to copy content from, hold special or sneak button and left click on node to copy content.
Chat will display confirmation message when content is copied into tool memory.

#### Apply copied content to compatible nodes

Hold tool containing desired content in you hand and point node that you want apply content to.
Left click with tool to apply new settings, chat will display confirmation message when content is applied to pointed node.

## Nodes compatible with Magic pen

r = ability to read
w = ability to write

* mesecons_luacontroller:luacontroller (r/w)
* mesecons_microcontroller:microcontroller (r)
* pipeworks:lua_tube (r/w)
* homedecor:book (r/w)
* travelnet:elevator (r)
* travelnet:travelnet (r)
* travelnet:travelnet_private (r)
* locked_travelnet:travelnet (r)

## Minetest protection checks (default settings)

Protection checks are done automatically for all tool uses, node registration does not need any protection checks.
Tool can be used to read content from protected nodes but it cannot be used to write content to protected nodes.

## Configuration

Magic pen configuration keys with default values (where * is any magic_pen node):

```
metatool:magic_pen:nodes:*:protection_bypass_read = interact
```
