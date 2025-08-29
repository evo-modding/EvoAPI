
local function notify(src, msg, ntype)
    TriggerClientEvent("EvoAPI:Notify", src, { msg = msg, type = ntype or "info" })
end

local function requireOnlineTarget(src, arg)
    local target = tonumber(arg or "")
    if not target or not GetPlayerName(target) then
        notify(src, "Invalid or offline player ID. Usage: see /help or try the Admin Panel.", "error")
        return nil
    end
    return target
end

-- Players list
EvoAPI.RegisterCommand("evoapi_players", "admin", function(src)
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        table.insert(list, ("[%s] %s — %s"):format(id, GetPlayerName(id) or "?", EvoAPI.GetGroup(id)))
    end
    notify(src, "Online:\n" .. table.concat(list, "\n"), "info")
end, "List online players and groups.")

-- Player DB info
EvoAPI.RegisterCommand("evoapi_data", "admin", function(src, args)
    local target = requireOnlineTarget(src, args[1])
    if not target then
        notify(src, "Usage: /evoapi_data <id> — target must be online.", "error")
        return
    end
    exports.EvoAPI:GetPlayerData(target, function(row)
        if not row then
            notify(src, "No data for that player.", "error"); return
        end
        local msg = ("Name: %s\nGroup: %s\nPlaytime: %d min\nFirst: %s\nLast: %s")
            :format(row.name or "?", row.group or "user", row.playtime or 0, tostring(row.first_join or "?"), tostring(row.last_join or "?"))
        notify(src, msg, "info")
    end)
end, "Show stored DB data for a player.")

-- Group management
EvoAPI.RegisterCommand("evoapi_setgroup", "owner", function(src, args)
    local target = requireOnlineTarget(src, args[1])
    local group = tostring(args[2] or ""):lower()
    if not target or group == "" then
        notify(src, "Usage: /evoapi_setgroup <id> <owner|admin|mod|user>", "error")
        return
    end
    local identifier = EvoAPI.PrimaryIdentifier(target)
    if not identifier then
        notify(src, "No identifier found for target.", "error")
        return
    end
    EvoAPI.DBSetGroup(identifier, group)
    EvoAPI.LogAction("Group Change", src, identifier, GetPlayerName(target), ("Set group to %s"):format(group), 0xFEE75C)
    notify(src, "Group updated.", "success")
end, "Set player's group in DB.")

-- Ban
EvoAPI.RegisterCommand("evoapi_ban", "admin", function(src, args)
    local target = requireOnlineTarget(src, args[1])
    if not target then
        notify(src, "Usage: /evoapi_ban <id> <reason>", "error")
        return
    end
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    if reason == "" then reason = "No reason" end
    local ok, err = EvoAPI.BanPlayer(src, target, reason)
    if ok then notify(src, "Player banned.", "success") else notify(src, err or "Failed to ban.", "error") end
end, "Ban a player by ID.")

-- Unban
EvoAPI.RegisterCommand("evoapi_unban", "owner", function(src, args)
    local identifier = tostring(args[1] or "")
    if identifier == "" then
        notify(src, "Usage: /evoapi_unban <license:...|steam:...|discord:...>", "error")
        return
    end
    EvoAPI.UnbanIdentifier(src, identifier)
    notify(src, "Unbanned.", "success")
end, "Unban by identifier.")

-- Kick
EvoAPI.RegisterCommand("evoapi_kick", "mod", function(src, args)
    local target = requireOnlineTarget(src, args[1])
    if not target then
        notify(src, "Usage: /evoapi_kick <id> <reason>", "error")
        return
    end
    table.remove(args, 1)
    local reason = table.concat(args, " ")
    if reason == "" then reason = "No reason" end
    local ok, err = EvoAPI.KickPlayer(src, target, reason)
    if ok then notify(src, "Player kicked.", "success") else notify(src, err or "Failed to kick.", "error") end
end, "Kick a player by ID.")

