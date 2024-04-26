gist = {}

gist.metadata = {
    name = "gist",
    description = "A simple github gist client",
    license = "MIT",
    author = "JackMacWindows",
    dependencies = {"version"}
}

gist.startup = function()
    if not fs.exists("/cos/programs/gist/gist.lua") then
        local hweb, err = http.get("https://pastebin.com/raw/zSLPYpqs")
        if not hweb then
            log("Failed to download gist.lua: " .. err, true, "error")
        end
        local hfile = fs.open("/cos/programs/gist/gist.lua", "w")
        hfile.write(hweb.readAll())
        hfile.close()
        hweb.close()
    end

    shell.setPath(shell.path() .. ":/cos/programs/gist")
    return true
end

gist.cleanup = function()
    fs.delete("/cos/programs/gist/gist.lua")
    return true
end

gist.update = function()
    local hweb, err = http.get("https://pastebin.com/raw/zSLPYpqs")
    if not hweb then
        log("Failed to download gist.lua: " .. err, true, "error")
    end
    local hfile = fs.open("/cos/programs/gist/gist.lua", "w")
    hfile.write(hweb.readAll())
    hfile.close()
    hweb.close()
end

return gist