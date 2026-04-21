local log = {}

local _file = nil
local _monitor = nil
local _level_names = { "INFO", "WARN", "ERROR" }

local function _timestamp()
    local ms = os.epoch("utc")
    local s = math.floor(ms / 1000)
    local rem = ms % 1000
    return string.format("%d.%03d", s, rem)
end

local function _write(level, msg, ...)
    local text = string.format("[%s] [%s] %s", _timestamp(), _level_names[level], string.format(msg, ...))
    if _file then
        _file.write(text .. "\n")
        _file.flush()
    end
    if _monitor then
        local _, h = _monitor.getSize()
        _monitor.scroll(1)
        _monitor.setCursorPos(1, h)
        _monitor.write(text)
    end
end

function log.init(path)
    if _file then _file.close() end
    _file = fs.open(path or "/log.txt", "a")
end

function log.toMonitor(side)
    local m = peripheral.wrap(side)
    if m then
        _monitor = m
        _monitor.setTextScale(0.5)
        _monitor.clear()
        _monitor.setCursorPos(1, 1)
    end
end

function log.info(msg, ...)  _write(1, msg, ...) end
function log.warn(msg, ...)  _write(2, msg, ...) end
function log.error(msg, ...) _write(3, msg, ...) end

function log.close()
    if _file then _file.close() end
    _file = nil
    _monitor = nil
end

return log
