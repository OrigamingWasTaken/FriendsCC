---@meta

---@class paintutilsAPI
paintutils = {}

---@param data string
---@return table
---@nodiscard
function paintutils.parseImage(data) end

---@param path string
---@return table|nil
function paintutils.loadImage(path) end

---@param x number
---@param y number
---@param color? number
function paintutils.drawPixel(x, y, color) end

---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param color? number
function paintutils.drawLine(startX, startY, endX, endY, color) end

---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param color? number
function paintutils.drawBox(startX, startY, endX, endY, color) end

---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param color? number
function paintutils.drawFilledBox(startX, startY, endX, endY, color) end

---@param image table
---@param x number
---@param y number
function paintutils.drawImage(image, x, y) end
