![](https://mineunit-badges.000webhostapp.com/S-S-X/metatool/sharetool-coverage)

## Sharetool basics

Sharetool is moderator tool that can be used to claim  ownership of various nodes and
then transfer ownership to sppecial shared user account.

For example it can be used to take ownership of book, then change text in book and
return book to shared account allowing multiple users to write into same book.

Another use is to manage shared travelnet networks without full travelnet admin privileges,
place and configure travelnet and then transfer ownership to shared account.

#### How to get sharetool

Sharetool is not craftable and using it requires selected privileges.
Anyone who does have privileges to use sharetool can also get sharetool with chat command:

`/metatool:give metatool:sharetool`

#### Claim ownership

Hold tool in your hand and point node that you want to claim, hold special or sneak button and left click on node to claim ownership.
Chat will display confirmation message when node ownership is transfered to your account.

#### Return ownership to shared account

Hold tool in your hand and point node that you want to be owned by shared account.
Left click with tool, chat will display confirmation message when pointed node owner is changed.
Pointed node is now owned by shared account and node is marked as shared.

## Nodes compatible with sharetool

* homedecor:book
* travelnet:elevator
* travelnet:travelnet
* travelnet:travelnet_private
* locked_travelnet:travelnet
* Mission block
* Mapserver POI
* Mapserver markers

## Minetest protection checks (default settings)

Tool cannot be used without ban privilege.
Tool uses special customized protection checks and can bypass protections if node is marked as shared or is owned by shared account.

## Configuration

Sharetool configuration keys with default values:

```
metatool:sharetool:privs = ban
metatool:sharetool:shared_account = shared
```

Sharetool configuration keys without any default values:

```
metatool:sharetool:nodes:travelnet:protection_bypass_read
metatool:sharetool:nodes:travelnet:protection_bypass_write
metatool:sharetool:nodes:book:protection_bypass_read
metatool:sharetool:nodes:book:protection_bypass_write
metatool:sharetool:nodes:poi:protection_bypass_read
metatool:sharetool:nodes:poi:protection_bypass_write
```
