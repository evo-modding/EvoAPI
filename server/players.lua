
-- EvoAPI player lifecycle
local joinTimes = {} -- src -> os.time()

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local src = source
    local identifier = EvoAPI.PrimaryIdentifier(src)
    if not identifier then
        setKickReason("No valid identifier found (license/steam/discord).")
        CancelEvent()
        return
    end
    EvoAPI.DBEnsurePlayer(identifier, name)
end)

AddEventHandler("playerJoining", function(oldId)
    local src = source
    local name = GetPlayerName(src) or ("Player "..tostring(src))
    local identifier = EvoAPI.PrimaryIdentifier(src)
    if identifier then
        EvoAPI.DBUpdateLastJoin(identifier)
    end
    joinTimes[src] = os.time()
    EvoAPI.DiscordLog("Player Joined", ("**%s** joined the server\n`%s`"):format(name, identifier or "unknown"), 0x57F287)
end)

AddEventHandler("playerDropped", function(reason)
    local src = source
    local identifier = EvoAPI.PrimaryIdentifier(src)
    local started = joinTimes[src]
    if started and identifier then
        local minutes = math.floor((os.time() - started) / 60)
        EvoAPI.DBAddPlaytime(identifier, minutes)
    end
    joinTimes[src] = nil
    local name = GetPlayerName(src) or ("Player "..tostring(src))
    EvoAPI.DiscordLog("Player Left", ("**%s** left the server\nReason: %s"):format(name, reason or "unknown"), 0xED4245)
end)

exports("GetPlayerData", function(src, cb)
    local identifier = EvoAPI.PrimaryIdentifier(src)
    if not identifier then cb(nil); return end
    EvoAPI.DBGetPlayerByIdentifier(identifier, function(row)
        cb(row)
    end)
end)
