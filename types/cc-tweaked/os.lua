---@meta

---@class osAPI
os = {}

---Yields.
---@param time number
function os.sleep(time) end

---@return string version e.g. "CraftOS 1.9"
---@nodiscard
function os.version() end

---@return number id
---@nodiscard
function os.getComputerID() end

---@return number id
---@nodiscard
function os.computerID() end

---@return string|nil label
---@nodiscard
function os.getComputerLabel() end

---@return string|nil label
---@nodiscard
function os.computerLabel() end

---@param label? string
function os.setComputerLabel(label) end

---@param env table
---@param path string
---@param ... string
---@return boolean success
function os.run(env, path, ...) end

---@param name string
---@param ... any
function os.queueEvent(name, ...) end

---Yields. Throws on "terminate".
---@param filter? string
---@return string event
---@return any ...
function os.pullEvent(filter) end

---Yields. Does not throw on "terminate".
---@param filter? string
---@return string event
---@return any ...
function os.pullEventRaw(filter) end

---@param delay number
---@return number timerID
function os.startTimer(delay) end

---@param timerID number
function os.cancelTimer(timerID) end

---@param time number In-game time 0.0 to 24.0
---@return number alarmID
function os.setAlarm(time) end

---@param alarmID number
function os.cancelAlarm(alarmID) end

---@return number time CPU seconds
---@nodiscard
function os.clock() end

---@param locale? string "ingame"|"utc"|"local"
---@return number time
---@nodiscard
function os.time(locale) end

---@param locale? string "ingame"|"utc"|"local"
---@return number day
---@nodiscard
function os.day(locale) end

---@param locale? string "ingame"|"utc"|"local"
---@return number epoch Milliseconds
---@nodiscard
function os.epoch(locale) end

---@param format? string
---@param time? number
---@return string|table result
---@nodiscard
function os.date(format, time) end

function os.shutdown() end
function os.reboot() end

---Yields. Alias for os.sleep().
---@param time number
function sleep(time) end
