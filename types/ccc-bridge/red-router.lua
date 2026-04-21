---@meta

---RedRouter peripheral from CC:C Bridge.
---Remote redstone control through Create cable networks.
---Peripheral type: "redrouter"
---@class RedRouter
local RedRouter = {}

---@param side string
---@param on boolean
function RedRouter:setOutput(side, on) end

---Errors if value outside 0-15.
---@param side string
---@param value number 0-15
function RedRouter:setAnalogOutput(side, value) end

---@param side string
---@return boolean
---@nodiscard
function RedRouter:getOutput(side) end

---@param side string
---@return boolean
---@nodiscard
function RedRouter:getInput(side) end

---@param side string
---@return number 0-15
---@nodiscard
function RedRouter:getAnalogOutput(side) end

---@param side string
---@return number 0-15
---@nodiscard
function RedRouter:getAnalogInput(side) end
