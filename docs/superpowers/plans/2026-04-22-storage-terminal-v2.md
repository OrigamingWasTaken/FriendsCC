# Storage Terminal v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a storage management system with a Svelte web UI for interaction, CC:Tweaked monitors for dashboard panels, and a Bun WebSocket relay connecting them.

**Architecture:** CC computer scans Create item vaults and holds the item cache (source of truth). It connects via WebSocket to a Bun relay server, which forwards messages to/from Svelte browser clients. Monitors render dashboard panels using raw term API with a custom dark palette.

**Tech Stack:** Lua 5.1 (CC:Tweaked), Bun + TypeScript (relay), Svelte 5 + Vite + TypeScript (frontend)

**Spec:** `docs/superpowers/specs/2026-04-22-storage-terminal-design.md`

**Note:** CC:Tweaked Lua has no test framework — validation is running in-game. Web/relay code can be verified by running the dev server. Each task ends with a verification step.

**Important CC:Tweaked conventions (from CLAUDE.md):**
- Use `dofile("/path/to/file.lua")` for custom libs, NOT `require` with `package.path`
- `require` is fine for built-in CC:T modules only
- Lua 5.1: no `goto`, no bitwise operators, use `unpack` not `table.unpack`, use `textutils.serializeJSON`/`textutils.unserializeJSON` for JSON

---

## Task 1: Project restructure + CC config & draw helpers

**Files:**
- Delete: `projects/storage-terminal/main.lua` (old single-file version)
- Delete: `projects/storage-terminal/deploy.sh`
- Delete: `projects/storage-terminal/install.lua`
- Delete: `projects/storage-terminal/startup.lua`
- Modify: `projects/storage-terminal/CLAUDE.md`
- Create: `projects/storage-terminal/cc/config.lua`
- Create: `projects/storage-terminal/cc/draw.lua`

- [ ] **Step 1: Remove old files and update CLAUDE.md**

Delete old files:
```bash
rm projects/storage-terminal/main.lua projects/storage-terminal/deploy.sh projects/storage-terminal/install.lua projects/storage-terminal/startup.lua
```

Replace `projects/storage-terminal/CLAUDE.md` with:

```markdown
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

## WebSocket Protocol
See spec: docs/superpowers/specs/2026-04-22-storage-terminal-design.md
```

- [ ] **Step 2: Create cc/config.lua**

```lua
local config = {}

local CONFIG_PATH = "/storage-terminal.config"

local _data = {
    relayUrl = "ws://localhost:3001/ws",
    outputInv = "minecraft:chest_0",
    scanInterval = 5,
    panels = {},
}

function config.load()
    if fs.exists(CONFIG_PATH) then
        local h = fs.open(CONFIG_PATH, "r")
        if h then
            local content = h.readAll()
            h.close()
            local loaded = textutils.unserialize(content)
            if type(loaded) == "table" then
                for k, v in pairs(loaded) do
                    _data[k] = v
                end
            end
        end
    end
end

function config.save()
    local h = fs.open(CONFIG_PATH, "w")
    if h then
        h.write(textutils.serialize(_data))
        h.close()
    end
end

function config.get(key)
    return _data[key]
end

function config.set(key, value)
    _data[key] = value
    config.save()
end

function config.getAll()
    local copy = {}
    for k, v in pairs(_data) do
        copy[k] = v
    end
    return copy
end

function config.setMany(tbl)
    for k, v in pairs(tbl) do
        _data[k] = v
    end
    config.save()
end

return config
```

- [ ] **Step 3: Create cc/draw.lua**

```lua
local draw = {}

function draw.applyPalette(mon)
    mon.setPaletteColor(colors.black, 0x1a1b26)
    mon.setPaletteColor(colors.gray, 0x24283b)
    mon.setPaletteColor(colors.lightGray, 0x565f89)
    mon.setPaletteColor(colors.blue, 0x7aa2f7)
    mon.setPaletteColor(colors.green, 0x9ece6a)
    mon.setPaletteColor(colors.red, 0xf7768e)
    mon.setPaletteColor(colors.purple, 0xbb9af7)
    mon.setPaletteColor(colors.orange, 0xff9e64)
    mon.setPaletteColor(colors.yellow, 0xe0af68)
    mon.setPaletteColor(colors.white, 0xc0caf5)
    mon.setPaletteColor(colors.cyan, 0x7dcfff)
    mon.setPaletteColor(colors.lightBlue, 0x89ddff)
end

function draw.clear(mon, bg)
    mon.setBackgroundColor(bg or colors.black)
    mon.clear()
end

function draw.box(mon, x, y, w, h, bg)
    mon.setBackgroundColor(bg)
    for row = y, y + h - 1 do
        mon.setCursorPos(x, row)
        mon.write(string.rep(" ", w))
    end
end

function draw.text(mon, x, y, text, fg, bg)
    mon.setCursorPos(x, y)
    if bg then mon.setBackgroundColor(bg) end
    if fg then mon.setTextColor(fg) end
    mon.write(text)
end

function draw.textRight(mon, x, y, w, text, fg, bg)
    local px = x + w - #text
    draw.text(mon, px, y, text, fg, bg)
end

function draw.header(mon, w, text, fg, bg)
    draw.box(mon, 1, 1, w, 1, bg or colors.blue)
    draw.text(mon, 2, 1, text, fg or colors.white, bg or colors.blue)
end

function draw.hline(mon, x, y, w, color)
    mon.setBackgroundColor(color or colors.lightGray)
    mon.setCursorPos(x, y)
    mon.write(string.rep(" ", w))
end

function draw.progressBar(mon, x, y, w, value, max, fg, bg)
    if max <= 0 then max = 1 end
    local filled = math.floor((value / max) * w + 0.5)
    if filled > w then filled = w end
    mon.setCursorPos(x, y)
    mon.setBackgroundColor(fg or colors.green)
    mon.write(string.rep(" ", filled))
    mon.setBackgroundColor(bg or colors.gray)
    mon.write(string.rep(" ", w - filled))
end

function draw.tableRow(mon, x, y, w, cols, fg, bg)
    draw.box(mon, x, y, w, 1, bg)
    local cx = x
    for i, col in ipairs(cols) do
        local text = tostring(col.text or "")
        local colW = col.width or math.floor(w / #cols)
        if #text > colW then
            text = text:sub(1, colW - 2) .. ".."
        end
        if col.align == "right" then
            draw.textRight(mon, cx, y, colW, text, col.fg or fg, bg)
        else
            draw.text(mon, cx, y, " " .. text, col.fg or fg, bg)
        end
        cx = cx + colW
    end
end

return draw
```

- [ ] **Step 4: Verify and commit**

```bash
ls projects/storage-terminal/cc/config.lua projects/storage-terminal/cc/draw.lua
cat projects/storage-terminal/CLAUDE.md
```

```bash
git add projects/storage-terminal/
git commit -m "refactor: restructure storage-terminal, add config and draw modules"
```

---

## Task 2: CC scanner.lua

**Files:**
- Create: `projects/storage-terminal/cc/scanner.lua`

- [ ] **Step 1: Create cc/scanner.lua**

