local archive = {}
archive.metadata = {
    name = "archive",
    description = "A simple archival tool for ComputerCraft",
    author = "JackMacWindows",
    license = "CC0",
    dependencies = {"libdeflate"}
}
archive.startup = function()
    if not fs.exists("/cos/lib/archive.lua") then
        local hweb, err = http.get("https://raw.githubusercontent.com/MCJack123/CC-Archive/master/archive.lua")
        if not hweb then
            error("Failed to download archive.lua: " .. err)
        end
        local hfile = fs.open("/cos/lib/archive.lua", "w")
        hfile.write(hweb.readAll())
        hfile.close()
        hweb.close()
    end
    return true
end

archive.update = function()
    local hweb, err = http.get("https://raw.githubusercontent.com/MCJack123/CC-Archive/master/archive.lua")
    if not hweb then
        error("Failed to download archive.lua: " .. err)
    end
    local hfile = fs.open("/cos/lib/archive.lua", "w")
    hfile.write(hweb.readAll())
    hfile.close()
    hweb.close()
end

archive.cleanup = function()
    return pcall(function() fs.delete("/cos/lib/archive.lua") end)
end



return archive