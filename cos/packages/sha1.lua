sha1 = {}
sha1.metadata = {
    name = "sha1",
    description = "A SHA1 hashing library (Unsafe, for educational/legacy uses only)",
    license = "MIT",
    author = "Anavrins",
    dependencies = {}
}

sha1.startup = function()
    if not fs.exists("/cos/lib/sha1.lua") then
        local hweb, err = http.get("https://pastebin.com/raw/SfL7vxP3")
        if not hweb then
            error("Failed to download sha1.lua: " .. err)
        end
        local hfile = fs.open("/cos/lib/sha1.lua", "w")
        hfile.write(hweb.readAll())
        hfile.close()
        hweb.close()
    end
    return true
end

sha1.update = function()
    local hweb, err = http.get("https://pastebin.com/raw/SfL7vxP3")
    if not hweb then
        error("Failed to download sha1.lua: " .. err)
    end
    local hfile = fs.open("/cos/lib/sha1.lua", "w")
    hfile.write(hweb.readAll())
    hfile.close()
    hweb.close()
end

sha1.cleanup = function()
    return pcall(function() fs.delete("/cos/lib/sha1.lua") end)
end

return sha1