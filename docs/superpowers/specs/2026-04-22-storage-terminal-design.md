# Storage Terminal v2 — Design Spec

A full-featured storage management system for CC:Tweaked + Create item vaults. Web UI for interaction, in-game monitors for dashboard panels, WebSocket relay connecting them.

## Architecture

```
[Monitors] <-- raw term API -- [CC Computer] -- ws client --> [Bun Relay] <-- ws --> [Svelte Frontend]
```

- **CC Computer** is the single source of truth. Scans inventories, holds item cache, renders monitor panels, handles extract commands.
- **Bun Relay** is a dumb WebSocket message forwarder (~50 lines). Also serves the built Svelte static files.
- **Svelte Frontend** is a single-page app for browsing, searching, filtering, and extracting items. Pure client-side, no SSR.

## Project Structure

```
projects/storage-terminal/
├── CLAUDE.md
├── cc/                          # CC:Tweaked Lua (deployed to computer)
│   ├── startup.lua
│   ├── main.lua                 # Entry point — parallel: scanner, panels, ws
│   ├── scanner.lua              # Inventory scanning + item cache + extract
│   ├── panels.lua               # Monitor panel renderer
│   ├── ws.lua                   # WebSocket client to relay
│   ├── config.lua               # Settings + panel assignments
│   └── draw.lua                 # Thin drawing helpers (box, bar, table, text)
├── relay/                       # Bun WebSocket relay + static file server
│   ├── package.json
│   ├── tsconfig.json
│   └── index.ts
├── web/                         # Svelte frontend
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   ├── index.html
│   └── src/
│       ├── App.svelte
│       ├── main.ts
│       ├── lib/
│       │   ├── ws.ts            # WebSocket connection to relay
│       │   ├── store.ts         # Svelte stores for inventory state
│       │   └── types.ts         # Item, PanelConfig, Message types
│       ├── components/
│       │   ├── ItemList.svelte   # Searchable/filterable item grid
│       │   ├── ItemDetail.svelte # Detail view + extract action
│       │   ├── SearchBar.svelte
│       │   ├── FilterBar.svelte
│       │   ├── Settings.svelte   # Panel config editor
│       │   └── ItemIcon.svelte   # Colored letter fallback
│       └── assets/
│           └── icons/           # Pre-extracted textures (future)
└── install.lua                  # In-game installer for cc/ files
```

## WebSocket Protocol

All messages are JSON over WebSocket through the relay.

### CC → Web (state updates)

**`inventory`** — full inventory snapshot, sent on connect and after each scan:
```json
{
  "type": "inventory",
  "items": [
    {
      "key": "minecraft:diamond_sword|{ench:[{id:sharpness,lvl:5}]}",
      "name": "minecraft:diamond_sword",
      "displayName": "Sharpness V Diamond Sword",
      "count": 3,
      "mod": "minecraft",
      "enchantments": [{"name": "Sharpness", "level": 5}],
      "customName": "Excalibur",
      "damage": 12,
      "maxDamage": 1561,
      "nbt": "{ench:[{id:sharpness,lvl:5}]}",
      "tags": ["minecraft:swords"]
    }
  ]
}
```

**`inventory_delta`** — incremental update between full scans:
```json
{
  "type": "inventory_delta",
  "added": [],
  "removed": [],
  "changed": [{"key": "...", "count": 128}]
}
```

**`config`** — current configuration:
```json
{
  "type": "config",
  "panels": {
    "monitor_0": "recent_activity",
    "monitor_1": "storage_fill"
  },
  "outputInv": "minecraft:chest_0",
  "scanInterval": 5,
  "relayUrl": "ws://localhost:3001"
}
```

**`activity`** — log event:
```json
{
  "type": "activity",
  "entry": {
    "action": "extract",
    "item": "Diamond Sword",
    "count": 1,
    "timestamp": 1745337600000
  }
}
```

**`status`** — system status:
```json
{
  "type": "status",
  "connected": true,
  "vaults": 5,
  "totalSlots": 270,
  "usedSlots": 142,
  "totalItems": 8453,
  "uniqueTypes": 87,
  "lastScanMs": 230
}
```

### Web → CC (commands)

**`extract`** — pull items to output chest:
```json
{
  "type": "extract",
  "itemKey": "minecraft:diamond|",
  "count": 64
}
```

**`config_update`** — change panel assignments or settings:
```json
{
  "type": "config_update",
  "panels": {"monitor_0": "top_items"}
}
```

**`refresh`** — force immediate rescan:
```json
{"type": "refresh"}
```

### Item Key Format

