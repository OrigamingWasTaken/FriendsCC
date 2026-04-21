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
        if msg.outputInv and msg.outputInv ~= "" then
            _config.set("outputInv", msg.outputInv)
        end
        if msg.scanInterval and msg.scanInterval > 0 then
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

        print("[ws] Connecting to " .. url)
        local ok, socket = pcall(http.websocket, url)
        if ok and socket then
            _socket = socket
            _connected = true
            backoff = 1

            local items = _scanner.getItems()
            print("[ws] Connected, sending " .. #items .. " items")
            ws.sendInventory(items)
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
            print("[ws] Disconnected")
        else
            print("[ws] Connection failed, retrying in " .. math.min(backoff, 30) .. "s")
        end

        sleep(math.min(backoff, 30))
        backoff = backoff * 2
    end
end

return ws
