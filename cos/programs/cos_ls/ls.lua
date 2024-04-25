local args = {...}
local pathToCheck = args[1] or shell.dir()
local entries = fs.list(pathToCheck)
local dirs = {}
local files = {}
for i,o in pairs(entries) do
    if fs.isDir(o) then
        table.insert(dirs,o)
    else
        table.insert(files,o)
    end
end

table.sort(entries,function(a,b)
    if fs.isDir(a) and not fs.isDir(b) then
        return true
    elseif not fs.isDir(a) and fs.isDir(b) then
        return false
    else
        return a < b
    end
end)

local function humanReadableSize(size)
    local sizes = {"B","KB","MB","GB","TB"}
    local i = 1
    while size > 1024 do
        size = size / 1024
        i = i + 1
    end
    return math.floor(size * 100) / 100 .. sizes[i]
end

for i,o in pairs(entries) do
    local attributes = fs.attributes(pathToCheck .. "/" .. o)
    local infoText = ""
    local textColor = term.getTextColor()
    if attributes.isDir then
        infoText = infoText .. "dr"
        textColor = colors.green
    else
        infoText = infoText .. "-r"
    end
    if attributes.isReadOnly then
        infoText = infoText .. "-"
    else
        infoText = infoText .. "w"
    end
    infoText = infoText .. " " -- add a trailing space
    local oldTextColor = term.getTextColor()
    term.setTextColor(textColor)
    print(infoText .. humanReadableSize(attributes.size) .. " " .. o)
    term.setTextColor(oldTextColor)
end