Items are uniquely identified by `name + "|" + (nbt or "")`. This ensures:
- Regular diamond sword ≠ enchanted diamond sword
- Two identical enchanted swords with the same enchantments = same key
- Renamed items have different NBT so they get their own key

## CC:Tweaked Lua Components

### main.lua

Entry point. Runs three loops in parallel:

```lua
parallel.waitForAll(
    scanner.loop,    -- scan inventories, maintain cache
    panels.loop,     -- render panels to monitors
    ws.loop          -- WebSocket connection + command handling
)
```

### scanner.lua

Inventory scanning and item management:

- `scanner.scan()` — scans all `inventory` peripherals (except output inv), returns aggregated item list
- `scanner.getItems()` — returns current cached item list
- `scanner.getDelta(oldItems, newItems)` — computes added/removed/changed
- `scanner.extract(itemKey, count)` — pulls items from storage to output chest via `pullItems()`
- `scanner.getStatus()` — returns vault count, slot usage, timing
- `scanner.loop()` — runs `scan()` every N seconds, fires callbacks on change

**Item detail enrichment:** On first seeing an item (by slot+nbt), calls `getItemDetail(slot)` to get:
- `displayName` — includes custom anvil names
- `enchantments` — table of `{name, level}` if present
- `damage` / `maxDamage` — durability
- `tags` — item tags for filtering

Detail results are cached by item key to avoid repeated `getItemDetail` calls. Fields like `enchantments`, `damage`, and `tags` may be absent depending on the item — scanner treats all detail fields as optional and defaults to nil.

**Activity log:** Scanner maintains a ring buffer of the last 50 events (add/remove/extract with item name, count, timestamp).

### panels.lua

Monitor panel rendering:

- `panels.loop()` — reads config, renders assigned panel to each monitor every 1 second
- Each panel is a function: `function(mon, monW, monH, data)` where `data` comes from scanner

**Available panels:**

| Panel ID | Description |
|---|---|
| `recent_activity` | Scrolling log of items added/removed with timestamps |
| `storage_fill` | Overall capacity progress bar + per-vault breakdown |
| `top_items` | Ranked list of highest-count items with bars |
| `low_stock` | Items below configurable threshold, highlighted red |
| `system_status` | Connection status, vault count, total items, scan time |

**Custom palette** applied to each monitor for a dark theme:
```lua
mon.setPaletteColor(colors.black, 0x1a1b26)      -- background
mon.setPaletteColor(colors.gray, 0x24283b)        -- card/row bg
mon.setPaletteColor(colors.lightGray, 0x565f89)   -- muted text
mon.setPaletteColor(colors.blue, 0x7aa2f7)        -- accent
mon.setPaletteColor(colors.green, 0x9ece6a)       -- positive
mon.setPaletteColor(colors.red, 0xf7768e)         -- alert
mon.setPaletteColor(colors.purple, 0xbb9af7)      -- enchanted
mon.setPaletteColor(colors.orange, 0xff9e64)       -- Create mod
mon.setPaletteColor(colors.yellow, 0xe0af68)       -- warning
mon.setPaletteColor(colors.white, 0xc0caf5)       -- primary text
mon.setPaletteColor(colors.cyan, 0x7dcfff)        -- info
mon.setPaletteColor(colors.lightBlue, 0x89ddff)   -- secondary
```

### draw.lua

Thin drawing helpers over raw `term.write` / `term.blit`:

- `draw.clear(mon, bg)` — fill screen with background color
- `draw.box(mon, x, y, w, h, bg)` — filled rectangle
- `draw.text(mon, x, y, text, fg, bg)` — colored text at position
- `draw.textRight(mon, x, y, w, text, fg, bg)` — right-aligned text
- `draw.progressBar(mon, x, y, w, value, max, fg, bg)` — horizontal progress bar using block characters
- `draw.table(mon, x, y, w, columns, rows, opts)` — auto-width table with alternating row colors
- `draw.header(mon, w, text, fg, bg)` — full-width header bar
- `draw.hline(mon, x, y, w, color)` — horizontal line

No external dependencies. Uses `term.blit` for per-character coloring.

### ws.lua

WebSocket client:

- `ws.connect(url)` — opens `http.websocket(url .. "?role=cc")`
- `ws.send(msg)` — serializes table to JSON and sends
- `ws.loop()` — main loop: connect, send initial state, listen for messages, dispatch commands, auto-reconnect on disconnect with exponential backoff
- Dispatches received commands to scanner (extract, refresh) or config (config_update)
- Sends inventory snapshots/deltas when scanner reports changes

### config.lua

Persistent configuration:

