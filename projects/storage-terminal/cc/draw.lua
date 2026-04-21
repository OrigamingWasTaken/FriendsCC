local draw = {}

function draw.applyPalette(mon)
    mon.setPaletteColor(colors.black, 0x1a1b26)
    mon.setPaletteColor(colors.gray, 0x24283b)
    mon.setPaletteColor(colors.lightGray, 0x565f89)
    mon.setPaletteColor(colors.blue, 0x7aa2f7)
    mon.setPaletteColor(colors.green, 0x9ece6a)
    mon.setPaletteColor(colors.red, 0xf7768e)
    mon.setPaletteColor(colors.purple, 0xbb9af7)
    mon.setPaletteColor(colors.orange, 0xff9e64)
    mon.setPaletteColor(colors.yellow, 0xe0af68)
    mon.setPaletteColor(colors.white, 0xc0caf5)
    mon.setPaletteColor(colors.cyan, 0x7dcfff)
    mon.setPaletteColor(colors.lightBlue, 0x89ddff)
end

function draw.clear(mon, bg)
    mon.setBackgroundColor(bg or colors.black)
    mon.clear()
end

function draw.box(mon, x, y, w, h, bg)
    mon.setBackgroundColor(bg)
    for row = y, y + h - 1 do
        mon.setCursorPos(x, row)
        mon.write(string.rep(" ", w))
    end
end

function draw.text(mon, x, y, text, fg, bg)
    mon.setCursorPos(x, y)
    if bg then mon.setBackgroundColor(bg) end
    if fg then mon.setTextColor(fg) end
    mon.write(text)
end

function draw.textRight(mon, x, y, w, text, fg, bg)
    local px = x + w - #text
    draw.text(mon, px, y, text, fg, bg)
end

function draw.header(mon, w, text, fg, bg)
    draw.box(mon, 1, 1, w, 1, bg or colors.blue)
    draw.text(mon, 2, 1, text, fg or colors.white, bg or colors.blue)
end

function draw.hline(mon, x, y, w, color)
    mon.setBackgroundColor(color or colors.lightGray)
    mon.setCursorPos(x, y)
    mon.write(string.rep(" ", w))
end

function draw.progressBar(mon, x, y, w, value, max, fg, bg)
    if max <= 0 then max = 1 end
    local filled = math.floor((value / max) * w + 0.5)
    if filled > w then filled = w end
    mon.setCursorPos(x, y)
    mon.setBackgroundColor(fg or colors.green)
    mon.write(string.rep(" ", filled))
    mon.setBackgroundColor(bg or colors.gray)
    mon.write(string.rep(" ", w - filled))
end

function draw.tableRow(mon, x, y, w, cols, fg, bg)
    draw.box(mon, x, y, w, 1, bg)
    local cx = x
    for i, col in ipairs(cols) do
        local text = tostring(col.text or "")
        local colW = col.width or math.floor(w / #cols)
        if #text > colW then
            text = text:sub(1, colW - 2) .. ".."
        end
        if col.align == "right" then
            draw.textRight(mon, cx, y, colW, text, col.fg or fg, bg)
        else
            draw.text(mon, cx, y, " " .. text, col.fg or fg, bg)
        end
        cx = cx + colW
    end
end

return draw