```lua
local scanner = {}

local _config = nil
local _items = {}
local _itemsByKey = {}
local _detailCache = {}
local _activity = {}
local _activityMax = 50
local _vaultCount = 0
local _totalSlots = 0
local _usedSlots = 0
local _lastScanMs = 0
local _onChangeCallbacks = {}

function scanner.init(config)
    _config = config
end

function scanner.onChange(callback)
    table.insert(_onChangeCallbacks, callback)
end

local function fireChange(items, delta)
    for _, cb in ipairs(_onChangeCallbacks) do
        cb(items, delta)
    end
end

local function addActivity(action, itemName, count)
    table.insert(_activity, 1, {
        action = action,
        item = itemName,
        count = count,
        timestamp = os.epoch("utc"),
    })
    while #_activity > _activityMax do
        table.remove(_activity)
    end
end

local function makeKey(name, nbt)
    return name .. "|" .. (nbt or "")
end

local function extractMod(name)
    return name:match("^([^:]+):") or "unknown"
end

local function enrichItem(invName, slot, basicItem)
    local key = makeKey(basicItem.name, basicItem.nbt)
    if _detailCache[key] then
        return _detailCache[key]
    end

    local ok, detail = pcall(peripheral.call, invName, "getItemDetail", slot)
    local enriched = {
        name = basicItem.name,
        displayName = basicItem.name,
        mod = extractMod(basicItem.name),
        enchantments = nil,
        customName = nil,
        damage = nil,
        maxDamage = nil,
        tags = nil,
    }

    if ok and detail then
        enriched.displayName = detail.displayName or basicItem.name
        enriched.enchantments = detail.enchantments
        enriched.damage = detail.damage
        enriched.maxDamage = detail.maxDamage
        enriched.tags = detail.tags

        if detail.displayName and detail.name then
            local defaultName = detail.name:match(":(.+)") or detail.name
            defaultName = defaultName:gsub("_", " ")
            local lower = detail.displayName:lower()
            local defaultLower = defaultName:lower()
            if lower ~= defaultLower then
                enriched.customName = detail.displayName
            end
        end
    end

    _detailCache[key] = enriched
    return enriched
end

function scanner.scan()
    local startTime = os.epoch("utc")
    local outputInv = _config.get("outputInv")
    local names = peripheral.getNames()
    local inventories = {}

    for _, name in ipairs(names) do
        if peripheral.hasType(name, "inventory") and name ~= outputInv then
            table.insert(inventories, name)
        end
    end

    _vaultCount = #inventories
    _totalSlots = 0
    _usedSlots = 0

    local newItemsByKey = {}

    for _, invName in ipairs(inventories) do
        local okSize, size = pcall(peripheral.call, invName, "size")
        if okSize and size then
            _totalSlots = _totalSlots + size
        end

        local okList, contents = pcall(peripheral.call, invName, "list")
        if okList and contents then
            for slot, basicItem in pairs(contents) do
                _usedSlots = _usedSlots + 1
                local key = makeKey(basicItem.name, basicItem.nbt)
                local detail = enrichItem(invName, slot, basicItem)

                if not newItemsByKey[key] then
                    newItemsByKey[key] = {
                        key = key,
                        name = detail.name,
                        displayName = detail.displayName,
                        count = 0,
                        mod = detail.mod,
                        enchantments = detail.enchantments,
                        customName = detail.customName,
                        damage = detail.damage,
                        maxDamage = detail.maxDamage,
                        nbt = basicItem.nbt,
                        tags = detail.tags,
                        sources = {},
                    }
                end

                newItemsByKey[key].count = newItemsByKey[key].count + basicItem.count
                table.insert(newItemsByKey[key].sources, {
                    inv = invName,
                    slot = slot,
                    count = basicItem.count,
                })
            end
        end
    end

    local delta = scanner.getDelta(_itemsByKey, newItemsByKey)
    _itemsByKey = newItemsByKey

    _items = {}
    for _, item in pairs(_itemsByKey) do
        table.insert(_items, item)
    end
    table.sort(_items, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.displayName < b.displayName
    end)

    for _, entry in ipairs(delta.added) do
        addActivity("add", entry.displayName, entry.count)
    end
    for _, entry in ipairs(delta.removed) do
        addActivity("remove", entry.displayName, entry.count)
    end

    _lastScanMs = os.epoch("utc") - startTime

    if #delta.added > 0 or #delta.removed > 0 or #delta.changed > 0 then
        fireChange(_items, delta)
    end

    return _items
end

function scanner.getDelta(oldByKey, newByKey)
    local added = {}
    local removed = {}
    local changed = {}

    for key, newItem in pairs(newByKey) do
        local oldItem = oldByKey[key]
        if not oldItem then
            table.insert(added, { key = key, displayName = newItem.displayName, count = newItem.count })
        elseif oldItem.count ~= newItem.count then
            table.insert(changed, { key = key, count = newItem.count })
        end
    end

    for key, oldItem in pairs(oldByKey) do
        if not newByKey[key] then
            table.insert(removed, { key = key, displayName = oldItem.displayName, count = oldItem.count })
        end
    end

    return { added = added, removed = removed, changed = changed }
end

function scanner.extract(itemKey, count)
    local item = _itemsByKey[itemKey]
    if not item then
        return 0, "Item not found"
    end

    local outputInv = _config.get("outputInv")
    local remaining = count
    local extracted = 0

    for _, source in ipairs(item.sources) do
        if remaining <= 0 then break end
        local ok, transferred = pcall(
            peripheral.call, outputInv, "pullItems",
            source.inv, source.slot,
            math.min(remaining, source.count)
        )
        if ok and transferred and transferred > 0 then
            remaining = remaining - transferred
            extracted = extracted + transferred
        end
    end

    if extracted > 0 then
        addActivity("extract", item.displayName, extracted)
    end

    return extracted
end

function scanner.getItems()
    return _items
end

function scanner.getActivity()
    return _activity
end

function scanner.getStatus()
    return {
        connected = true,
        vaults = _vaultCount,
        totalSlots = _totalSlots,
        usedSlots = _usedSlots,
        totalItems = 0,
        uniqueTypes = #_items,
        lastScanMs = _lastScanMs,
    }
end

function scanner.loop()
    while true do
        scanner.scan()
        sleep(_config.get("scanInterval") or 5)
    end
end

return scanner
```

- [ ] **Step 2: Verify and commit**

```bash
wc -l projects/storage-terminal/cc/scanner.lua
```

```bash
git add projects/storage-terminal/cc/scanner.lua
git commit -m "feat: scanner module — inventory scanning, item enrichment, extraction"
```

---

## Task 3: CC ws.lua

**Files:**
- Create: `projects/storage-terminal/cc/ws.lua`

- [ ] **Step 1: Create cc/ws.lua**

```lua
local ws = {}

local _config = nil
local _scanner = nil
local _socket = nil
local _connected = false

function ws.init(config, scanner)
    _config = config
    _scanner = scanner

    scanner.onChange(function(items, delta)
        if _connected then
            ws.sendInventory(items)
            ws.sendStatus()
        end
    end)
end

function ws.sendJSON(tbl)
    if _socket then
        local ok, json = pcall(textutils.serializeJSON, tbl)
        if ok then
            pcall(_socket.send, json)
        end
    end
end

function ws.sendInventory(items)
    local sendItems = {}
    for _, item in ipairs(items) do
        local si = {
            key = item.key,
            name = item.name,
            displayName = item.displayName,
            count = item.count,
            mod = item.mod,
            nbt = item.nbt,
        }
        if item.enchantments then si.enchantments = item.enchantments end
        if item.customName then si.customName = item.customName end
        if item.damage then si.damage = item.damage end
        if item.maxDamage then si.maxDamage = item.maxDamage end
        if item.tags then si.tags = item.tags end
        table.insert(sendItems, si)
    end
    ws.sendJSON({ type = "inventory", items = sendItems })
end

function ws.sendStatus()
    local status = _scanner.getStatus()
    status.type = "status"
    ws.sendJSON(status)
end

function ws.sendConfig()
    local cfg = _config.getAll()
    cfg.type = "config"
    ws.sendJSON(cfg)
end

function ws.sendActivity(entry)
    ws.sendJSON({ type = "activity", entry = entry })
end

local function handleMessage(raw)
    local ok, msg = pcall(textutils.unserializeJSON, raw)
    if not ok or type(msg) ~= "table" then return end

    if msg.type == "extract" then
        local extracted = _scanner.extract(msg.itemKey, msg.count or 1)
        _scanner.scan()
        ws.sendJSON({
            type = "extract_result",
            itemKey = msg.itemKey,
            requested = msg.count,
            extracted = extracted,
        })

    elseif msg.type == "config_update" then
        if msg.panels then
            _config.set("panels", msg.panels)
        end
        if msg.outputInv then
            _config.set("outputInv", msg.outputInv)
        end
        if msg.scanInterval then
            _config.set("scanInterval", msg.scanInterval)
        end
        ws.sendConfig()

    elseif msg.type == "refresh" then
        _scanner.scan()
    end
end

function ws.loop()
    local backoff = 1

    while true do
        local url = _config.get("relayUrl") or "ws://localhost:3001/ws"
        if not url:find("%?") then
            url = url .. "?role=cc"
        else
            url = url .. "&role=cc"
        end

        local ok, socket = pcall(http.websocket, url)
        if ok and socket then
            _socket = socket
            _connected = true
            backoff = 1

            ws.sendInventory(_scanner.getItems())
            ws.sendStatus()
            ws.sendConfig()

            while true do
                local raw = socket.receive()
                if raw == nil then
                    break
                end
                handleMessage(raw)
            end

            _connected = false
            _socket = nil
            pcall(socket.close)
        end

        sleep(math.min(backoff, 30))
        backoff = backoff * 2
    end
end

return ws
```

