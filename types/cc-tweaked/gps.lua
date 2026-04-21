---@meta

---@class gpsAPI
gps = {}

---Yields. Requires wireless modem and 4+ GPS hosts.
---@param timeout? number
---@param debug? boolean
---@return number|nil x
---@return number|nil y
---@return number|nil z
function gps.locate(timeout, debug) end
