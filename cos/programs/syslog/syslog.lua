local args = {...}

local function help()
    print("Synopsis\nsyslog [OPTIONS]\n\nDescription\nview\n    opens the log file for viewing\nclear\n     clears the log file\nerrors\n      lists all errors in the log file")
end

if not args[1] then
    help()
end

local function checkAlive()
    local alive = false
    local function check()
        os.queueEvent("syslog_daemon","ping")
        os.pullEvent("syslog_daemon_response")
        alive = true
    end
    local function timeout()
        sleep(1)
        log("syslog isn't active!!",true)
    end
    parallel.waitForAny(timeout,check)
    return alive
end

--if not checkAlive() then error("syslog daemon isn't alive",0) end

if args[1] == "clear" then
    local file = fs.open(_G.cos_packages_config["cos_syslog"].logPath, "w")
    file.close()
elseif args[1] == "view" then
    shell.run("edit " .. _G.cos_packages_config.cos_syslog.path)
elseif args[1] == "errors" then
    local h = fs.open(_G.cos_packages_config.cos_syslog.path,"r")
    local contents = h.readAll()
    h.close()
    for s in contents:gmatch("[^\n]+") do
        --print(s)
        if string.match(s, "[ERROR]") then
            print(s)
        end
    end
end