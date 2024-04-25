local args = {...}

if not args[1] then
    print("syslog help:")
    print("clear - clears the log file")
end

local checkAlive = function()
    local function check()
        os.queueEvent("syslog_daemon")
        os.pullEvent("syslog_daemon_response")
        return true
    end
    local function timeout()
        sleep(1)
        return false
    end
    parallel.waitForAny(timeout,check)
end

if not checkAlive() then error("daemon isn't alive",0) end

if args[1] == "clear" then
    os.queueEvent("syslog_daemon", "clearLog")
end