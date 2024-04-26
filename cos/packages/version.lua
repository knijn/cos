version = {}
version.metadata = {
    name = "version",
    description = "library to make semantic versioning shrimple",
    license = "MIT",
    author = "9551-Dev",
    dependencies = {}
}


version.startup = function()
    if not fs.exists("/cos/lib/version.lua") then
        local hweb, err = http.get("https://raw.githubusercontent.com/9551-Dev/version/main/version.lua")
        if not hweb then
            error("Failed to download version.lua: " .. err)
        end
        local hfile = fs.open("/cos/lib/version.lua", "w")
        hfile.write(hweb.readAll())
        hfile.close()
        hweb.close()
    end
    return true
end

version.cleanup = function()
    fs.delete("/cos/lib/version.lua")
    return true
end
version.update = function()
    local hweb, err = http.get("https://raw.githubusercontent.com/9551-Dev/version/main/version.lua")
    if not hweb then
        error("Failed to download version.lua: " .. err)
    end
    local hfile = fs.open("/cos/lib/version.lua", "w")
    hfile.write(hweb.readAll())
    hfile.close()
    hweb.close()
end

return version