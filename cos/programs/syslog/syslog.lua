local args = {...}

if not args[1] then
    print("syslog help:")
    print("clear - clears the log file")
end

local function checkAlive()
    local alive = false
    local function check()
        os.queueEvent("syslog_daemon","ping")
        print("sent queue event", true)
        os.pullEvent("syslog_daemon_response")
        print("got response", true)
        alive = true
    end
    local function timeout()
        sleep(1)
        log("syslog isn't active!!",true)
    end
    parallel.waitForAny(timeout,check)
    return alive
end

if not checkAlive() then error("daemon isn't alive",0) end

if args[1] == "clear" then
    os.queueEvent("syslog_daemon", "clearLog")
end