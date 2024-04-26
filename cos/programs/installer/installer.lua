local args = {...}


local function downloadLatestBuild()
    local apiURL = "http://api.github.com/repos/knijn/cos/releases"
    local baseRepoURL = "https://github.com/knijn/cos"
    local scKey = _G._GIT_API_KEY
    if scKey then
      requestData = {
        url = apiURL,
        headers = {["Authorization"] = "token " .. scKey}
      }
      http.request(requestData)
    else
      http.request(apiURL) -- when not on switchcraft, use no authentication
    end
    print("Made request to " .. apiURL)
end

if args[1] == "install" then
    -- data[1].assets[1].browser_download_url
    downloadLatestBuild()
    
    while true do
        local event, url, handle = os.pullEvent()
        if event == "http_failure" then
            error("Failed to download file: " .. handle)
        elseif event == "http_success" then
            local data = textutils.unserialiseJSON(handle.readAll())
            local url = data[1].assets[1].browser_download_url
            local h = http.get(url)
            local buildData = textutils.unserialise(h.readAll()) -- load all the of the OS in RAM, this might be bad later
            h.close()
            
            for i,o in pairs(buildData.directories) do
                print("d+ " .. o)
                fs.makeDir(o)
            end

            for file,fileData in pairs(buildData.files) do
                local h = fs.open(file,"w")
                h.write(fileData)
                h.close()
                print(" + " .. file)
            end
            print("cOS has been installed, please reboot!")
            return
        end
    end
elseif args[1] == "update" then
    downloadLatestBuild()
    local versionAPI = require("version")
    while true do
        local event, url, handle = os.pullEvent()
        if event == "http_failure" then
            error("Failed to download file: " .. handle)
        elseif event == "http_success" then
            local data = textutils.unserialiseJSON(handle.readAll())
            local url = data[1].assets[1].browser_download_url
            local h = http.get(url)
            local buildData = textutils.unserialise(h.readAll()) -- load all the of the OS in RAM, this might be bad later
            h.close()
            
            local newBuildVersion = versionAPI.parse_version(buildData.version)
            local currentVersion = versionAPI.parse_version(_G.cos_version)
            print("Current version: " .. _G.cos_version)
            print("New version: " .. buildData.version)
            
            local function updateOS()
                for i,o in pairs(buildData.directories) do
                    print("d+ " .. o)
                    fs.makeDir(o)
                end
                for file,fileData in pairs(buildData.files) do
                    local h = fs.open(file,"w")
                    h.write(fileData)
                    h.close()
                    print(" + " .. file)
                end
                print("Core system updated")
            end

            local function updatePackages()
                for i,o in pairs(_G.cos_loaded_packages) do
                    local package = require("/cos/packages/" .. o)
                    if package.update then
                        package.update()
                    else
                        log("Package " .. o .. " has no update function", true, "error")
                    end
                end
            end

            if (newBuildVersion.major > currentVersion.major) or (newBuildVersion.minor > currentVersion.minor) and newBuildVersion.major == currentVersion.major or (newBuildVersion.patch > currentVersion.patch) and newBuildVersion.major == currentVersion.major and newBuildVersion.minor == currentVersion.minor then
                if newBuildVersion.major > currentVersion.major then
                    print("Major update available, are you sure you want to continue?")
                    print("This will update the core system and all packages")
                    print("y/n")
                    local entry = string.lower(read())
                    if entry == "y" then
                        updateOS()
                        updatePackages()
                        return
                    else
                        print("Update cancelled")
                        return
                    end
                end

                print("New version available!")
                print("Would you like to update the core system and package store? (y/n) ")
                local entry = string.lower(read())
                if entry == "y" then
                    updateOS()
                else
                    print("Core system not updated")
                end
                print("Would you like to update the packages? (y/n) ")
                local entry = string.lower(read())
                if entry == "y" then
                    updatePackages()
                else
                    print("Packages not updated")
                end    
            else
                print("No new system version available")
            end
            
            
            return
        end
    end
elseif args[1] == "build" then
    local filesConfig = _G.cos_packages_config.installer.files
    local directoriesConfig = _G.cos_packages_config.installer.directories
    local ignoreConfig = _G.cos_packages_config.installer.ignore

    local fileListing = {}
    local directoryListing = {}

    local archive = {}
    
    local function packageDir(directory)
        local sub = fs.list(directory)
        for i,subf in pairs(sub) do
            if fs.isDir(fs.combine(directory, subf)) then
                packageDir(fs.combine(directory, subf))
                print("d " ..fs.combine(directory, subf))
                table.insert(directoryListing,directory .. subf)
            else
                table.insert(fileListing,fs.combine(directory, subf))
                print("f " .. fs.combine(directory, subf))
            end
        end
    end

    print("Queuing files to be packaged")

    for i, directory in pairs(directoriesConfig) do
        packageDir(directory)
    end
    
    for i,file in pairs(filesConfig) do
        table.insert(fileListing,file)
    end

    -- strip the listings from any files we don't want
    for i,file in pairs(ignoreConfig) do
        for i,o in pairs(fileListing) do
            if o == file then
                table.remove(fileListing,i)
            end
        end
        for i,o in pairs(directoryListing) do
            if o == file then
                table.remove(directoryListing,i)
            end
        end
    end

    archive.directories = {}
    archive.files = {}

    for i,file in pairs(fileListing) do
        local h, err = fs.open(file,"r")
        if not h then error(err) end
        local fileContents = h.readAll()
        h.close()
        print(" + " .. file)
        archive.files[file] = fileContents
    end
    for i,directory in pairs(directoryListing) do
        print("d+ " .. directory)
        table.insert(archive.directories,directory)
    end

    -- open the default config
    local h = fs.open("/cos/programs/installer/data/defaultconfig.lua","r")
    local defaultConfig = h.readAll()
    h.close()
    archive.files["/cos/config.lua"] = defaultConfig
    print("Inserted default config")

    archive.version = _G.cos_version

    local h = fs.open("/cos-build","w")
    h.write(textutils.serialize(archive))
    h.close()
end
