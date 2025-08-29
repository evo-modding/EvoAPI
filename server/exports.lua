
-- EvoAPI Server Exports
exports("RegisterEvent", function(event, cb, perm)
    EvoAPI.RegisterEvent(event, cb, perm)
end)

exports("RegisterCommand", function(name, perm, handler, suggestion)
    EvoAPI.RegisterCommand(name, perm, handler, suggestion)
end)

exports("TriggerClient", function(event, target, data)
    EvoAPI.TriggerClient(event, target, data)
end)

exports("Broadcast", function(event, data)
    EvoAPI.Broadcast(event, data)
end)

exports("Log", function(msg)
    EvoAPI.Log(msg)
end)

exports("GetPlayerData", function(src, cb)
    local identifier = EvoAPI.PrimaryIdentifier(src)
    if not identifier then cb(nil); return end
    MySQL.query("SELECT * FROM evoapi_players WHERE identifier = ? LIMIT 1", {identifier}, function(result)
        cb(result and result[0+1])
    end)
end)

exports("GetGroup", EvoAPI.GetGroup)
exports("HasGroup", EvoAPI.HasGroup)
