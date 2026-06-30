-- ============================================================
--  Orion AutoMod - Server main.lua
-- ============================================================

local banFilePath = "data/bans.json"
local activeBans  = {}
local banCounter  = 0 



local function log(msg)
    if Config.LogToConsole then
        print("^2[Orion AutoMod]^7 " .. msg)
    end
end

local function debug(msg)
    if Config.Debug then
        print("^5[Orion AutoMod DEBUG]^7 " .. msg)
    end
end

local function loadBans()
    local file = LoadResourceFile(GetCurrentResourceName(), banFilePath)
    if file and file ~= "" then
        local decoded = json.decode(file)
        if type(decoded) == "table" then
            activeBans = decoded
            for _, ban in pairs(activeBans) do
                if ban.banId then
                    local n = tonumber(ban.banId:match("AUTOMOD%-(%d+)"))
                    if n and n > banCounter then banCounter = n end
                end
            end
            debug("Loaded ban records from file, counter at " .. banCounter)
        end
    else
        activeBans = {}
        debug("No ban file found — starting fresh")
    end
end

local function saveBans()
    SaveResourceFile(GetCurrentResourceName(), banFilePath, json.encode(activeBans), -1)
    debug("Ban file saved")
end

local function pruneExpiredBans()
    local now     = os.time()
    local removed = 0
    for id, ban in pairs(activeBans) do
        if ban.expires <= now then
            activeBans[id] = nil
            removed = removed + 1
            debug("Expired ban removed for identifier: " .. id)
        end
    end
    if removed > 0 then
        log(("Pruned %d expired ban(s)"):format(removed))
        saveBans()
    end
end

local function isPlayerBanned(source)
    pruneExpiredBans()
    local identifiers = getFilteredIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if activeBans[id] then
            return true, activeBans[id]
        end
    end
    return false, nil
end

local allowedIdentifiers = { "license", "steam", "discord", "xbl", "live", "fivem" }

local function getFilteredIdentifiers(source)
    local filtered = {}
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        for _, prefix in ipairs(allowedIdentifiers) do
            if id:sub(1, #prefix + 1) == prefix .. ":" then
                filtered[#filtered + 1] = id
                break
            end
        end
    end
    return filtered
end
local function formatDuration(seconds)
    local days    = math.floor(seconds / 86400)
    local hours   = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local parts   = {}
    if days    > 0 then parts[#parts+1] = days    .. (days    == 1 and " day"    or " days")    end
    if hours   > 0 then parts[#parts+1] = hours   .. (hours   == 1 and " hour"   or " hours")   end
    if minutes > 0 then parts[#parts+1] = minutes .. (minutes == 1 and " minute" or " minutes") end
    if #parts == 0 then return "less than a minute" end
    return table.concat(parts, ", ")
end

local function addBan(source, reason)
    banCounter        = banCounter + 1
    local banId       = ("AUTOMOD-%04d"):format(banCounter)
    local expires     = os.time() + (Config.BanDurationHours * 3600)
    local duration    = formatDuration(Config.BanDurationHours * 3600)
    local identifiers = getFilteredIdentifiers(source)
    for _, id in ipairs(identifiers) do
        activeBans[id] = { banId = banId, expires = expires, reason = reason }
        debug("Ban stored — id: " .. banId .. " | identifier: " .. id)
    end
    saveBans()
    return banId, duration
end

local function getPlayerName(source)
    return GetPlayerName(source) or ("Player #" .. source)
end

local function normalise(msg)
    msg = string.lower(msg)
    msg = msg:gsub("[3]",     "e")
    msg = msg:gsub("[4@]",    "a")
    msg = msg:gsub("[1!|]",   "i")
    msg = msg:gsub("[0]",     "o")
    msg = msg:gsub("[5$]",    "s")
    msg = msg:gsub("[^%a%s]", "")
    debug("Normalised: '" .. msg .. "'")
    return msg
end

local function containsBannedWord(message)
    local norm = normalise(message)
    debug("Scanning against " .. #Config.Words .. " patterns")
    for _, entry in ipairs(Config.Words) do
        if norm:match(entry.pattern) then
            debug("Match — pattern: '" .. entry.pattern .. "' tier: " .. entry.tier)
            return entry
        end
    end
    debug("No banned words detected")
    return nil
end

local function broadcastNotification(msg, notifType)
    if Config.NotifyAll then
        debug(("Broadcasting — type: %s | msg: %s"):format(notifType, msg))
        TriggerClientEvent("orion-automod:notify", -1, {
            title   = "AutoMod",
            message = msg,
            type    = notifType
        })
    end
end

local function doKick(source, playerName, entry)
    log(("Kicking %s (id: %d) — pattern: '%s'"):format(playerName, source, entry.pattern))
    DropPlayer(source, Config.KickMessage)
    CreateThread(function()
        Wait(100)
        broadcastNotification(Config.BroadcastKick:format(playerName), "error")
    end)
end

local function doBan(source, playerName, entry)
    log(("Banning %s (id: %d) — pattern: '%s' | duration: %dh"):format(
        playerName, source, entry.pattern, Config.BanDurationHours
    ))

    local identifiers = getFilteredIdentifiers(source)
    for _, id in ipairs(identifiers) do
        log("Banned identifier: " .. id)
    end

    local banId, duration = addBan(source, "AutoMod: banned word (" .. entry.tier .. ")")
    local dropMsg = Config.BanMessage:format(banId, duration)

    log(("Ban issued — %s | expires in: %s"):format(banId, duration))

    DropPlayer(source, dropMsg)

    CreateThread(function()
        Wait(100)
        broadcastNotification(
            Config.BroadcastBan:format(playerName, Config.BanDurationHours),
            "error"
        )
    end)
end

AddEventHandler("chatMessage", function(source, name, message)
    if source == 0 then return end

    debug(("Chat — player: %d (%s) | message: '%s'"):format(source, name, message))

    local entry = containsBannedWord(message)
    if not entry then return end

    CancelEvent()

    local playerName = getPlayerName(source)

    log(("%s (id: %d) used banned word — pattern: '%s' tier: %s action: %s"):format(
        playerName, source, entry.pattern, entry.tier, entry.action
    ))

    if entry.action == "ban" then
        doBan(source, playerName, entry)
    elseif entry.action == "kick" then
        doKick(source, playerName, entry)
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    Wait(0)

    pruneExpiredBans()

    local banned, banData = isPlayerBanned(source)
    if banned then
        local remaining = banData.expires - os.time()
        local duration  = formatDuration(remaining)
        local banId     = banData.banId or "AUTOMOD-????"
        local msg       = Config.BanMessage:format(banId, duration)
        log(("Blocked banned player '%s' (id: %d) from connecting — %s | expires in: %s"):format(
            name, source, banId, duration
        ))
        deferrals.done(msg)
    else
        deferrals.done()
    end
end)

CreateThread(function()
    loadBans()
    while true do
        Wait(600000)
        pruneExpiredBans()
    end
end)

AddEventHandler("playerDropped", function(reason)
    debug(("Player %d dropped — reason: %s"):format(source, tostring(reason)))
end)
