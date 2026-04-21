---@meta

---@class windowAPI
window = {}

---@class Window
---@field write fun(self: Window, text: string)
---@field blit fun(self: Window, text: string, textColors: string, bgColors: string)
---@field clear fun(self: Window)
---@field clearLine fun(self: Window)
---@field getCursorPos fun(self: Window): number, number
---@field setCursorPos fun(self: Window, x: number, y: number)
---@field getCursorBlink fun(self: Window): boolean
---@field setCursorBlink fun(self: Window, blink: boolean)
---@field getSize fun(self: Window): number, number
---@field scroll fun(self: Window, n: number)
---@field isColor fun(self: Window): boolean
---@field isColour fun(self: Window): boolean
---@field getTextColor fun(self: Window): number
---@field getTextColour fun(self: Window): number
---@field setTextColor fun(self: Window, color: number)
---@field setTextColour fun(self: Window, colour: number)
---@field getBackgroundColor fun(self: Window): number
---@field getBackgroundColour fun(self: Window): number
---@field setBackgroundColor fun(self: Window, color: number)
---@field setBackgroundColour fun(self: Window, colour: number)
---@field getPaletteColor fun(self: Window, color: number): number, number, number
---@field getPaletteColour fun(self: Window, colour: number): number, number, number
---@field setPaletteColor fun(self: Window, color: number, r: number, g?: number, b?: number)
---@field setPaletteColour fun(self: Window, colour: number, r: number, g?: number, b?: number)
---@field setVisible fun(self: Window, visible: boolean)
---@field isVisible fun(self: Window): boolean
---@field getPosition fun(self: Window): number, number
---@field reposition fun(self: Window, x: number, y: number, width?: number, height?: number, parent?: table)
---@field getLine fun(self: Window, y: number): string, string, string
---@field redraw fun(self: Window)

---@param parent table
---@param x number
---@param y number
---@param width number
---@param height number
---@param visible? boolean
---@return Window
function window.create(parent, x, y, width, height, visible) end
