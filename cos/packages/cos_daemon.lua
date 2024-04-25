local daemon = {}
daemon.metadata = {
    name = "cos_daemon",
    description = "A daemon to manage cos",
    license = "MIT",
    dependencies = {"redrun"}
}

daemon.startup = function()
    shell.setPath(shell.path() .. ":/cos/programs/cos/cos_daemon")
    _G.cos_packages.redrun.start(function() 
        while true do
            local event, command, arg1, arg2 = os.pullEvent("cos_daemon")
            if command == "listActive" then 
                os.queueEvent("cos_daemon_response",  _G.cos_loaded_packages)
            elseif command == "cleanup" then
                for packageName,o in pairs(_G.cos_downloaded_packages) do
                    if not _G.cos_loaded_packages[packageName] then
                        local package = require("cos/packages/" .. packageName)
                        if package.cleanup then
                            package.cleanup()
                            _G.cos_downloaded_packages[package] = nil
                        else
                            log("Package " .. packageName .. " has no cleanup function and couldn't be cleaned up", false, "error")
                        end
                        
                        
                    end
                end
            end
        end
    end, "cos_daemon")
    return true
end

return daemon