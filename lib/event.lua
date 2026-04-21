local event = {}

local _handlers = {}
local _timers = {}
local _running = false

function event.on(eventName, callback)
    if not _handlers[eventName] then
        _handlers[eventName] = {}
    end
    table.insert(_handlers[eventName], callback)
end

function event.every(seconds, callback)
    local id = os.startTimer(seconds)
    _timers[id] = { interval = seconds, callback = callback }
end

function event.run()
    _running = true
    while _running do
        local e = { os.pullEvent() }
        local name = e[1]

        if name == "timer" then
            local id = e[2]
            local t = _timers[id]
            if t then
                _timers[id] = nil
                t.callback()
                if _running then
                    local newId = os.startTimer(t.interval)
                    _timers[newId] = t
                end
            end
        end

        local handlers = _handlers[name]
        if handlers then
            for _, cb in ipairs(handlers) do
                cb(unpack(e, 2))
            end
        end

        local allHandlers = _handlers["*"]
        if allHandlers then
            for _, cb in ipairs(allHandlers) do
                cb(unpack(e))
            end
        end
    end
end

function event.stop()
    _running = false
end

return event
