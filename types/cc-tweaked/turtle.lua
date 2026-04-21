---@meta

---Only available on turtle computers.
---@class turtleAPI
turtle = {}

---Yields.
---@return boolean success
---@return string|nil error
function turtle.forward() end

---Yields.
---@return boolean success
---@return string|nil error
function turtle.back() end

---Yields.
---@return boolean success
---@return string|nil error
function turtle.up() end

---Yields.
---@return boolean success
---@return string|nil error
function turtle.down() end

---Yields.
---@return boolean success
---@return string|nil error
function turtle.turnLeft() end

---Yields.
---@return boolean success
---@return string|nil error
function turtle.turnRight() end

---Yields.
---@param side? string
---@return boolean success
---@return string|nil error
function turtle.dig(side) end

---Yields.
---@param side? string
---@return boolean success
---@return string|nil error
function turtle.digUp(side) end

---Yields.
---@param side? string
---@return boolean success
---@return string|nil error
function turtle.digDown(side) end

---Yields.
---@param text? string
---@return boolean success
---@return string|nil error
function turtle.place(text) end

---Yields.
---@param text? string
---@return boolean success
---@return string|nil error
function turtle.placeUp(text) end

---Yields.
---@param text? string
---@return boolean success
---@return string|nil error
function turtle.placeDown(text) end

---@param slot number 1-16
---@return boolean
function turtle.select(slot) end

---@return number slot
---@nodiscard
function turtle.getSelectedSlot() end

---@param slot? number
---@return number
---@nodiscard
function turtle.getItemCount(slot) end

---@param slot? number
---@return number
---@nodiscard
function turtle.getItemSpace(slot) end

---@param slot? number
---@param detailed? boolean
---@return table|nil
---@nodiscard
function turtle.getItemDetail(slot, detailed) end

---Yields.
---@return boolean success
---@return string|nil error
function turtle.equipLeft() end

---Yields.
---@return boolean success
---@return string|nil error
function turtle.equipRight() end

---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.drop(count) end

---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.dropUp(count) end

---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.dropDown(count) end

---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.suck(count) end

---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.suckUp(count) end

---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.suckDown(count) end

---Yields.
---@param count? number
---@return boolean success
---@return string|nil error
function turtle.refuel(count) end

---@return number|"unlimited"
---@nodiscard
function turtle.getFuelLevel() end

---@return number|"unlimited"
---@nodiscard
function turtle.getFuelLimit() end

---@return boolean
function turtle.detect() end

---@return boolean
function turtle.detectUp() end

---@return boolean
function turtle.detectDown() end

---@return boolean success
---@return table info
function turtle.inspect() end

---@return boolean success
---@return table info
function turtle.inspectUp() end

---@return boolean success
---@return table info
function turtle.inspectDown() end

---@param slot number
---@param count? number
---@return boolean
function turtle.transferTo(slot, count) end

---Yields. Requires crafting table equipped.
---@param limit? number
---@return boolean success
---@return string|nil error
function turtle.craft(limit) end
