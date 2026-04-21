---@meta

---@class redstoneAPI
redstone = {}

---@return string[]
---@nodiscard
function redstone.getSides() end

---@param side string
---@return boolean
---@nodiscard
function redstone.getInput(side) end

---@param side string
---@param on boolean
function redstone.setOutput(side, on) end

---@param side string
---@return boolean
---@nodiscard
function redstone.getOutput(side) end

---@param side string
---@return number 0-15
---@nodiscard
function redstone.getAnalogInput(side) end

---@param side string
---@param strength number 0-15
function redstone.setAnalogOutput(side, strength) end

---@param side string
---@return number
---@nodiscard
function redstone.getAnalogOutput(side) end

---@param side string
---@return number
---@nodiscard
function redstone.getBundledInput(side) end

---@param side string
---@param colors number
function redstone.setBundledOutput(side, colors) end

---@param side string
---@return number
---@nodiscard
function redstone.getBundledOutput(side) end

---@param side string
---@param mask number
---@return boolean
---@nodiscard
function redstone.testBundledInput(side, mask) end

---@type redstoneAPI
rs = redstone
