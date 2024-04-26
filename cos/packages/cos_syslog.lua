syslog = {}

syslog.metadata = {
    name = "cos_syslog",
    description = "A simple logging system for cOS",
    author = "EmmaKnijn",
    license = "MIT",
    dependencies = {"redrun"}
}

syslog.startup = function(config)
    if not config and not config.path then
        logPath = "syslog.txt"
    else
        logPath = config.path
    end
    _G.cos_packages_config["cos_syslog"].logPath = logPath
    -- This is probably a sin but whatever
    _G.log = function(message,printed,level)
        if printed then        
            local oldTermColor = term.getTextColor()
            if level == "error" then
                term.setTextColor(colors.red)
            end
            print(message)
            term.setTextColor(oldTermColor)
        end
        
        local file = fs.open(logPath, "a")
        file.write(message .. "\n")
        file.close()
    end
    
    if config.daemon then
        shell.setPath(shell.path() .. ":/cos/programs/syslog")
        _G.cos_packages.redrun.start(function() -- start the background daemon
            while true do
              local event, command, arg1, arg2 = os.pullEvent("syslog_daemon")
              if command == "clearLog" then
                  local file = fs.open(logPath, "w")
                  file.close()
              elseif command == "ping" then
                  os.queueEvent("syslog_daemon_response")
              end
            end
        end, "syslog_daemon")
    end

    return true
end

syslog.update = function()
    return true
end

syslog.cleanup = function()
    return true
end

return syslog