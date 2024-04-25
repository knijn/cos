local daemon = {}
daemon.metadata = {
    name = "cos_daemon",
    description = "A daemon to manage cos",
    license = "MIT",
    dependencies = {"redrun"}
}

daemon.startup = function()
    _G.cos_packages.redrun.start(function() 
        local event, command, arg1, arg2 = os.pullEvent("cos_daemon")
        if command == "listActive" then 
            os.queueEvent("cos_daemon_response",  _G.cos_loaded_packages)
        end
    end, "cos_daemon")


    return true
end

return daemon