- [ ] **Step 2: Verify and commit**

```bash
git add projects/storage-terminal/cc/ws.lua
git commit -m "feat: WebSocket client — relay connection with auto-reconnect"
```

---

## Task 4: CC panels.lua

**Files:**
- Create: `projects/storage-terminal/cc/panels.lua`

- [ ] **Step 1: Create cc/panels.lua**

```lua
local panels = {}

local _config = nil
local _scanner = nil
local _draw = nil

function panels.init(config, scanner, draw)
    _config = config
    _scanner = scanner
    _draw = draw
end

local function formatCount(n)
    if n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fk", n / 1000)
    end
    return tostring(n)
end

local function formatTime(epoch)
    local s = math.floor(epoch / 1000)
    local m = math.floor(s / 60) % 60
    local h = math.floor(s / 3600) % 24
    return string.format("%02d:%02d", h, m)
end

-- ============================================================================
-- Panel: recent_activity
-- ============================================================================

local function panelRecentActivity(mon, w, h)
    _draw.header(mon, w, "Recent Activity", colors.white, colors.blue)

    local activity = _scanner.getActivity()
    local maxRows = h - 2

    if #activity == 0 then
        _draw.text(mon, 2, 3, "No activity yet", colors.lightGray, colors.black)
        return
    end

    for i = 1, math.min(#activity, maxRows) do
        local entry = activity[i]
        local row = i + 1
        local bg = i % 2 == 0 and colors.gray or colors.black
        _draw.box(mon, 1, row, w, 1, bg)

        local icon, iconColor
        if entry.action == "add" then
            icon = "+"
            iconColor = colors.green
        elseif entry.action == "remove" or entry.action == "extract" then
            icon = "-"
            iconColor = colors.red
        else
            icon = "?"
            iconColor = colors.yellow
        end

        _draw.text(mon, 2, row, icon, iconColor, bg)

        local countStr = formatCount(entry.count)
        local nameW = w - #countStr - 5
        local name = entry.item or "?"
        if #name > nameW then
            name = name:sub(1, nameW - 2) .. ".."
        end
        _draw.text(mon, 4, row, name, colors.white, bg)
        _draw.textRight(mon, 1, row, w - 1, countStr, colors.lightBlue, bg)
    end
end

-- ============================================================================
-- Panel: storage_fill
-- ============================================================================

local function panelStorageFill(mon, w, h)
    _draw.header(mon, w, "Storage Usage", colors.white, colors.blue)

    local status = _scanner.getStatus()
    local total = status.totalSlots
    local used = status.usedSlots
    local pct = total > 0 and math.floor(used / total * 100) or 0

    _draw.text(mon, 2, 3, "Overall", colors.white, colors.black)
    _draw.textRight(mon, 1, 3, w - 1, pct .. "%", colors.lightGray, colors.black)
    _draw.progressBar(mon, 2, 4, w - 2, used, total,
        pct > 90 and colors.red or pct > 70 and colors.yellow or colors.green,
        colors.gray)

    _draw.text(mon, 2, 6, string.format("%s / %s slots", formatCount(used), formatCount(total)), colors.lightGray, colors.black)
    _draw.text(mon, 2, 7, string.format("%d vaults connected", status.vaults), colors.lightGray, colors.black)
    _draw.text(mon, 2, 8, string.format("%d unique item types", status.uniqueTypes), colors.lightGray, colors.black)
end

-- ============================================================================
-- Panel: top_items
-- ============================================================================

local function panelTopItems(mon, w, h)
    _draw.header(mon, w, "Top Items", colors.white, colors.blue)

    local items = _scanner.getItems()
    local maxRows = h - 2

    if #items == 0 then
        _draw.text(mon, 2, 3, "No items", colors.lightGray, colors.black)
        return
    end

    local topCount = items[1] and items[1].count or 1

    for i = 1, math.min(#items, maxRows) do
        local item = items[i]
        local row = i + 1
        local bg = i % 2 == 0 and colors.gray or colors.black

        local countStr = formatCount(item.count)
        local nameW = w - #countStr - 4
        local name = item.displayName
        if #name > nameW then
            name = name:sub(1, nameW - 2) .. ".."
        end

        _draw.box(mon, 1, row, w, 1, bg)
        _draw.text(mon, 2, row, name, colors.white, bg)
        _draw.textRight(mon, 1, row, w - 1, countStr, colors.lime, bg)
    end
end

-- ============================================================================
-- Panel: low_stock
-- ============================================================================

local function panelLowStock(mon, w, h)
    _draw.header(mon, w, "Low Stock", colors.white, colors.red)

    local items = _scanner.getItems()
    local threshold = 16
    local lowItems = {}

    for _, item in ipairs(items) do
        if item.count <= threshold then
            table.insert(lowItems, item)
        end
    end

    table.sort(lowItems, function(a, b) return a.count < b.count end)

    local maxRows = h - 2

    if #lowItems == 0 then
        _draw.text(mon, 2, 3, "All stocked!", colors.green, colors.black)
        return
    end

    for i = 1, math.min(#lowItems, maxRows) do
        local item = lowItems[i]
        local row = i + 1
        local bg = i % 2 == 0 and colors.gray or colors.black

        local countStr = tostring(item.count)
        local nameW = w - #countStr - 4
        local name = item.displayName
        if #name > nameW then
            name = name:sub(1, nameW - 2) .. ".."
        end

        local countColor = item.count <= 4 and colors.red or colors.yellow
        _draw.box(mon, 1, row, w, 1, bg)
        _draw.text(mon, 2, row, name, colors.white, bg)
        _draw.textRight(mon, 1, row, w - 1, countStr, countColor, bg)
    end
end

-- ============================================================================
-- Panel: system_status
-- ============================================================================

local function panelSystemStatus(mon, w, h)
    _draw.header(mon, w, "System Status", colors.white, colors.cyan)

    local status = _scanner.getStatus()

    local rows = {
        { "Vaults", tostring(status.vaults), colors.white },
        { "Total Slots", formatCount(status.totalSlots), colors.white },
        { "Used Slots", formatCount(status.usedSlots), colors.white },
        { "Unique Types", tostring(status.uniqueTypes), colors.white },
        { "Scan Time", status.lastScanMs .. "ms", colors.lightGray },
        { "WS Connected", status.connected and "Yes" or "No", status.connected and colors.green or colors.red },
    }

    for i, row in ipairs(rows) do
        local y = i + 2
        if y > h then break end
        local bg = i % 2 == 0 and colors.gray or colors.black
        _draw.box(mon, 1, y, w, 1, bg)
        _draw.text(mon, 2, y, row[1], colors.lightGray, bg)
        _draw.textRight(mon, 1, y, w - 1, row[2], row[3], bg)
    end
end

-- ============================================================================
-- Panel registry
-- ============================================================================

local PANEL_REGISTRY = {
    recent_activity = panelRecentActivity,
    storage_fill = panelStorageFill,
    top_items = panelTopItems,
    low_stock = panelLowStock,
    system_status = panelSystemStatus,
}

local function renderPanel(mon, panelId)
    local w, h = mon.getSize()
    _draw.applyPalette(mon)
    _draw.clear(mon, colors.black)

    local panelFn = PANEL_REGISTRY[panelId]
    if panelFn then
        panelFn(mon, w, h)
    else
        _draw.text(mon, 2, 2, "Unknown panel:", colors.red, colors.black)
        _draw.text(mon, 2, 3, panelId or "nil", colors.white, colors.black)
    end
end

function panels.loop()
    while true do
        local panelConfig = _config.get("panels") or {}

        for monName, panelId in pairs(panelConfig) do
            local ok, mon = pcall(peripheral.wrap, monName)
            if ok and mon then
                mon.setTextScale(0.5)
                local termObj = mon
                renderPanel(termObj, panelId)
            end
        end

        sleep(1)
    end
end

return panels
```

