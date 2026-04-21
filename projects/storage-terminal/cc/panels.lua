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

        _draw.box(mon, 1, row, w, 1, bg)
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

local function panelStorageFill(mon, w, h)
    _draw.header(mon, w, "Storage Usage", colors.white, colors.blue)

    local status = _scanner.getStatus()
    local total = status.totalSlots
    local used = status.usedSlots
    local pct = total > 0 and math.floor(used / total * 100) or 0

    _draw.text(mon, 2, 3, "Overall", colors.white, colors.black)
    _draw.textRight(mon, 1, 3, w - 1, pct .. "%", colors.lightGray, colors.black)

    local barColor = colors.green
    if pct > 90 then barColor = colors.red
    elseif pct > 70 then barColor = colors.yellow end
    _draw.progressBar(mon, 2, 4, w - 2, used, total, barColor, colors.gray)

    _draw.text(mon, 2, 6, string.format("%s / %s slots", formatCount(used), formatCount(total)), colors.lightGray, colors.black)
    _draw.text(mon, 2, 7, string.format("%d vaults connected", status.vaults), colors.lightGray, colors.black)
    _draw.text(mon, 2, 8, string.format("%d unique item types", status.uniqueTypes), colors.lightGray, colors.black)
end

local function panelTopItems(mon, w, h)
    _draw.header(mon, w, "Top Items", colors.white, colors.blue)

    local items = _scanner.getItems()
    local maxRows = h - 2

    if #items == 0 then
        _draw.text(mon, 2, 3, "No items", colors.lightGray, colors.black)
        return
    end

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
                renderPanel(mon, panelId)
            end
        end

        sleep(1)
    end
end

return panels
