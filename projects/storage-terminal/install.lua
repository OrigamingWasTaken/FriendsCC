local repo = "https://raw.githubusercontent.com/OrigamingWasTaken/FriendsCC/main"

local files = {
    {remote = "lib/log.lua", path = "/lib/log.lua"},
    {remote = "projects/storage-terminal/startup.lua", path = "/startup.lua"},
    {remote = "projects/storage-terminal/main.lua", path = "/main.lua"},
}

for _, f in ipairs(files) do
    local dir = fs.getDir(f.path)
    if dir ~= "" and not fs.exists(dir) then
        fs.makeDir(dir)
    end
    if fs.exists(f.path) then
        fs.delete(f.path)
    end
    print("Downloading " .. f.path)
    shell.run("wget", repo .. "/" .. f.remote, f.path)
end

if not fs.exists("/basalt.lua") and not fs.exists("/basalt") then
    print("Installing Basalt...")
    shell.run("wget run https://raw.githubusercontent.com/Pyroxenium/Basalt2/main/install.lua -r")
end

print("Done! Run 'reboot' to start.")
