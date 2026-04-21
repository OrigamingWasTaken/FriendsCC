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
