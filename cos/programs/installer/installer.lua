local args = {...}
if args[1] == "install" then
      -- data[1].assets[1].browser_download_url
    local apiURL = "http://api.github.com/repos/knijn/cos/releases"
    local baseRepoURL = "https://github.com/knijn/cos"
    local skipcheck = false
    if args and args[1] == "y" then
      skipcheck = true
    end

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

    while true do
        event, url, handle = os.pullEvent()
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
elseif args[1] == "build" then
    local filesConfig = _G.cos_packages_config.installer.files
    local directoriesConfig = _G.cos_packages_config.installer.directories
    local ignoreConfig = _G.cos_packages_config.installer.ignore

    local fileListing = {}
    local directoryListing = {}

    local archive = {}

    for i,directory in pairs(directoriesConfig) do
        local subdirectories = fs.list(directory)
        table.insert(directoryListing,directory)
        for i,subdirectory in pairs(subdirectories) do
            --print(directory .. subdirectory)
            if fs.isDir(directory .. subdirectory) then
                table.insert(directoryListing,directory .. subdirectory)
                local subsubdirectories = fs.list(directory .. subdirectory)
                
                for i,subsubdirectory in pairs(subsubdirectories) do
                    if fs.isDir(directory .. subdirectory .. "/" .. subsubdirectory .. "/") then
                        table.insert(directoryListing,directory .. subdirectory  .. "/".. subsubdirectory)
                        for i,subsubsubdirectory in pairs(fs.list(directory .. subdirectory .. "/" .. subsubdirectory .. "/")) do
                            if fs.isDir(directory .. subdirectory .. "/" .. subsubdirectory .. "/" .. subsubsubdirectory) then
                                table.insert(directoryListing,directory .. subdirectory  .. "/".. subsubdirectory .. "/" .. subsubsubdirectory)
                            else
                                table.insert(fileListing,directory .. subdirectory  .. "/".. subsubdirectory .. "/" .. subsubsubdirectory)
                            end
                            -- this is hell
                        end
                    else
                      table.insert(fileListing,directory .. subdirectory  .. "/".. subsubdirectory)
                    end
                end
            else
                table.insert(fileListing,directory .. subdirectory)
            end
        end
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

    local h = fs.open("/cos-build","w")
    h.write(textutils.serialize(archive))
    h.close()
end
