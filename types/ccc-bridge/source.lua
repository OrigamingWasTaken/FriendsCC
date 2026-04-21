---@meta

---Source Block peripheral from CC:C Bridge.
---Text written here displays via Create Display Links.
---Peripheral type: "create_source"
---@class CreateSource
local CreateSource = {}

---@return number width
---@return number height
---@nodiscard
function CreateSource:getSize() end

function CreateSource:clear() end

---@param x number
---@param y number
function CreateSource:setCursorPos(x, y) end

---@return number x
---@return number y
---@nodiscard
function CreateSource:getCursorPos() end

---@param text string
function CreateSource:write(text) end

---@param color number
function CreateSource:setBackgroundColor(color) end

---@param color number
function CreateSource:setTextColor(color) end

---@param lineNumber number
---@return string text
---@nodiscard
function CreateSource:getLine(lineNumber) end

function CreateSource:clearLine() end
