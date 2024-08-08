function descriptor()
    return {
        title = "Smart Playlist Extender";
        description = "Extends the playlist by files in last item's directory";
        version = "0.1.1";
        author = "thebamby";
        capabilities = {}
    }
end

function activate()
    -- vlc.playlist.enqueue({{path = ""}})
    -- if (true) then return end

    local playlistItems = vlc.playlist.get("normal", false).children
    -- vlc.msg.dbg(vlc.playlist.current())
    if (#playlistItems == 0) then 
        vlc.msg.info("[SmartLoad] No items in playlist!")
        vlc.deactivate()
        return 
    end

    local curItem = playlistItems[#playlistItems] -- playlist.current_item()
    for k,v in pairs(curItem) do vlc.msg.dbg(tostring(k) .. " " .. tostring(v)) end
    local ignoredPaths = { "."; ".." }

    for key,item in ipairs(playlistItems) do
        table.insert(ignoredPaths, getFilename(item.path))
    end
    
    if (not (string.sub(curItem.path, 1, 7) == "file://")) then
        vlc.msg.info("[SmartLoad] Last item is not a proper file!")
        vlc.deactivate()
        return 
    end

    local folderPath = getFolder(curItem.path).path
    local curItemName = getFilename(curItem.path).path
    -- for k,v in pairs(vlc.net.opendir(folderPath)) do vlc.msg.dbg(tostring(k) .. " " .. tostring(v)) end

    local files = vlc.io.readdir(folderPath)
    table.sort(files)

    local beforeFile = true

    for _, item in ipairs(files) do
        if ((curItemName >= item) or (arrayContains(item, ignoredPaths))) then
            vlc.msg.dbg("Skip: " .. item)
        else
            vlc.msg.dbg("Trying to add: " .. item)
            vlc.playlist.enqueue({{path = "file://" .. folderPath .. item; name = item}})
        end
    end
    vlc.deactivate()
end

function arrayContains(value, arr)
    for _, item in ipairs(arr) do
        if (item == value) then
            return true
        end
    end

    return false
end

function getFolder(path)
    local folderPath = string.match(path, ".*[\\\\/]")
    folderPath = string.gsub(folderPath, "file://", "")
    -- vlc.msg.dbg(folderPath)
    return unpercent(folderPath)
end

function getFilename(path)
    local filename = string.match(path, "[^\\\\/]*$")
    return unpercent(filename)
end

function unpercent(str)

    return vlc.strings.url_parse(str)
    -- local matchCount
    -- local parsedString
    -- local percMatch = "%%%x%x"
    -- function parsePercent(str)
    --    local varCode = tonumber(string.sub(str, 2), 16)
    --     -- vlc.msg.dbg("matched " .. str .. " charCode " .. varCode .. " char: " .. string.char(varCode))
    --     return string.char(varCode) -- should be utf8.char(varCode)
    -- end
    
    -- parsedString, matchCount = string.gsub(str, percMatch, parsePercent)
    -- -- vlc.msg.dbg(matchCount .. " " .. parsedString)
    -- return parsedString
end

function deactivate()
end

function meta_changed()
end

function close()
    vlc.deactivate()
end