- Stores in `/storage-terminal.config` (serialized Lua table)
- Fields: `relayUrl`, `outputInv`, `scanInterval`, `panels` (table of monitor name → panel ID)
- `config.load()` — reads file, applies defaults for missing fields
- `config.save()` — writes current config to file
- `config.get(key)` — get a config value
- `config.set(key, value)` — set and auto-save

Default config:
```lua
{
    relayUrl = "ws://localhost:3001",
    outputInv = "minecraft:chest_0",
    scanInterval = 5,
    panels = {}
}
```

## Bun Relay Server

Single file `relay/index.ts`:

- Listens on configurable port (default 3001, via `PORT` env var)
- WebSocket endpoint at `/ws`
- Connections identified by `?role=cc` or `?role=browser` query param
- One CC connection at a time (new CC connection replaces old)
- Multiple browser connections
- CC → all browsers (broadcast)
- Browser → CC (forward)
- On CC disconnect: broadcast `{type: "status", connected: false}` to browsers
- On browser command with no CC: respond `{type: "error", message: "Computer not connected"}`
- Serves static files from `../web/dist/` for the Svelte frontend
- Health check at `GET /health`

## Svelte Frontend

### Layout

Single-page app, dark theme. Three sections:

1. **Header bar** — "Storage Terminal" title, connection status dot (green/red), gear icon for settings
2. **Left sidebar** — SearchBar + FilterBar + sort options
3. **Main area** — ItemList grid, clicking an item opens ItemDetail as a right-side slide-out panel

### Components

**`SearchBar.svelte`**
- Text input with debounce (200ms)
- Filters items client-side by displayName and registry name
- Clear button

**`FilterBar.svelte`**
- Mod filter: chips for each mod present in inventory (auto-detected), click to toggle
- Special filters: "Enchanted", "Renamed", "Damaged" toggle chips
- Sort: dropdown — "Count (high→low)", "Name (A→Z)", "Recently changed"

**`ItemList.svelte`**
- CSS grid of item cards
- Each card: ItemIcon, displayName (truncated), count badge, mod name small
- Enchanted items: purple left border
- Renamed items: italic custom name, original name below in gray
- Empty state: "No items found" or "Not connected"

**`ItemDetail.svelte`**
- Slide-out panel from right
- Full item info: icon, display name, registry name, mod, total count
- Enchantments list if any (e.g. "Sharpness V, Unbreaking III")
- Durability bar if damaged
- Vault breakdown: which vaults hold this item and how many
- Extract section: number input, "Extract" button, "Extract All" button
- Success/error toast on extraction result

**`ItemIcon.svelte`**
- If icon PNG exists in `assets/icons/{name}.png`, show it
- Otherwise: colored square with first letter of item name, color based on mod
- Future: support for sprite sheet lookup

**`Settings.svelte`**
- Modal or separate route
- List of connected monitors (from CC status), dropdown to assign panel type
- Output inventory name (text input)
- Scan interval (number input)
- Relay URL (text input, mostly for dev)

### Stores (`store.ts`)

Svelte writable stores:
- `items` — full item list from CC
- `connected` — boolean, WebSocket connection state
- `status` — system status from CC
- `config` — current config from CC
- `activity` — recent activity log entries

### WebSocket Client (`ws.ts`)

- Connects to relay at `ws://{host}:{port}/ws?role=browser`
- Auto-reconnect with exponential backoff
- Parses incoming JSON, updates appropriate stores
- Exposes `send(msg)` for commands
- Connection state reflected in `connected` store

### Styling

- Dark theme: `#1a1b26` background, `#c0caf5` text (Tokyo Night inspired, matching monitor palette)
- No CSS framework — plain CSS with CSS custom properties for theming
- Responsive but designed for desktop
- Subtle transitions on card hover, slide-out panel animation

## Item Handling

### Special Item Support

| Item Type | How Detected | Display Treatment |
|---|---|---|
| Regular items | No NBT or standard NBT | Normal display |
| Renamed items | `displayName` differs from default name for that `name` | Italic custom name, original below in gray |
| Enchanted items | `enchantments` table present and non-empty | Purple accent, enchantment list shown |
| Damaged items | `damage > 0` | Durability bar shown |
| Items with NBT | `nbt` field present | Separate entry per unique NBT |

### Item Aggregation

Items are aggregated by key (`name + "|" + nbt`). This means:
- 64 regular diamonds across 3 vaults = 1 entry showing 64
- A renamed diamond sword = separate entry from an unrenamed one
- Two identically enchanted bows = same entry, counts summed
- Two differently enchanted bows = two separate entries

### Extraction

When extracting, the scanner iterates over the item's `sources` (list of `{inv, slot, count}`) and calls `pullItems()` on the output inventory for each source until the requested amount is fulfilled. If the output chest is full, it stops and reports how many were actually extracted.
