local config = require("/cos/config")
if not config then error("No config file or not valid") end

_G.cos_packages = {}
-- let packages inject stuff into _G.cos_packages in order to make them available system wide if its a library

-- default fallback log function if the syslog package is not loaded
_G.log = function(message, printed)    
    if printed then
      print(message)
    end
end

_G.cos_loaded_packages = {}
_G.cos_packages_config = {}
-- initial scan to build list of packages to load
local toLoad = {}
local printLogs = true
if config.silent_startup then
  printLogs = false
end
term.clear()
term.setCursorPos(1,1)
log("Setting .settings values...", printLogs)
if config.settings then
  for k,v in pairs(config.settings) do
    settings.set(k,v)
  end
  settings.save()
end

log("Basic cOS initialisation done.", printLogs)
log("Loading packages...", printLogs)
--log(" ", printLogs)
--log(" ", printLogs)


if config.packages then
    for packageName,o in pairs(config.packages) do
      if fs.exists("/cos/packages/" .. packageName .. ".lua") then
        local package = require("/cos/packages/" .. packageName)
        if package and package.metadata then
            log("queued " .. packageName .. " ", printLogs)
            -- Queue the package to load
            toLoad[packageName] = 1
            local dependencies = package.metadata.dependencies
            for i,dependency in pairs(dependencies) do
                if require("/cos/packages/" .. dependency) then
                    toLoad[dependency] = 2
                    log("queued dependency  " .. dependency .. "", printLogs)
                else
                    log("!! " .. packageName .. " - not queued as its missing", printLogs)
                end
            end
          elseif package then
            log("queued " .. packageName .. " ", printLogs)
            -- Queue the package to load
              toLoad[packageName] = 1
          end
        else
          log("!! " .. packageName .. " - not queued as its missing", printLogs)
        end
    end
end
for i=1,4 do
  targetPriority = 4 - i

  for packageName,priority in pairs(toLoad) do
    if (priority == targetPriority and not _G.cos_loaded_packages[packageName]) or (targetPriority == 0 and not _G.cos_loaded_packages[packageName]) then -- this will re-attempt to load it if it failed the first time in a higher priority
      local package = require("/cos/packages/" .. packageName)
      if package then
        log("loading " .. packageName .. " with priority " .. priority, printLogs)
        -- Let the package handle anything it needs to on every startup
        
        local errorObject = nil
        _G.cos_packages_config[packageName] = config.packages[packageName]
        _G.cos_loaded_packages[packageName], errorObject = pcall(package.startup,config.packages[packageName])
        if not _G.cos_loaded_packages[packageName] then
          log("error loading " .. packageName .. "\n" .. errorObject, printLogs, "error")
      end
      else
        log("!! " .. packageName .. " - not loaded as its missing", printLogs, "error")
        _G.cos_loaded_packages[packageName] = false
      end
    end
  end

end

for package,loaded in pairs(_G.cos_loaded_packages) do
  if not loaded then
    log("package " .. package .. " failed to load!", printLogs)
  end
end

