local config = require("/cos/config")
if not config then error("No config file or not valid") end


-- let packages inject stuff into _G.cos_packages in order to make them available system wide if its a library

-- default fallback log function if the syslog package is not loaded
_G.log = function(message, printed)    
    if printed then
      print(message)
    end
end
log("Basic log() overwrite done", true)

_G.cos_loaded_packages = {}
_G.cos_packages_config = {}
_G.cos_packages = {}
_G.cos_version = "0.3.0"
_G.cos_installed_packages = settings.get("cos.installed_packages",{})


-- initial scan to build list of packages to load
local toLoad = {}
local printLogs = true
if config.silent_startup then
  printLogs = false
end
if config.pretty_boot then
  printLogs = false
end
term.clear()
term.setCursorPos(1,1)

local function setBootDots(amt)
  if not config.pretty_boot then
    return
  end
  local xSize, ySize = term.getSize()
  local dot = "\7 "
  term.setCursorPos(math.ceil(xSize/2) - 9 / 2, math.ceil(ySize/2)+2)
  for i=1,5 do
    if amt >= i then
      term.setTextColor(config.theme.secondary_color or colors.lightBlue)
    else
      term.setTextColor(colors.gray)
    end
    term.write(dot)
  end
  term.setTextColor(config.theme.text_color)
end

if config.pretty_boot then
  local xSize, ySize = term.getSize()
  local text = "cOS "
  term.setCursorPos(math.ceil(xSize/2) - #text / 2, math.ceil(ySize/2))
  term.setTextColor(config.theme.primary_color or colors.blue)
  term.write(text)
  setBootDots(1)
  term.setCursorPos(1,ySize)
  term.setTextColor(colors.gray)
  term.write("v" .. _G.cos_version)
end

log("Setting .settings values...", printLogs)
if config.settings then
  for k,v in pairs(config.settings) do
    settings.set(k,v)
  end
  settings.save()
end
fs.makeDir("/cos/lib")
fs.makeDir("/cos/programs/ccsmb10")
fs.makeDir("/cos/userdata")
settings.set("path.programs", "/cos/programs/ccsmb10")
settings.set("path.libraries", "/cos/lib")
settings.set("path.data","/cos/userdata")
shell.setPath(shell.path() .. ":/cos/programs/ccsmb10")
settings.set("shell.package_path", settings.get("shell.package_path") .. ";/cos/lib/?;/cos/lib/?.lua")
settings.save()

log("Loading syslog now...", printLogs)
require("/cos/packages/redrun").startup(config.packages.redrun)
require("/cos/packages/cos_syslog").startup(config.packages.cos_syslog)
log("Syslog loaded..")

log("Base cOS initialization done.", printLogs)
log("Loading packages...", printLogs)
--log(" ", printLogs)
--log(" ", printLogs)

setBootDots(2)
if config.packages then
    for packageName,o in pairs(config.packages) do
      if fs.exists("/cos/packages/" .. packageName .. ".lua") and packageName ~= "cos_syslog"  or packageName ~= "redrun" then
        local package, err = require("/cos/packages/" .. packageName)
        if package == true then
          log("The package " .. packageName .." was misconfigured")
        end
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

for i=1,5 do -- do a scan for packages that depend on other packages
  log("scanning for deep subdependencies, iteration " .. i, printLogs)
  for packageName,priority in pairs(toLoad) do
      local package = require("/cos/packages/" .. packageName)
      if package and package.metadata and packageName ~= "cos_syslog"  or packageName ~= "redrun" then
        local dependencies = package.metadata.dependencies
        for i,dependency in pairs(dependencies) do
          if not toLoad[dependency] then
            toLoad[dependency] = 2
            log("queued " .. packageName .. " as a subdependency", printLogs)
          end
        end
      end
  end

  
end
setBootDots(3)
for i=1,4 do
  targetPriority = 4 - i

  for packageName,priority in pairs(toLoad) do
    if (priority == targetPriority and not _G.cos_loaded_packages[packageName]) or (targetPriority == 0 and not _G.cos_loaded_packages[packageName]) then -- this will re-attempt to load it if it failed the first time in a higher priority
      local package = require("/cos/packages/" .. packageName)
      if package and (packageName ~= "cos_syslog" or packageName ~= "redrun") then
        log("loading " .. packageName .. " with priority " .. priority, printLogs)
        -- Let the package handle anything it needs to on every startup
        
        local errorObject = nil
        _G.cos_packages_config[packageName] = config.packages[packageName]
        _G.cos_loaded_packages[packageName], errorObject = pcall(package.startup,config.packages[packageName])
        if not _G.cos_loaded_packages[packageName] then
          log("error loading " .. packageName .. "\n" .. errorObject, printLogs, "error")
        elseif not _G.cos_installed_packages[packageName]  then
          _G.cos_installed_packages[packageName] = true
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

settings.set("cos.installed_packages",_G.cos_installed_packages)
settings.save()
setBootDots(5)
log("cOS started", printLogs)
if config.pretty_boot then
  local waitTime = config.pretty_boot_time or 2
  sleep(waitTime)
  term.clear()
  term.setCursorPos(1,1)
  term.setTextColor(colors.yellow)
  term.write("cOS " .. _G.cos_version)
  term.setTextColor(colors.white)
  term.setCursorPos(1,2)
end