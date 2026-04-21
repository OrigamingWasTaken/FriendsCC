---@meta

---Scroller Pane peripheral from CC:C Bridge.
---Peripheral type: "scroller_pane"
---@class ScrollerPane
local ScrollerPane = {}

---@return number width
---@return number height
---@nodiscard
function ScrollerPane:getSize() end

function ScrollerPane:clear() end

---@param x number
---@param y number
function ScrollerPane:setCursorPos(x, y) end

---@return number x
---@return number y
---@nodiscard
function ScrollerPane:getCursorPos() end

---@param text string
function ScrollerPane:write(text) end

function ScrollerPane:clearLine() end
