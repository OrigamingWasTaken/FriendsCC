---@meta

---@class Monitor
---@field write fun(self: Monitor, text: string)
---@field blit fun(self: Monitor, text: string, textColors: string, bgColors: string)
---@field clear fun(self: Monitor)
---@field clearLine fun(self: Monitor)
---@field getCursorPos fun(self: Monitor): number, number
---@field setCursorPos fun(self: Monitor, x: number, y: number)
---@field getCursorBlink fun(self: Monitor): boolean
---@field setCursorBlink fun(self: Monitor, blink: boolean)
---@field getSize fun(self: Monitor): number, number
---@field scroll fun(self: Monitor, n: number)
---@field isColor fun(self: Monitor): boolean
---@field isColour fun(self: Monitor): boolean
---@field getTextColor fun(self: Monitor): number
---@field getTextColour fun(self: Monitor): number
---@field setTextColor fun(self: Monitor, color: number)
---@field setTextColour fun(self: Monitor, colour: number)
---@field getBackgroundColor fun(self: Monitor): number
---@field getBackgroundColour fun(self: Monitor): number
---@field setBackgroundColor fun(self: Monitor, color: number)
---@field setBackgroundColour fun(self: Monitor, colour: number)
---@field getPaletteColor fun(self: Monitor, color: number): number, number, number
---@field getPaletteColour fun(self: Monitor, colour: number): number, number, number
---@field setPaletteColor fun(self: Monitor, color: number, r: number, g?: number, b?: number)
---@field setPaletteColour fun(self: Monitor, colour: number, r: number, g?: number, b?: number)
local Monitor = {}

---@param scale number 0.5 to 5
function Monitor:setTextScale(scale) end
