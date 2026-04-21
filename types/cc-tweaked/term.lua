---@meta

---@class termAPI
term = {}

---@param text string
function term.write(text) end

---@param text string
---@param textColors string
---@param bgColors string
function term.blit(text, textColors, bgColors) end

function term.clear() end
function term.clearLine() end

---@return number x
---@return number y
---@nodiscard
function term.getCursorPos() end

---@param x number
---@param y number
function term.setCursorPos(x, y) end

---@return boolean
---@nodiscard
function term.getCursorBlink() end

---@param blink boolean
function term.setCursorBlink(blink) end

---@return number width
---@return number height
---@nodiscard
function term.getSize() end

---@param n number
function term.scroll(n) end

---@return boolean
---@nodiscard
function term.isColor() end

---@return boolean
---@nodiscard
function term.isColour() end

---@return number color
---@nodiscard
function term.getTextColor() end

---@return number colour
---@nodiscard
function term.getTextColour() end

---@param color number
function term.setTextColor(color) end

---@param colour number
function term.setTextColour(colour) end

---@return number color
---@nodiscard
function term.getBackgroundColor() end

---@return number colour
---@nodiscard
function term.getBackgroundColour() end

---@param color number
function term.setBackgroundColor(color) end

---@param colour number
function term.setBackgroundColour(colour) end

---@param color number
---@return number r
---@return number g
---@return number b
---@nodiscard
function term.getPaletteColor(color) end

---@param colour number
---@return number r
---@return number g
---@return number b
---@nodiscard
function term.getPaletteColour(colour) end

---@param color number
---@param r number Red 0-1 or hex
---@param g? number
---@param b? number
function term.setPaletteColor(color, r, g, b) end

---@param colour number
---@param r number
---@param g? number
---@param b? number
function term.setPaletteColour(colour, r, g, b) end

---@param target table
---@return table previous
function term.redirect(target) end

---@return table current
---@nodiscard
function term.current() end

---@return table native
---@nodiscard
function term.native() end

---@param text any
function write(text) end

---Yields.
---@param replaceChar? string
---@param history? string[]
---@param completeFn? fun(partial: string): string[]
---@param default? string
---@return string|nil text
function read(replaceChar, history, completeFn, default) end

---@param ... any
function printError(...) end
