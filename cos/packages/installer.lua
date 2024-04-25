local args = {...}
if args[1] == "install-cos" then
  -- when installing cOS from a regular computer, we'll find ourselves here
end

local installer = {}
installer.metadata = {
    name = "installer",
    description = "The cOS installer",
    license = "MIT",
    author = "EmmaKnijn",
    dependencies = {"archive"}
}

installer.startup = function()
    shell.setPath(shell.path() .. ":/cos/programs/installer")
    return true
end

return installer