- [ ] **Step 2: Verify and commit**

```bash
git add projects/storage-terminal/cc/panels.lua
git commit -m "feat: monitor panels — activity, storage fill, top items, low stock, system status"
```

---

## Task 5: CC main.lua + startup.lua

**Files:**
- Create: `projects/storage-terminal/cc/startup.lua`
- Create: `projects/storage-terminal/cc/main.lua`

- [ ] **Step 1: Create cc/startup.lua**

```lua
shell.run("main.lua")
```

- [ ] **Step 2: Create cc/main.lua**

```lua
local config = dofile("/config.lua")
local draw = dofile("/draw.lua")
local scanner = dofile("/scanner.lua")
local panels = dofile("/panels.lua")
local ws = dofile("/ws.lua")

config.load()
scanner.init(config)
panels.init(config, scanner, draw)
ws.init(config, scanner)

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.lightBlue)
print("=== Storage Terminal v2 ===")
term.setTextColor(colors.white)
print("Relay: " .. (config.get("relayUrl") or "not set"))
print("Output: " .. (config.get("outputInv") or "not set"))
print("")
print("Starting...")

parallel.waitForAll(
    scanner.loop,
    panels.loop,
    ws.loop
)
```

- [ ] **Step 3: Verify and commit**

```bash
git add projects/storage-terminal/cc/
git commit -m "feat: main entry point and startup — ties scanner, panels, ws together"
```

---

## Task 6: Bun relay server

**Files:**
- Create: `projects/storage-terminal/relay/package.json`
- Create: `projects/storage-terminal/relay/tsconfig.json`
- Create: `projects/storage-terminal/relay/index.ts`

- [ ] **Step 1: Create relay/package.json**

```json
{
  "name": "storage-terminal-relay",
  "version": "1.0.0",
  "scripts": {
    "dev": "bun run --watch index.ts",
    "start": "bun run index.ts"
  },
  "dependencies": {},
  "devDependencies": {
    "@types/bun": "latest"
  }
}
```

- [ ] **Step 2: Create relay/tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true,
    "types": ["bun"]
  }
}
```

- [ ] **Step 3: Create relay/index.ts**

```typescript
import { type ServerWebSocket } from "bun";
import { join } from "path";

const PORT = parseInt(process.env.PORT || "3001");

type Role = "cc" | "browser";
type WSData = { role: Role };

let ccSocket: ServerWebSocket<WSData> | null = null;
const browserSockets = new Set<ServerWebSocket<WSData>>();

const webDistPath = join(import.meta.dir, "..", "web", "dist");

const server = Bun.serve({
  port: PORT,

  async fetch(req, server) {
    const url = new URL(req.url);

    if (url.pathname === "/ws") {
      const role = (url.searchParams.get("role") as Role) || "browser";
      const upgraded = server.upgrade(req, { data: { role } });
      if (!upgraded) {
        return new Response("WebSocket upgrade failed", { status: 400 });
      }
      return undefined;
    }

    if (url.pathname === "/health") {
      return Response.json({
        status: "ok",
        cc: ccSocket !== null,
        browsers: browserSockets.size,
      });
    }

    let filePath = url.pathname === "/" ? "/index.html" : url.pathname;
    const file = Bun.file(join(webDistPath, filePath));
    if (await file.exists()) {
      return new Response(file);
    }

    const indexFile = Bun.file(join(webDistPath, "index.html"));
    if (await indexFile.exists()) {
      return new Response(indexFile);
    }

    return new Response("Not found", { status: 404 });
  },

  websocket: {
    open(ws: ServerWebSocket<WSData>) {
      if (ws.data.role === "cc") {
        if (ccSocket) {
          ccSocket.close(1000, "replaced");
        }
        ccSocket = ws;
        console.log("[relay] CC connected");
      } else {
        browserSockets.add(ws);
        console.log(`[relay] Browser connected (${browserSockets.size} total)`);
        if (!ccSocket) {
          ws.send(JSON.stringify({ type: "status", connected: false }));
        }
      }
    },

    message(ws: ServerWebSocket<WSData>, message: string | Buffer) {
      const raw = typeof message === "string" ? message : message.toString();

      if (ws.data.role === "cc") {
        for (const browser of browserSockets) {
          browser.send(raw);
        }
      } else {
        if (ccSocket) {
          ccSocket.send(raw);
        } else {
          ws.send(JSON.stringify({ type: "error", message: "Computer not connected" }));
        }
      }
    },

    close(ws: ServerWebSocket<WSData>) {
      if (ws.data.role === "cc") {
        ccSocket = null;
        console.log("[relay] CC disconnected");
        const msg = JSON.stringify({ type: "status", connected: false });
        for (const browser of browserSockets) {
          browser.send(msg);
        }
      } else {
        browserSockets.delete(ws);
        console.log(`[relay] Browser disconnected (${browserSockets.size} total)`);
      }
    },
  },
});

console.log(`[relay] Listening on http://localhost:${server.port}`);
```

- [ ] **Step 4: Install dependencies and verify**

```bash
cd projects/storage-terminal/relay && bun install
```

```bash
bun run index.ts &
sleep 1
curl http://localhost:3001/health
kill %1
```

Expected: `{"status":"ok","cc":false,"browsers":0}`

- [ ] **Step 5: Commit**

```bash
cd /home/marlon/Code/Lua/FriendsCC
git add projects/storage-terminal/relay/
git commit -m "feat: Bun WebSocket relay server"
```

---

## Task 7: Svelte project setup + types + stores + ws

**Files:**
- Create: `projects/storage-terminal/web/package.json`
- Create: `projects/storage-terminal/web/vite.config.ts`
- Create: `projects/storage-terminal/web/tsconfig.json`
- Create: `projects/storage-terminal/web/index.html`
- Create: `projects/storage-terminal/web/src/main.ts`
- Create: `projects/storage-terminal/web/src/lib/types.ts`
- Create: `projects/storage-terminal/web/src/lib/store.ts`
- Create: `projects/storage-terminal/web/src/lib/ws.ts`
- Create: `projects/storage-terminal/web/src/App.svelte`

- [ ] **Step 1: Create web/package.json**

```json
{
  "name": "storage-terminal-web",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "devDependencies": {
    "@sveltejs/vite-plugin-svelte": "^5.0.0",
    "svelte": "^5.0.0",
    "typescript": "^5.7.0",
    "vite": "^6.0.0"
  }
}
```

- [ ] **Step 2: Create web/vite.config.ts**

```typescript
import { defineConfig } from "vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

export default defineConfig({
  plugins: [svelte()],
});
```

- [ ] **Step 3: Create web/tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true,
    "types": ["svelte"]
  },
  "include": ["src/**/*"]
}
```

- [ ] **Step 4: Create web/index.html**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Storage Terminal</title>
</head>
<body>
  <div id="app"></div>
  <script type="module" src="/src/main.ts"></script>
</body>
</html>
```

- [ ] **Step 5: Create web/src/lib/types.ts**

```typescript
export interface Item {
  key: string;
  name: string;
  displayName: string;
  count: number;
  mod: string;
  enchantments?: { name: string; level: number }[];
  customName?: string;
  damage?: number;
  maxDamage?: number;
  nbt?: string;
  tags?: string[];
}

