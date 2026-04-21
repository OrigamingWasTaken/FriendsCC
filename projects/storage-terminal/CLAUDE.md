# Storage Terminal v2

Full-featured storage management for Create item vaults. Web UI for browsing/extraction, monitors for dashboard panels, WebSocket relay connecting them.

## Architecture

CC Computer (Lua) → WebSocket → Bun Relay → WebSocket → Svelte Browser

## CC:Tweaked Files (deployed to computer)

All files in cc/ are deployed to the computer root. Load siblings with dofile:
```lua
local config = dofile("/config.lua")
local draw = dofile("/draw.lua")
```

## Inventory Peripheral Methods
- `list()` → table of `{name: string, count: number, nbt?: string}` keyed by slot
- `getItemDetail(slot)` → `{displayName, name, count, maxCount, enchantments?, damage?, maxDamage?, tags?}`
- `size()` → number of slots
- `pushItems(toName, fromSlot, limit?, toSlot?)` → number transferred
- `pullItems(fromName, fromSlot, limit?, toSlot?)` → number transferred

## Item Key Format
`name .. "|" .. (nbt or "")` — uniquely identifies items including enchantments and renames.
