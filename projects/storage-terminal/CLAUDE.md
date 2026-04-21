# storage-terminal

Monitor-based storage terminal for Create item networks

## Addons
@types/basalt/basalt.lua

## Libs
@lib/log.lua

## Hardware
- Advanced Computer connected via wired modem network
- 4x3 advanced monitor (touch input, colors)
- Create storage blocks (vaults, chests, barrels) on the same wired network
- An output inventory (chest/barrel) adjacent to the computer or on the network for item extraction

## CC:Tweaked Inventory Peripheral Methods
All inventory blocks expose these generic methods when wrapped:
- `list()` → table of `{name: string, count: number, nbt?: string}` keyed by slot number
- `getItemDetail(slot)` → detailed item info including displayName, maxCount, tags
- `size()` → number of slots
- `pushItems(toName, fromSlot, limit?, toSlot?)` → number of items transferred
- `pullItems(fromName, fromSlot, limit?, toSlot?)` → number of items transferred