export interface ActivityEntry {
  action: "add" | "remove" | "extract";
  item: string;
  count: number;
  timestamp: number;
}

export interface SystemStatus {
  connected: boolean;
  vaults: number;
  totalSlots: number;
  usedSlots: number;
  totalItems: number;
  uniqueTypes: number;
  lastScanMs: number;
}

export interface PanelConfig {
  [monitorName: string]: string;
}

export interface Config {
  panels: PanelConfig;
  outputInv: string;
  scanInterval: number;
  relayUrl: string;
}

export type ServerMessage =
  | { type: "inventory"; items: Item[] }
  | { type: "inventory_delta"; added: Item[]; removed: Item[]; changed: { key: string; count: number }[] }
  | { type: "config"; panels: PanelConfig; outputInv: string; scanInterval: number; relayUrl: string }
  | { type: "activity"; entry: ActivityEntry }
  | { type: "status"; connected: boolean; vaults: number; totalSlots: number; usedSlots: number; totalItems: number; uniqueTypes: number; lastScanMs: number }
  | { type: "extract_result"; itemKey: string; requested: number; extracted: number }
  | { type: "error"; message: string };

export type ClientMessage =
  | { type: "extract"; itemKey: string; count: number }
  | { type: "config_update"; panels?: PanelConfig; outputInv?: string; scanInterval?: number }
  | { type: "refresh" };
```

- [ ] **Step 6: Create web/src/lib/store.ts**

```typescript
import { writable } from "svelte/store";
import type { Item, SystemStatus, Config, ActivityEntry } from "./types";

export const items = writable<Item[]>([]);
export const connected = writable(false);
export const status = writable<SystemStatus>({
  connected: false,
  vaults: 0,
  totalSlots: 0,
  usedSlots: 0,
  totalItems: 0,
  uniqueTypes: 0,
  lastScanMs: 0,
});
export const config = writable<Config>({
  panels: {},
  outputInv: "",
  scanInterval: 5,
  relayUrl: "",
});
export const activity = writable<ActivityEntry[]>([]);
export const selectedItem = writable<Item | null>(null);
```

- [ ] **Step 7: Create web/src/lib/ws.ts**

```typescript
import { items, connected, status, config, activity } from "./store";
import type { ServerMessage, ClientMessage } from "./types";

let socket: WebSocket | null = null;
let backoff = 1000;

function getWsUrl(): string {
  const protocol = location.protocol === "https:" ? "wss:" : "ws:";
  return `${protocol}//${location.host}/ws?role=browser`;
}

function handleMessage(msg: ServerMessage) {
  switch (msg.type) {
    case "inventory":
      items.set(msg.items);
      connected.set(true);
      break;
    case "status":
      status.set({
        connected: msg.connected,
        vaults: msg.vaults ?? 0,
        totalSlots: msg.totalSlots ?? 0,
        usedSlots: msg.usedSlots ?? 0,
        totalItems: msg.totalItems ?? 0,
        uniqueTypes: msg.uniqueTypes ?? 0,
        lastScanMs: msg.lastScanMs ?? 0,
      });
      if (msg.connected !== undefined) {
        connected.set(msg.connected);
      }
      break;
    case "config":
      config.set({
        panels: msg.panels ?? {},
        outputInv: msg.outputInv ?? "",
        scanInterval: msg.scanInterval ?? 5,
        relayUrl: msg.relayUrl ?? "",
      });
      break;
    case "activity":
      activity.update((a) => {
        const updated = [msg.entry, ...a];
        return updated.slice(0, 100);
      });
      break;
    case "extract_result":
      break;
    case "error":
      console.error("[ws] Error:", msg.message);
      break;
  }
}

export function connect() {
  const url = getWsUrl();
  socket = new WebSocket(url);

  socket.onopen = () => {
    console.log("[ws] Connected");
    connected.set(true);
    backoff = 1000;
  };

  socket.onmessage = (event) => {
    try {
      const msg = JSON.parse(event.data) as ServerMessage;
      handleMessage(msg);
    } catch (e) {
      console.error("[ws] Parse error:", e);
    }
  };

  socket.onclose = () => {
    console.log("[ws] Disconnected, reconnecting in", backoff, "ms");
    connected.set(false);
    socket = null;
    setTimeout(connect, backoff);
    backoff = Math.min(backoff * 2, 30000);
  };

  socket.onerror = () => {
    socket?.close();
  };
}

export function send(msg: ClientMessage) {
  if (socket && socket.readyState === WebSocket.OPEN) {
    socket.send(JSON.stringify(msg));
  }
}
```

- [ ] **Step 8: Create web/src/main.ts**

```typescript
import App from "./App.svelte";
import { mount } from "svelte";
import { connect } from "./lib/ws";

const app = mount(App, { target: document.getElementById("app")! });

connect();

export default app;
```

- [ ] **Step 9: Create web/src/App.svelte (placeholder)**

```svelte
<script lang="ts">
  import { connected, items, status } from "./lib/store";
</script>

<main>
  <header>
    <h1>Storage Terminal</h1>
    <span class="status" class:connected={$connected}>
      {$connected ? "Connected" : "Disconnected"}
    </span>
  </header>
  <p>{$items.length} items, {$status.uniqueTypes} types</p>
</main>

