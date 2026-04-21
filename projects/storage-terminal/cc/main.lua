local config = dofile("/config.lua")
local draw = dofile("/draw.lua")
local scanner = dofile("/scanner.lua")
local panels = dofile("/panels.lua")
local ws = dofile("/ws.lua")

config.load()
scanner.init(config)
panels.init(config, scanner, draw)
ws.init(config, scanner)

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.lightBlue)
print("=== Storage Terminal v2 ===")
term.setTextColor(colors.white)
print("Relay: " .. (config.get("relayUrl") or "not set"))
print("Output: " .. (config.get("outputInv") or "not set"))
print("")
print("Running initial scan...")
scanner.scan()
print("Found " .. #scanner.getItems() .. " items")
print("Starting...")

parallel.waitForAll(
    scanner.loop,
    panels.loop,
    ws.loop
)
