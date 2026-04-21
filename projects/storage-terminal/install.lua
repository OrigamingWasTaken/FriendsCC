local repo = "https://raw.githubusercontent.com/OrigamingWasTaken/FriendsCC/main"

local files = {
    { remote = "projects/storage-terminal/cc/config.lua", path = "/config.lua" },
    { remote = "projects/storage-terminal/cc/draw.lua", path = "/draw.lua" },
    { remote = "projects/storage-terminal/cc/scanner.lua", path = "/scanner.lua" },
    { remote = "projects/storage-terminal/cc/ws.lua", path = "/ws.lua" },
    { remote = "projects/storage-terminal/cc/panels.lua", path = "/panels.lua" },
    { remote = "projects/storage-terminal/cc/main.lua", path = "/main.lua" },
    { remote = "projects/storage-terminal/cc/startup.lua", path = "/startup.lua" },
}

for _, f in ipairs(files) do
    if fs.exists(f.path) then
        fs.delete(f.path)
    end
    print("Downloading " .. f.path)
    shell.run("wget", repo .. "/" .. f.remote, f.path)
end

print("")
print("Done! Edit /config.lua to set relayUrl and outputInv.")
print("Then run: reboot")