-- Add Note
EvoAPI.RegisterCommand("evoapi_addnote", "admin", function(src, args)
    local target = requireOnlineTarget(src, args[1])
    if not target then
        notify(src, "Usage: /evoapi_addnote <id> <text>", "error")
        return
    end
    table.remove(args, 1)
    local note = table.concat(args, " ")
    if note == "" then
        notify(src, "Usage: /evoapi_addnote <id> <text>", "error")
        return
    end
    local identifier = EvoAPI.PrimaryIdentifier(target)
    EvoAPI.AddNote(src, identifier, note)
    notify(src, "Note added.", "success")
end, "Add a staff note for a player.")

-- Notes list
EvoAPI.RegisterCommand("evoapi_notes", "admin", function(src, args)
    local target = requireOnlineTarget(src, args[1])
    if not target then
        notify(src, "Usage: /evoapi_notes <id>", "error")
        return
    end
    local identifier = EvoAPI.PrimaryIdentifier(target)
    EvoAPI.GetNotes(identifier, function(rows)
        if #rows == 0 then
            notify(src, "No notes found for this player.", "info"); return
        end
        for _, r in ipairs(rows) do
            notify(src, ("[%s] %s: %s"):format(tostring(r.timestamp or "?"), tostring(r.added_by or "staff"), tostring(r.note or "")), "info")
        end
    end)
end, "List recent notes for a player.")

-- Watermark
EvoAPI.RegisterCommand("evoapi_setwatermark", "admin", function(src, args)
    local msg = table.concat(args or {}, " ")
    if msg == "" then
        notify(src, "Usage: /evoapi_setwatermark <text>", "error")
        return
    end
    EvoAPI.Broadcast("EvoAPI:Watermark:Set", msg)
    EvoAPI.LogAction("Watermark", src, "", "", ("Set to: %s"):format(msg), 0x57F287)
    notify(src, "Watermark updated.", "success")
end, "Set global watermark text.")

-- Config reload
EvoAPI.RegisterCommand("evoapi_reload", "owner", function(src)
    local res = GetCurrentResourceName()
    local cfg = LoadResourceFile(res, "config.lua")
    if not cfg then notify(src, "Failed to load config.lua", "error"); return end
    local chunk, err = load(cfg)
    if not chunk then notify(src, "Config parse error.", "error"); print(err); return end
    local ok, perr = pcall(chunk)
    if not ok then notify(src, "Config exec error.", "error"); print(perr); return end
    notify(src, "Config reloaded.", "success")
    EvoAPI.LogAction("Config Reload", src, "", "", "Config reloaded", 0x5865F2)
end, "Reload EvoAPI config without restart.")

-- Debug toggle
EvoAPI.RegisterCommand("evoapi_debug", "owner", function(src, args)
    local val = tostring(args[1] or ""):lower()
    if val ~= "on" and val ~= "off" then
        notify(src, "Usage: /evoapi_debug on|off", "error"); return
    end
    Config.Debug = (val == "on")
    notify(src, "Debug: " .. tostring(Config.Debug), "info")
end, "Toggle debug mode: /evoapi_debug on|off")

-- NEW: List bans for verification
EvoAPI.RegisterCommand("evoapi_bans", "admin", function(src)
    MySQL.query("SELECT name, identifier, reason, banned_by, timestamp FROM evoapi_bans ORDER BY id DESC LIMIT 25", {}, function(rows)
        if not rows or #rows == 0 then
            notify(src, "No active bans.", "info"); return
        end
        notify(src, "[EvoAPI Bans] Showing latest " .. tostring(#rows), "info")
        for _, r in ipairs(rows) do
            local line = ("%s | %s | Reason: %s | By: %s | %s")
                :format(r.name or "Unknown", r.identifier or "id", r.reason or "None", r.banned_by or "staff", tostring(r.timestamp or ""))
            notify(src, line, "info")
        end
    end)
end, "List recent bans from database.")
