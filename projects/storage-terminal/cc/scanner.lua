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

function scanner.getMonitors()
    local monitors = {}
    local names = peripheral.getNames()
    for _, name in ipairs(names) do
        if peripheral.hasType(name, "monitor") then
            table.insert(monitors, name)
        end
    end
    return monitors
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
        monitors = scanner.getMonitors(),
    }
end

function scanner.loop()
    while true do
        scanner.scan()
        sleep(_config.get("scanInterval") or 5)
    end
end

return scanner
