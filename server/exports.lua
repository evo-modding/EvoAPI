
exports("RegisterEvent", function(event, cb, perm) EvoAPI.RegisterEvent(event, cb, perm) end)
exports("RegisterCommand", function(name, perm, handler, suggestion) EvoAPI.RegisterCommand(name, perm, handler, suggestion) end)
exports("TriggerClient", function(event, target, data) EvoAPI.TriggerClient(event, target, data) end)
exports("Broadcast", function(event, data) EvoAPI.Broadcast(event, data) end)
exports("Log", function(msg) EvoAPI.Log(msg) end)

exports("GetPlayerData", function(src, cb)
    local identifier = EvoAPI.PrimaryIdentifier(src)
    if not identifier then cb(nil); return end
    MySQL.query("SELECT * FROM evoapi_players WHERE identifier = ? LIMIT 1", {identifier}, function(result)
        cb(result and result[0+1])
    end)
end)
exports("GetGroup", EvoAPI.GetGroup)
exports("HasGroup", EvoAPI.HasGroup)

exports("BanIdentifier", function(actor_src, identifier, name, reason) EvoAPI.BanIdentifier(actor_src, identifier, name, reason) end)
exports("BanPlayer", function(actor_src, target_src, reason) return EvoAPI.BanPlayer(actor_src, target_src, reason) end)
exports("UnbanIdentifier", function(actor_src, identifier) EvoAPI.UnbanIdentifier(actor_src, identifier) end)
exports("KickPlayer", function(actor_src, target_src, reason) return EvoAPI.KickPlayer(actor_src, target_src, reason) end)
exports("AddNote", function(actor_src, identifier, note) EvoAPI.AddNote(actor_src, identifier, note) end)
exports("GetNotes", function(identifier, cb) EvoAPI.GetNotes(identifier, cb) end)
exports("LogAction", function(action, actor_src, target_identifier, target_name, details, color) EvoAPI.LogAction(action, actor_src, target_identifier, target_name, details, color) end)
