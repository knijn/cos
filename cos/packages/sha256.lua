sha256 = {}
sha1.metadata = {
    name = "sha256",
    description = "SHA-256, HMAC and PBKDF2 functions in ComputerCraft",
    license = "MIT",
    author = "Anavrins",
    dependencies = {}
}

sha256.startup = function()
    if not fs.exists("/cos/lib/sha256.lua") then
        local hweb, err = http.get("https://pastebin.com/raw/6UV4qfNF")
        if not hweb then
            error("Failed to download sha256.lua: " .. err)
        end
        local hfile = fs.open("/cos/lib/sha256.lua", "w")
        hfile.write(hweb.readAll())
        hfile.close()
        hweb.close()
    end
    return true
end

sha256.update = function()
    local hweb, err = http.get("https://pastebin.com/raw/6UV4qfNF")
    if not hweb then
        error("Failed to download sha256.lua: " .. err)
    end
    local hfile = fs.open("/cos/lib/sha256.lua", "w")
    hfile.write(hweb.readAll())
    hfile.close()
    hweb.close()
end

sha256.cleanup = function()
    return pcall(function() fs.delete("/cos/lib/sha256.lua") end)
end

return sha256