<style>
  :global(body) {
    margin: 0;
    background: #1a1b26;
    color: #c0caf5;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  }
  main {
    padding: 1rem;
  }
  header {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem 1rem;
    background: #24283b;
    border-bottom: 1px solid #3b4261;
  }
  h1 {
    margin: 0;
    font-size: 1.2rem;
  }
  .status {
    font-size: 0.8rem;
    padding: 0.2rem 0.5rem;
    border-radius: 4px;
    background: #f7768e33;
    color: #f7768e;
  }
  .status.connected {
    background: #9ece6a33;
    color: #9ece6a;
  }
</style>
```

- [ ] **Step 10: Install dependencies and verify**

```bash
cd projects/storage-terminal/web && bun install
bun run build
```

Expected: builds successfully to `web/dist/`.

- [ ] **Step 11: Commit**

```bash
cd /home/marlon/Code/Lua/FriendsCC
git add projects/storage-terminal/web/
git commit -m "feat: Svelte project setup with types, stores, WebSocket client"
```

---

## Task 8: Svelte components — ItemIcon, SearchBar, FilterBar

**Files:**
- Create: `projects/storage-terminal/web/src/components/ItemIcon.svelte`
- Create: `projects/storage-terminal/web/src/components/SearchBar.svelte`
- Create: `projects/storage-terminal/web/src/components/FilterBar.svelte`

- [ ] **Step 1: Create ItemIcon.svelte**

```svelte
<script lang="ts">
  const { name, mod }: { name: string; mod: string } = $props();

  const MOD_COLORS: Record<string, string> = {
    minecraft: "#9ece6a",
    create: "#ff9e64",
    computercraft: "#e0af68",
    ae2: "#7dcfff",
    mekanism: "#9ece6a",
  };

  const letter = $derived((name.split(":")[1] || name)[0]?.toUpperCase() || "?");
  const color = $derived(MOD_COLORS[mod] || "#7aa2f7");
</script>

<div class="icon" style="background: {color}22; border-color: {color}">
  <span style="color: {color}">{letter}</span>
</div>

<style>
  .icon {
    width: 36px;
    height: 36px;
    border-radius: 6px;
    border: 1px solid;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  span {
    font-size: 1rem;
    font-weight: 700;
  }
</style>
```

- [ ] **Step 2: Create SearchBar.svelte**

```svelte
<script lang="ts">
  let { value = $bindable("") }: { value: string } = $props();
  let timeout: ReturnType<typeof setTimeout>;

  function onInput(e: Event) {
    const target = e.target as HTMLInputElement;
    clearTimeout(timeout);
    timeout = setTimeout(() => {
      value = target.value;
    }, 200);
  }

  function clear() {
    value = "";
  }
</script>

<div class="search">
  <input
    type="text"
    placeholder="Search items..."
    value={value}
    oninput={onInput}
  />
  {#if value}
    <button onclick={clear}>✕</button>
  {/if}
</div>

<style>
  .search {
    position: relative;
    display: flex;
    gap: 0.5rem;
  }
  input {
    flex: 1;
    padding: 0.5rem 0.75rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
    font-size: 0.9rem;
    outline: none;
  }
  input:focus {
    border-color: #7aa2f7;
  }
  input::placeholder {
    color: #565f89;
  }
  button {
    background: none;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #565f89;
    padding: 0.5rem;
    cursor: pointer;
  }
  button:hover {
    color: #c0caf5;
    border-color: #7aa2f7;
  }
</style>
```

- [ ] **Step 3: Create FilterBar.svelte**

```svelte
<script lang="ts">
  import { items } from "../lib/store";
  import type { Item } from "../lib/types";

  let { activeMods = $bindable<string[]>([]), showEnchanted = $bindable(false), showRenamed = $bindable(false), showDamaged = $bindable(false), sortBy = $bindable("count") }: {
    activeMods: string[];
    showEnchanted: boolean;
    showRenamed: boolean;
    showDamaged: boolean;
    sortBy: string;
  } = $props();

  const allMods = $derived(
    [...new Set($items.map((i: Item) => i.mod))].sort()
  );

  function toggleMod(mod: string) {
    if (activeMods.includes(mod)) {
      activeMods = activeMods.filter((m) => m !== mod);
    } else {
      activeMods = [...activeMods, mod];
    }
  }
</script>

<div class="filters">
  <div class="chips">
    {#each allMods as mod}
      <button
        class="chip"
        class:active={activeMods.includes(mod)}
        onclick={() => toggleMod(mod)}
      >
        {mod}
      </button>
    {/each}
  </div>

  <div class="chips">
    <button class="chip" class:active={showEnchanted} onclick={() => showEnchanted = !showEnchanted}>Enchanted</button>
    <button class="chip" class:active={showRenamed} onclick={() => showRenamed = !showRenamed}>Renamed</button>
    <button class="chip" class:active={showDamaged} onclick={() => showDamaged = !showDamaged}>Damaged</button>
  </div>

  <select bind:value={sortBy}>
    <option value="count">Count (high→low)</option>
    <option value="name">Name (A→Z)</option>
  </select>
</div>

<style>
  .filters {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }
  .chips {
    display: flex;
    flex-wrap: wrap;
    gap: 0.25rem;
  }
  .chip {
    padding: 0.25rem 0.5rem;
    background: #24283b;
    border: 1px solid #3b4261;
    border-radius: 4px;
    color: #565f89;
    font-size: 0.75rem;
    cursor: pointer;
  }
  .chip:hover {
    border-color: #7aa2f7;
    color: #c0caf5;
  }
  .chip.active {
    background: #7aa2f733;
    border-color: #7aa2f7;
    color: #7aa2f7;
  }
  select {
    padding: 0.4rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
    font-size: 0.8rem;
  }
</style>
```

- [ ] **Step 4: Verify and commit**

```bash
cd projects/storage-terminal/web && bun run build
```

```bash
cd /home/marlon/Code/Lua/FriendsCC
git add projects/storage-terminal/web/src/components/
git commit -m "feat: ItemIcon, SearchBar, FilterBar components"
```

---

## Task 9: Svelte components — ItemList, ItemDetail, Settings

**Files:**
- Create: `projects/storage-terminal/web/src/components/ItemList.svelte`
- Create: `projects/storage-terminal/web/src/components/ItemDetail.svelte`
- Create: `projects/storage-terminal/web/src/components/Settings.svelte`

- [ ] **Step 1: Create ItemList.svelte**

```svelte
<script lang="ts">
  import type { Item } from "../lib/types";
  import ItemIcon from "./ItemIcon.svelte";
  import { selectedItem } from "../lib/store";

  let { items: filteredItems }: { items: Item[] } = $props();

  function formatCount(n: number): string {
    if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + "M";
    if (n >= 1_000) return (n / 1_000).toFixed(1) + "k";
    return String(n);
  }

  function select(item: Item) {
    selectedItem.set(item);
  }
</script>

{#if filteredItems.length === 0}
  <div class="empty">No items found</div>
{:else}
  <div class="grid">
    {#each filteredItems as item (item.key)}
      <button class="card" class:enchanted={item.enchantments?.length} class:renamed={!!item.customName} onclick={() => select(item)}>
        <ItemIcon name={item.name} mod={item.mod} />
        <div class="info">
          <span class="name">{item.displayName}</span>
          {#if item.customName}
            <span class="original">{item.name.split(":")[1]?.replace(/_/g, " ")}</span>
          {/if}
          <span class="mod">{item.mod}</span>
        </div>
        <span class="count">{formatCount(item.count)}</span>
      </button>
    {/each}
  </div>
{/if}

<style>
  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 0.5rem;
  }
  .card {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem;
    background: #24283b;
    border: 1px solid #3b4261;
    border-radius: 8px;
    cursor: pointer;
    text-align: left;
    color: inherit;
    font: inherit;
    transition: border-color 0.15s;
  }
  .card:hover {
    border-color: #7aa2f7;
  }
  .card.enchanted {
    border-left: 3px solid #bb9af7;
  }
  .info {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
  }
  .name {
    font-size: 0.85rem;
    color: #c0caf5;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .card.renamed .name {
    font-style: italic;
  }
  .original {
    font-size: 0.7rem;
    color: #565f89;
  }
  .mod {
    font-size: 0.65rem;
    color: #565f89;
  }
  .count {
    font-size: 1rem;
    font-weight: 700;
    color: #9ece6a;
    white-space: nowrap;
  }
  .empty {
    text-align: center;
    padding: 2rem;
    color: #565f89;
  }
</style>
```

- [ ] **Step 2: Create ItemDetail.svelte**

```svelte
<script lang="ts">
  import { selectedItem } from "../lib/store";
  import { send } from "../lib/ws";
  import ItemIcon from "./ItemIcon.svelte";

  let extractAmount = $state("");
  let extracting = $state(false);
  let message = $state("");

  function close() {
    selectedItem.set(null);
    extractAmount = "";
    message = "";
  }

  function formatCount(n: number): string {
    if (n >= 1_000_000) return (n / 1_000_000).toFixed(1) + "M";
    if (n >= 1_000) return (n / 1_000).toFixed(1) + "k";
    return String(n);
  }

  function extract(amount: number) {
    if (!$selectedItem || amount <= 0) return;
    extracting = true;
    message = "";
    send({ type: "extract", itemKey: $selectedItem.key, count: amount });
    setTimeout(() => {
      extracting = false;
      message = `Requested ${amount} items`;
    }, 500);
  }

  function extractCustom() {
    const n = parseInt(extractAmount);
    if (n > 0) extract(n);
  }

  function extractAll() {
    if ($selectedItem) extract($selectedItem.count);
  }
</script>

{#if $selectedItem}
  <div class="overlay" onclick={close}></div>
  <aside class="panel">
    <div class="panel-header">
      <h2>Item Detail</h2>
      <button class="close" onclick={close}>✕</button>
    </div>

    <div class="detail-body">
      <div class="item-header">
        <ItemIcon name={$selectedItem.name} mod={$selectedItem.mod} />
        <div>
          <h3>{$selectedItem.displayName}</h3>
          <p class="registry">{$selectedItem.name}</p>
          <p class="mod">{$selectedItem.mod}</p>
        </div>
      </div>

      <div class="stat">
        <span>Total Count</span>
        <strong>{formatCount($selectedItem.count)}</strong>
      </div>

      {#if $selectedItem.enchantments?.length}
        <div class="section">
          <h4>Enchantments</h4>
          {#each $selectedItem.enchantments as ench}
            <span class="ench">{ench.name} {ench.level}</span>
          {/each}
        </div>
      {/if}

      {#if $selectedItem.damage != null && $selectedItem.maxDamage}
        <div class="section">
          <h4>Durability</h4>
          <div class="durability-bar">
            <div class="fill" style="width: {((($selectedItem.maxDamage - $selectedItem.damage) / $selectedItem.maxDamage) * 100)}%"></div>
          </div>
          <p class="durability-text">{$selectedItem.maxDamage - $selectedItem.damage} / {$selectedItem.maxDamage}</p>
        </div>
      {/if}

      <div class="extract-section">
        <h4>Extract</h4>
        <div class="extract-row">
          <input
            type="number"
            placeholder="Amount"
            bind:value={extractAmount}
            min="1"
            max={$selectedItem.count}
          />
          <button class="btn primary" onclick={extractCustom} disabled={extracting}>Take</button>
          <button class="btn secondary" onclick={extractAll} disabled={extracting}>All</button>
        </div>
        {#if message}
          <p class="message">{message}</p>
        {/if}
      </div>
    </div>
  </aside>
{/if}

<style>
  .overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 10;
  }
  .panel {
    position: fixed;
    top: 0;
    right: 0;
    width: 320px;
    height: 100vh;
    background: #24283b;
    border-left: 1px solid #3b4261;
    z-index: 11;
    display: flex;
    flex-direction: column;
    animation: slideIn 0.2s ease;
  }
  @keyframes slideIn {
    from { transform: translateX(100%); }
    to { transform: translateX(0); }
  }
  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #3b4261;
  }
  .panel-header h2 {
    margin: 0;
    font-size: 1rem;
  }
  .close {
    background: none;
    border: none;
    color: #565f89;
    font-size: 1.2rem;
    cursor: pointer;
  }
  .close:hover { color: #c0caf5; }
  .detail-body {
    padding: 1rem;
    overflow-y: auto;
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }
  .item-header {
    display: flex;
    gap: 0.75rem;
    align-items: flex-start;
  }
  .item-header h3 {
    margin: 0;
    font-size: 1rem;
    color: #c0caf5;
  }
  .registry {
    font-size: 0.75rem;
    color: #565f89;
    margin: 0.2rem 0;
  }
  .mod {
    font-size: 0.7rem;
    color: #565f89;
    margin: 0;
  }
  .stat {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem;
    background: #1a1b26;
    border-radius: 6px;
  }
  .stat strong {
    color: #9ece6a;
  }
  .section h4 {
    margin: 0 0 0.4rem;
    font-size: 0.8rem;
    color: #565f89;
    text-transform: uppercase;
  }
  .ench {
    display: inline-block;
    padding: 0.15rem 0.4rem;
    background: #bb9af722;
    border: 1px solid #bb9af755;
    border-radius: 4px;
    color: #bb9af7;
    font-size: 0.75rem;
    margin: 0.15rem;
  }
  .durability-bar {
    height: 6px;
    background: #3b4261;
    border-radius: 3px;
    overflow: hidden;
  }
  .fill {
    height: 100%;
    background: #9ece6a;
    border-radius: 3px;
    transition: width 0.3s;
  }
  .durability-text {
    font-size: 0.75rem;
    color: #565f89;
    margin: 0.25rem 0 0;
  }
  .extract-section {
    margin-top: auto;
    padding-top: 1rem;
    border-top: 1px solid #3b4261;
  }
  .extract-row {
    display: flex;
    gap: 0.5rem;
  }
  .extract-row input {
    flex: 1;
    padding: 0.5rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
  }
  .btn {
    padding: 0.5rem 0.75rem;
    border: none;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
    font-size: 0.85rem;
  }
  .btn.primary {
    background: #9ece6a;
    color: #1a1b26;
  }
  .btn.secondary {
    background: #7aa2f7;
    color: #1a1b26;
  }
  .btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .message {
    font-size: 0.8rem;
    color: #9ece6a;
    margin: 0.5rem 0 0;
  }
</style>
```

- [ ] **Step 3: Create Settings.svelte**

```svelte
<script lang="ts">
  import { config } from "../lib/store";
  import { send } from "../lib/ws";

  let { open = $bindable(false) }: { open: boolean } = $props();

  let outputInv = $state($config.outputInv);
  let scanInterval = $state($config.scanInterval);

  const PANEL_TYPES = [
    { value: "", label: "None" },
    { value: "recent_activity", label: "Recent Activity" },
    { value: "storage_fill", label: "Storage Usage" },
    { value: "top_items", label: "Top Items" },
    { value: "low_stock", label: "Low Stock" },
    { value: "system_status", label: "System Status" },
  ];

  function save() {
    send({
      type: "config_update",
      outputInv,
      scanInterval,
      panels: $config.panels,
    });
    open = false;
  }

  function setPanelType(monitor: string, panelType: string) {
    config.update((c) => {
      const panels = { ...c.panels };
      if (panelType) {
        panels[monitor] = panelType;
      } else {
        delete panels[monitor];
      }
      return { ...c, panels };
    });
  }
</script>

{#if open}
  <div class="overlay" onclick={() => open = false}></div>
  <div class="modal">
    <div class="modal-header">
      <h2>Settings</h2>
      <button class="close" onclick={() => open = false}>✕</button>
    </div>

    <div class="modal-body">
      <label>
        Output Inventory
        <input type="text" bind:value={outputInv} placeholder="minecraft:chest_0" />
      </label>

      <label>
        Scan Interval (seconds)
        <input type="number" bind:value={scanInterval} min="1" max="60" />
      </label>

      <h3>Monitor Panels</h3>
      {#each Object.entries($config.panels) as [monitor, panel]}
        <div class="panel-row">
          <span class="monitor-name">{monitor}</span>
          <select value={panel} onchange={(e) => setPanelType(monitor, (e.target as HTMLSelectElement).value)}>
            {#each PANEL_TYPES as pt}
              <option value={pt.value}>{pt.label}</option>
            {/each}
          </select>
        </div>
      {/each}

      <button class="btn save" onclick={save}>Save</button>
    </div>
  </div>
{/if}

<style>
  .overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 20;
  }
  .modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 400px;
    max-height: 80vh;
    background: #24283b;
    border: 1px solid #3b4261;
    border-radius: 12px;
    z-index: 21;
    overflow: hidden;
  }
  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.75rem 1rem;
    border-bottom: 1px solid #3b4261;
  }
  .modal-header h2 { margin: 0; font-size: 1rem; }
  .close {
    background: none;
    border: none;
    color: #565f89;
    font-size: 1.2rem;
    cursor: pointer;
  }
  .modal-body {
    padding: 1rem;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    overflow-y: auto;
  }
  label {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
    font-size: 0.85rem;
    color: #565f89;
  }
  input, select {
    padding: 0.5rem;
    background: #1a1b26;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #c0caf5;
    font-size: 0.85rem;
  }
  h3 {
    margin: 0.5rem 0 0;
    font-size: 0.85rem;
    color: #565f89;
    text-transform: uppercase;
  }
  .panel-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 0.5rem;
  }
  .monitor-name {
    font-size: 0.8rem;
    color: #c0caf5;
  }
  .btn.save {
    margin-top: 0.5rem;
    padding: 0.5rem;
    background: #9ece6a;
    color: #1a1b26;
    border: none;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
  }
</style>
```

- [ ] **Step 4: Verify and commit**

```bash
cd projects/storage-terminal/web && bun run build
```

```bash
cd /home/marlon/Code/Lua/FriendsCC
git add projects/storage-terminal/web/src/components/
git commit -m "feat: ItemList, ItemDetail, Settings components"
```

---

## Task 10: Full App.svelte layout

**Files:**
- Modify: `projects/storage-terminal/web/src/App.svelte`

- [ ] **Step 1: Replace App.svelte with full layout**

```svelte
<script lang="ts">
  import { connected, items, status } from "./lib/store";
  import { send } from "./lib/ws";
  import type { Item } from "./lib/types";
  import SearchBar from "./components/SearchBar.svelte";
  import FilterBar from "./components/FilterBar.svelte";
  import ItemList from "./components/ItemList.svelte";
  import ItemDetail from "./components/ItemDetail.svelte";
  import Settings from "./components/Settings.svelte";

  let search = $state("");
  let activeMods = $state<string[]>([]);
  let showEnchanted = $state(false);
  let showRenamed = $state(false);
  let showDamaged = $state(false);
  let sortBy = $state("count");
  let settingsOpen = $state(false);

  const filtered = $derived.by(() => {
    let result = $items;

    if (search) {
      const q = search.toLowerCase();
      result = result.filter(
        (i: Item) =>
          i.displayName.toLowerCase().includes(q) ||
          i.name.toLowerCase().includes(q)
      );
    }

    if (activeMods.length > 0) {
      result = result.filter((i: Item) => activeMods.includes(i.mod));
    }
    if (showEnchanted) {
      result = result.filter((i: Item) => i.enchantments && i.enchantments.length > 0);
    }
    if (showRenamed) {
      result = result.filter((i: Item) => !!i.customName);
    }
    if (showDamaged) {
      result = result.filter((i: Item) => i.damage != null && i.damage > 0);
    }

    if (sortBy === "name") {
      result = [...result].sort((a: Item, b: Item) => a.displayName.localeCompare(b.displayName));
    }

    return result;
  });

  function refresh() {
    send({ type: "refresh" });
  }
</script>

<div class="app">
  <header>
    <h1>Storage Terminal</h1>
    <div class="header-right">
      <span class="stat">{$status.uniqueTypes} types · {$status.vaults} vaults</span>
      <button class="icon-btn" onclick={refresh} title="Refresh">↻</button>
      <button class="icon-btn" onclick={() => settingsOpen = true} title="Settings">⚙</button>
      <span class="status-dot" class:connected={$connected} title={$connected ? "Connected" : "Disconnected"}></span>
    </div>
  </header>

  <div class="layout">
    <aside class="sidebar">
      <SearchBar bind:value={search} />
      <FilterBar
        bind:activeMods
        bind:showEnchanted
        bind:showRenamed
        bind:showDamaged
        bind:sortBy
      />
    </aside>

    <main>
      <ItemList items={filtered} />
    </main>
  </div>

  <ItemDetail />
  <Settings bind:open={settingsOpen} />
</div>

<style>
  :global(*) {
    box-sizing: border-box;
  }
  :global(body) {
    margin: 0;
    background: #1a1b26;
    color: #c0caf5;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  }
  .app {
    display: flex;
    flex-direction: column;
    height: 100vh;
  }
  header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0.5rem 1rem;
    background: #24283b;
    border-bottom: 1px solid #3b4261;
    flex-shrink: 0;
  }
  h1 {
    margin: 0;
    font-size: 1.1rem;
  }
  .header-right {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }
  .stat {
    font-size: 0.75rem;
    color: #565f89;
  }
  .icon-btn {
    background: none;
    border: 1px solid #3b4261;
    border-radius: 6px;
    color: #565f89;
    padding: 0.3rem 0.5rem;
    cursor: pointer;
    font-size: 1rem;
  }
  .icon-btn:hover {
    color: #c0caf5;
    border-color: #7aa2f7;
  }
  .status-dot {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #f7768e;
  }
  .status-dot.connected {
    background: #9ece6a;
  }
  .layout {
    display: flex;
    flex: 1;
    overflow: hidden;
  }
  .sidebar {
    width: 240px;
    padding: 0.75rem;
    border-right: 1px solid #3b4261;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    overflow-y: auto;
    flex-shrink: 0;
  }
  main {
    flex: 1;
    padding: 0.75rem;
    overflow-y: auto;
  }
</style>
```

- [ ] **Step 2: Verify build**

```bash
cd projects/storage-terminal/web && bun run build
```

- [ ] **Step 3: Commit**

```bash
cd /home/marlon/Code/Lua/FriendsCC
git add projects/storage-terminal/web/src/App.svelte
git commit -m "feat: full App layout with sidebar, header, filtering, and settings"
```

---

## Task 11: Install script + gitignore updates

**Files:**
- Create: `projects/storage-terminal/install.lua`
- Modify: `.gitignore`

- [ ] **Step 1: Create install.lua**

```lua
local repo = "https://raw.githubusercontent.com/OrigamingWasTaken/FriendsCC/main"

local files = {
    { remote = "projects/storage-terminal/cc/config.lua", path = "/config.lua" },
    { remote = "projects/storage-terminal/cc/draw.lua", path = "/draw.lua" },
    { remote = "projects/storage-terminal/cc/scanner.lua", path = "/scanner.lua" },
    { remote = "projects/storage-terminal/cc/ws.lua", path = "/ws.lua" },
    { remote = "projects/storage-terminal/cc/panels.lua", path = "/panels.lua" },
    { remote = "projects/storage-terminal/cc/main.lua", path = "/main.lua" },
    { remote = "projects/storage-terminal/cc/startup.lua", path = "/startup.lua" },
}

for _, f in ipairs(files) do
    if fs.exists(f.path) then
        fs.delete(f.path)
    end
    print("Downloading " .. f.path)
    shell.run("wget", repo .. "/" .. f.remote, f.path)
end

print("")
print("Done! Edit /config.lua to set relayUrl and outputInv.")
print("Then run: reboot")
```

- [ ] **Step 2: Update .gitignore**

Add to `.gitignore`:
```
# Node/Bun
node_modules/
dist/
bun.lockb
```

- [ ] **Step 3: Commit**

```bash
git add projects/storage-terminal/install.lua .gitignore
git commit -m "feat: in-game installer script and gitignore updates"
```

---

## Task 12: Integration verification

- [ ] **Step 1: Verify CC file structure**

```bash
ls projects/storage-terminal/cc/
```

Expected: `config.lua  draw.lua  main.lua  panels.lua  scanner.lua  startup.lua  ws.lua`

- [ ] **Step 2: Verify relay starts**

```bash
cd projects/storage-terminal/relay && timeout 3 bun run index.ts 2>&1 || true
```

Expected: `[relay] Listening on http://localhost:3001`

- [ ] **Step 3: Verify web builds**

```bash
cd projects/storage-terminal/web && bun run build && ls dist/
```

Expected: `dist/` contains `index.html` and JS/CSS assets.

- [ ] **Step 4: Verify full structure**

```bash
find projects/storage-terminal/ -type f | grep -v node_modules | grep -v dist | grep -v bun.lockb | sort
```

Expected:
```
projects/storage-terminal/CLAUDE.md
projects/storage-terminal/cc/config.lua
projects/storage-terminal/cc/draw.lua
projects/storage-terminal/cc/main.lua
projects/storage-terminal/cc/panels.lua
projects/storage-terminal/cc/scanner.lua
projects/storage-terminal/cc/startup.lua
projects/storage-terminal/cc/ws.lua
projects/storage-terminal/install.lua
projects/storage-terminal/relay/index.ts
projects/storage-terminal/relay/package.json
projects/storage-terminal/relay/tsconfig.json
projects/storage-terminal/web/index.html
projects/storage-terminal/web/package.json
projects/storage-terminal/web/src/App.svelte
projects/storage-terminal/web/src/components/FilterBar.svelte
projects/storage-terminal/web/src/components/ItemDetail.svelte
projects/storage-terminal/web/src/components/ItemIcon.svelte
projects/storage-terminal/web/src/components/ItemList.svelte
projects/storage-terminal/web/src/components/SearchBar.svelte
projects/storage-terminal/web/src/components/Settings.svelte
projects/storage-terminal/web/src/lib/store.ts
projects/storage-terminal/web/src/lib/types.ts
projects/storage-terminal/web/src/lib/ws.ts
projects/storage-terminal/web/src/main.ts
projects/storage-terminal/web/tsconfig.json
projects/storage-terminal/web/vite.config.ts
```

- [ ] **Step 5: Push**

```bash
git push
```
