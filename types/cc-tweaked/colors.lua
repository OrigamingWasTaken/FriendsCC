---@meta

---@class colorsAPI
colors = {}

---@type number
colors.white = 1
---@type number
colors.orange = 2
---@type number
colors.magenta = 4
---@type number
colors.lightBlue = 8
---@type number
colors.yellow = 16
---@type number
colors.lime = 32
---@type number
colors.pink = 64
---@type number
colors.gray = 128
---@type number
colors.lightGray = 256
---@type number
colors.cyan = 512
---@type number
colors.purple = 1024
---@type number
colors.blue = 2048
---@type number
colors.brown = 4096
---@type number
colors.green = 8192
---@type number
colors.red = 16384
---@type number
colors.black = 32768

---@param ... number
---@return number
---@nodiscard
function colors.combine(...) end

---@param col number
---@param ... number
---@return number
---@nodiscard
function colors.subtract(col, ...) end

---@param col number
---@param color number
---@return boolean
---@nodiscard
function colors.test(col, color) end

---@param r number
---@param g number
---@param b number
---@return number
---@nodiscard
function colors.packRGB(r, g, b) end

---@param rgb number
---@return number r
---@return number g
---@return number b
---@nodiscard
function colors.unpackRGB(rgb) end

---@param color number
---@return string
---@nodiscard
function colors.toBlit(color) end

---@param blit string
---@return number
---@nodiscard
function colors.fromBlit(blit) end

---@type colorsAPI
colours = colors
