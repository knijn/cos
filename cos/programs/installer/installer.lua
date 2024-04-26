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
            print("cOS has been updated, please reboot!")
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
