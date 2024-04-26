local installer = {}
installer.metadata = {
    name = "installer",
    description = "The cOS installer",
    license = "MIT",
    author = "EmmaKnijn",
    dependencies = {"version"}
}

installer.startup = function()
    shell.setPath(shell.path() .. ":/cos/programs/installer")
    return true
end

installer.update = function()
    return true
end

installer.cleanup = function()
    return true
end

return installer