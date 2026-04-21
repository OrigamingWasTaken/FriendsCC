---@meta

---@class Printer
local Printer = {}

---@param text string
function Printer:write(text) end

---@param x number
---@param y number
function Printer:setCursorPos(x, y) end

---@return number x
---@return number y
---@nodiscard
function Printer:getCursorPos() end

---@return number width
---@return number height
---@nodiscard
function Printer:getPageSize() end

---@return boolean success
function Printer:newPage() end

---@return boolean success
function Printer:endPage() end

---@param title? string
function Printer:setPageTitle(title) end

---@return number level
---@nodiscard
function Printer:getInkLevel() end

---@return number level
---@nodiscard
function Printer:getPaperLevel() end
