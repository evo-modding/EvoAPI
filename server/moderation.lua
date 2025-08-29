
local function actorInfo(src)
    return EvoAPI.PrimaryIdentifier(src) or "console", GetPlayerName(src) or "console"
end

function EvoAPI.LogAction(action, actor_src, target_identifier, target_name, details, color)
    local a_id, a_name = actorInfo(actor_src or 0)
    EvoAPI.DBLog(action, a_id, a_name, target_identifier, target_name, details or "")
    EvoAPI.DiscordLog(("EvoAPI %s"):format(action), ("**%s** → **%s**\n%s"):format(a_name, target_name or (target_identifier or "unknown"), details or ""), color or 0x5865F2)
    EvoAPI.Log(("[%s] %s -> %s | %s"):format(action, a_name, target_name or target_identifier or "unknown", details or ""))
end

function EvoAPI.BanIdentifier(actor_src, identifier, name, reason)
    reason = reason or "No reason"
    name = name or "Unknown"
    local _, a_name = actorInfo(actor_src or 0)
    EvoAPI.DBBan(identifier, name, reason, a_name)
    EvoAPI.LogAction("Ban", actor_src, identifier, name, ("Reason: %s"):format(reason), 0xED4245)
end

function EvoAPI.BanPlayer(actor_src, target_src, reason)
    if not GetPlayerName(target_src) then return false, "Invalid target" end
    local identifier = EvoAPI.PrimaryIdentifier(target_src)
    if not identifier then return false, "No identifier" end
    EvoAPI.BanIdentifier(actor_src, identifier, GetPlayerName(target_src), reason)
    DropPlayer(target_src, ("Banned: %s"):format(reason or "No reason"))
    return true
end

function EvoAPI.UnbanIdentifier(actor_src, identifier)
    EvoAPI.DBUnban(identifier)
    EvoAPI.LogAction("Unban", actor_src, identifier, identifier, "Removed ban", 0x57F287)
end

function EvoAPI.KickPlayer(actor_src, target_src, reason)
    if not GetPlayerName(target_src) then return false, "Invalid target" end
    local name = GetPlayerName(target_src)
    local identifier = EvoAPI.PrimaryIdentifier(target_src) or "unknown"
    DropPlayer(target_src, ("Kicked: %s"):format(reason or "No reason"))
    EvoAPI.LogAction("Kick", actor_src, identifier, name, ("Reason: %s"):format(reason or "No reason"), 0xFEE75C)
    return true
end

function EvoAPI.AddNote(actor_src, identifier, note)
    local _, a_name = actorInfo(actor_src or 0)
    EvoAPI.DBAddNote(identifier, note or "", a_name)
    EvoAPI.LogAction("Note", actor_src, identifier, identifier, note or "", 0x5865F2)
end

function EvoAPI.GetNotes(identifier, cb)
    EvoAPI.DBGetNotes(identifier, function(rows) cb(rows or {}) end)
end
