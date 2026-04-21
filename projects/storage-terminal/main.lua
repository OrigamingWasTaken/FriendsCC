local basalt = require("basalt")
local log = dofile("/lib/log.lua")

log.init("/storage-terminal.log")

-- Config: change these to match your setup
local OUTPUT_INV = "minecraft:chest_0"
local SCAN_INTERVAL = 5
local ITEMS_PER_PAGE = 0

-- State
local allItems = {}
local filteredItems = {}
local currentPage = 1
local totalPages = 1
local waitingForInput = false

local CATEGORY_COLORS = {
    ["minecraft:"] = colors.white,
    ["create:"] = colors.orange,
    ["computercraft:"] = colors.yellow,
    ["ae2:"] = colors.cyan,
    ["mekanism:"] = colors.green,
}

local function getItemColor(name)
    for prefix, color in pairs(CATEGORY_COLORS) do
        if name:sub(1, #prefix) == prefix then
            return color
        end
    end
    return colors.lightGray
end

local function shortName(fullName)
    local name = fullName:match(":(.+)") or fullName
    name = name:gsub("_", " ")
    return name:sub(1, 1):upper() .. name:sub(2)
end

local function formatCount(n)
    if n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fk", n / 1000)
    end
    return tostring(n)
end

local function scanInventories()
    local inventories = {}
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        if peripheral.hasType(name, "inventory") then
            if name ~= OUTPUT_INV then
                table.insert(inventories, name)
            end
        end
    end
    return inventories
end

local function aggregateItems(inventories)
    local itemMap = {}

    for _, invName in ipairs(inventories) do
        local ok, contents = pcall(peripheral.call, invName, "list")
        if ok and contents then
            for slot, item in pairs(contents) do
                local key = item.name .. (item.nbt or "")
                if not itemMap[key] then
                    local detail = peripheral.call(invName, "getItemDetail", slot)
                    itemMap[key] = {
                        name = item.name,
                        displayName = detail and detail.displayName or shortName(item.name),
                        count = 0,
                        sources = {},
                    }
                end
                itemMap[key].count = itemMap[key].count + item.count
                table.insert(itemMap[key].sources, {
                    inv = invName,
                    slot = slot,
                    count = item.count,
                })
            end
        end
    end

    local items = {}
    for _, item in pairs(itemMap) do
        table.insert(items, item)
    end
    table.sort(items, function(a, b)
        if a.count ~= b.count then return a.count > b.count end
        return a.displayName < b.displayName
    end)
    return items
end

local function extractItems(item, amount)
    local remaining = amount
    for _, source in ipairs(item.sources) do
        if remaining <= 0 then break end
        local ok, transferred = pcall(
            peripheral.call, OUTPUT_INV, "pullItems",
            source.inv, source.slot,
            math.min(remaining, source.count)
        )
        if ok and transferred then
            remaining = remaining - transferred
        end
    end
    local extracted = amount - remaining
    log.info("Extracted %d x %s", extracted, item.displayName)
    return extracted
end

-- ============================================================================
-- Computer terminal helpers (keyboard input on the computer screen)
-- ============================================================================

local function termClear()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end

local function termStatus(msg)
    termClear()
    term.setTextColor(colors.lightBlue)
    print("=== Storage Terminal ===")
    print()
    term.setTextColor(colors.white)
    print(msg)
end

local function termPromptAmount(item)
    termClear()
    term.setTextColor(colors.lightBlue)
    print("=== Storage Terminal ===")
    print()
    term.setTextColor(colors.yellow)
    print(item.displayName)
    term.setTextColor(colors.lightGray)
    print("Available: " .. formatCount(item.count))
    print()
    term.setTextColor(colors.white)
    write("Amount (or 'all'): ")
    local input = read()
    if input == "all" then
        return item.count
    end
    return tonumber(input)
end

local function termPromptSearch()
    termClear()
    term.setTextColor(colors.lightBlue)
    print("=== Storage Terminal ===")
    print()
    term.setTextColor(colors.white)
    write("Search (empty = clear): ")
    return read()
end

-- ============================================================================
-- Find monitor
-- ============================================================================

local mon = peripheral.find("monitor")
if not mon then
    printError("No monitor found!")
    return
end
mon.setTextScale(0.5)

local main = basalt.getMainFrame()
main:setTerm(mon)
main:setBackground(colors.black)

local monW, monH = mon.getSize()
ITEMS_PER_PAGE = monH - 3

-- ============================================================================
-- Header
-- ============================================================================

main:addLabel()
    :setPosition(1, 1)
    :setSize(monW, 1)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setText(" Storage Terminal")

local countBadge = main:addLabel()
    :setPosition(monW - 12, 1)
    :setSize(13, 1)
    :setBackground(colors.blue)
    :setForeground(colors.lightBlue)
    :setText("")

-- Search button (tapping opens search prompt on computer terminal)
local searchBtn = main:addButton()
    :setPosition(1, 2)
    :setSize(monW, 1)
    :setBackground(colors.gray)
    :setForeground(colors.lightGray)
    :setText(" > Tap to search...")

-- ============================================================================
-- Item list
-- ============================================================================

local listFrame = main:addFrame()
    :setPosition(1, 3)
    :setSize(monW, monH - 3)
    :setBackground(colors.black)

-- ============================================================================
-- Footer
-- ============================================================================

local footerInfo = main:addLabel()
    :setPosition(1, monH)
    :setSize(monW - 10, 1)
    :setBackground(colors.gray)
    :setForeground(colors.lightGray)
    :setText("")

local prevBtn = main:addButton()
    :setPosition(monW - 9, monH)
    :setSize(5, 1)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setText(" < ")

local nextBtn = main:addButton()
    :setPosition(monW - 4, monH)
    :setSize(5, 1)
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :setText(" > ")

-- ============================================================================
-- Rendering
-- ============================================================================

local itemWidgets = {}
local searchQuery = ""

local function applyFilter()
    local query = searchQuery:lower()
    if query == "" then
        filteredItems = allItems
    else
        filteredItems = {}
        for _, item in ipairs(allItems) do
            if item.displayName:lower():find(query, 1, true)
                or item.name:lower():find(query, 1, true) then
                table.insert(filteredItems, item)
            end
        end
    end
    totalPages = math.max(1, math.ceil(#filteredItems / ITEMS_PER_PAGE))
    if currentPage > totalPages then currentPage = totalPages end
end

local function renderList()
    for _, w in ipairs(itemWidgets) do
        w:destroy()
    end
    itemWidgets = {}

    local startIdx = (currentPage - 1) * ITEMS_PER_PAGE + 1
    local endIdx = math.min(startIdx + ITEMS_PER_PAGE - 1, #filteredItems)
    local countColW = 7

    for i = startIdx, endIdx do
        local item = filteredItems[i]
        local row = i - startIdx + 1
        local rowBg = row % 2 == 0 and colors.black or colors.gray

        local nameText = " " .. item.displayName
        local nameW = monW - countColW
        if #nameText > nameW then
            nameText = nameText:sub(1, nameW - 2) .. ".."
        end

        local btn = listFrame:addButton()
            :setPosition(1, row)
            :setSize(nameW, 1)
            :setBackground(rowBg)
            :setForeground(getItemColor(item.name))
            :setText(nameText)

        btn:onClick(function()
            if waitingForInput then return end
            waitingForInput = true
            basalt.schedule(function()
                local amount = termPromptAmount(item)
                if amount and amount > 0 then
                    amount = math.min(math.floor(amount), item.count)
                    extractItems(item, amount)
                    refresh()
                end
                termStatus("Tap items on the monitor.")
                waitingForInput = false
            end)
        end)

        local countLbl = listFrame:addLabel()
            :setPosition(nameW + 1, row)
            :setSize(countColW, 1)
            :setBackground(rowBg)
            :setForeground(colors.lime)
            :setText(string.format("%" .. countColW .. "s", formatCount(item.count)))

        table.insert(itemWidgets, btn)
        table.insert(itemWidgets, countLbl)
    end

    for row = endIdx - startIdx + 2, ITEMS_PER_PAGE do
        local lbl = listFrame:addLabel()
            :setPosition(1, row)
            :setSize(monW, 1)
            :setBackground(colors.black)
            :setText("")
        table.insert(itemWidgets, lbl)
    end

    footerInfo:setText(string.format(" Pg %d/%d  %d items", currentPage, totalPages, #filteredItems))
    countBadge:setText(string.format("%d types ", #allItems))

    if searchQuery ~= "" then
        searchBtn:setText(" > " .. searchQuery .. "  [tap to clear]")
        searchBtn:setForeground(colors.white)
    else
        searchBtn:setText(" > Tap to search...")
        searchBtn:setForeground(colors.lightGray)
    end
end

local function refresh()
    local inventories = scanInventories()
    allItems = aggregateItems(inventories)
    applyFilter()
    renderList()
    log.info("Scanned %d inventories, %d unique items", #inventories, #allItems)
end

-- ============================================================================
-- Event handlers
-- ============================================================================

searchBtn:onClick(function()
    if waitingForInput then return end
    waitingForInput = true
    basalt.schedule(function()
        local query = termPromptSearch()
        searchQuery = query or ""
        currentPage = 1
        applyFilter()
        renderList()
        termStatus("Tap items on the monitor.")
        waitingForInput = false
    end)
end)

prevBtn:onClick(function()
    if currentPage > 1 then
        currentPage = currentPage - 1
        renderList()
    end
end)

nextBtn:onClick(function()
    if currentPage < totalPages then
        currentPage = currentPage + 1
        renderList()
    end
end)

-- ============================================================================
-- Main
-- ============================================================================

termStatus("Tap items on the monitor.")
refresh()

basalt.schedule(function()
    while true do
        sleep(SCAN_INTERVAL)
        if not waitingForInput then
            refresh()
        end
    end
end)

basalt.run()
