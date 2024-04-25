local args = {...}

local function checkAlive()
    local alive = false
    local function check()
        os.queueEvent("cos_daemon","ping")
        os.pullEvent("cos_daemon_response")
        alive = true
    end
    local function timeout()
        sleep(1)
    end
    parallel.waitForAny(timeout,check)
    return alive
end

if not checkAlive() then error("cos daemon isn't alive",0) end


if args[1] == "cleanup" then
    os.queueEvent("cos_daemon", "cleanup", true) -- enable printing
    local event, command, response = os.pullEvent("cos_daemon_response")
    print(response)
end