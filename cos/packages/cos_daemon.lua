local daemon = {}
daemon.metadata = {
    name = "cos_daemon",
    description = "A daemon to manage cos",
    license = "MIT",
    dependencies = {"redrun"}
}

daemon.startup = function()
    shell.setPath(shell.path() .. ":/cos/programs/cos_daemon")
    _G.cos_packages.redrun.start(function() 
        while true do
            local event, command, arg1, arg2 = os.pullEvent("cos_daemon")
            if command == "listActive" then 
                os.queueEvent("cos_daemon_response",  _G.cos_loaded_packages)
            elseif command == "ping" then
                os.queueEvent("cos_daemon_response")
            elseif command == "cleanup" then
                if not arg1 then arg1 = false end -- disable printing if not specified
                log("Received cleanup command", arg1)
                for packageName,o in pairs(_G.cos_installed_packages) do
                    if not _G.cos_loaded_packages[packageName] then
                        local package = require("/cos/packages/" .. packageName)
                        if package.cleanup then
                            log("Cleaning up package " .. packageName, arg1)
                            package.cleanup()
                            _G.cos_installed_packages[package] = nil
                            settings.set("cos.installed_packages", _G.cos_installed_packages)
                            settings.save()
                        else
                            log("Package " .. packageName .. " has no cleanup function and couldn't be cleaned up", arg1, "error")
                        end
                    end
                end
                os.queueEvent("cos_daemon_response","cleanup","done")
            end
        end
    end, "cos_daemon")
    return true
end

daemon.update = function()
    return true
end

daemon.cleanup = function()
    return true
end

return daemon