local libdeflate = {}
libdeflate.metadata = {
    name = "archive",
    description = "A simple archival tool for ComputerCraft",
    author = "JackMacWindows",
    license = "CC0",
    dependencies = {"libdeflate"}
}
libdeflate.startup = function()
    if not fs.exists("/cos/lib/LibDeflate.lua") then
        local hweb, err = http.get("https://raw.githubusercontent.com/MCJack123/CC-Archive/master/LibDeflate.lua")
        if not hweb then
            log("Failed to download LibDeflate.lua: " .. err, false, "error")
            error("Failed to download LibDeflate.lua: " .. err)
        end
        local hfile = fs.open("/cos/lib/LibDeflate.lua", "w")
        hfile.write(hweb.readAll())
        hfile.close()
        hweb.close()
    end
    return true
end

libdeflate.cleanup = function()
    fs.delete("/cos/lib/LibDeflate.lua")
    return true
end

libdeflate.update = function()
    local hweb, err = http.get("https://raw.githubusercontent.com/MCJack123/CC-Archive/master/LibDeflate.lua")
    if not hweb then
        log("Failed to download LibDeflate.lua: " .. err, false, "error")
        error("Failed to download LibDeflate.lua: " .. err)
    end
    local hfile = fs.open("/cos/lib/LibDeflate.lua", "w")
    hfile.write(hweb.readAll())
    hfile.close()
    hweb.close()
end

return libdeflate