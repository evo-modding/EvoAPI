
-- EvoAPI Commands

EvoAPI.RegisterCommand("evoapi_players", "admin", function(src)
    local list = {}
    for _, id in ipairs(GetPlayers()) do
        table.insert(list, ("[%s] %s — %s"):format(id, GetPlayerName(id) or "?", EvoAPI.GetGroup(id)))
    end
    TriggerClientEvent("EvoAPI:Notify", src, { msg = "Online: \n" .. table.concat(list, "\n"), type = "info" })
end, "List online players and groups.")

EvoAPI.RegisterCommand("evoapi_data", "admin", function(src, args)
    local target = tonumber(args[1] or "")
    if not target or not GetPlayerName(target) then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "Usage: /evoapi_data <id>", type = "error" })
        return
    end
    exports.EvoAPI:GetPlayerData(target, function(row)
        if not row then
            TriggerClientEvent("EvoAPI:Notify", src, { msg = "No data for that player.", type = "error" })
            return
        end
        local msg = ("Name: %s\nGroup: %s\nPlaytime: %d min\nFirst: %s\nLast: %s")
            :format(row.name or "?", row.group or "user", row.playtime or 0, tostring(row.first_join or "?"), tostring(row.last_join or "?"))
        TriggerClientEvent("EvoAPI:Notify", src, { msg = msg, type = "info" })
    end)
end, "Show stored DB data for a player.")

EvoAPI.RegisterCommand("evoapi_setgroup", "owner", function(src, args)
    local target = tonumber(args[1] or "")
    local group = tostring(args[2] or ""):lower()
    if not target or not GetPlayerName(target) or group == "" then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "Usage: /evoapi_setgroup <id> <owner|admin|mod|user>", type = "error" })
        return
    end
    local identifier = EvoAPI.PrimaryIdentifier(target)
    if not identifier then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "No identifier for target.", type = "error" })
        return
    end
    EvoAPI.DBSetGroup(identifier, group)
    EvoAPI.DiscordLog("Group Changed", ("**%s** set **%s** to group **%s**"):format(GetPlayerName(src) or src, GetPlayerName(target) or target, group), 0xFEE75C)
    TriggerClientEvent("EvoAPI:Notify", src, { msg = "Group updated.", type = "success" })
end, "Set player's group in DB.")

EvoAPI.RegisterCommand("evoapi_reload", "owner", function(src)
    local res = GetCurrentResourceName()
    local cfg = LoadResourceFile(res, "config.lua")
    if not cfg then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "Failed to load config.lua", type = "error" })
        return
    end
    local chunk, err = load(cfg)
    if not chunk then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "Config parse error.", type = "error" })
        print(err)
        return
    end
    local ok, perr = pcall(chunk)
    if not ok then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "Config exec error.", type = "error" })
        print(perr)
        return
    end
    TriggerClientEvent("EvoAPI:Notify", src, { msg = "Config reloaded.", type = "success" })
    EvoAPI.DiscordLog("Config Reloaded", ("By %s"):format(GetPlayerName(src) or src), 0x5865F2)
    -- Reapply vMenu permissions after reload
    TriggerEvent("EvoAPI:ApplyVMenuPerms")
end, "Reload EvoAPI config without restart.")

EvoAPI.RegisterCommand("evoapi_setwatermark", "admin", function(src, args)
    local msg = table.concat(args or {}, " ")
    if msg == "" then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "Usage: /evoapi_setwatermark <text>", type = "error" })
        return
    end
    EvoAPI.Broadcast("EvoAPI:Watermark:Set", msg)
    EvoAPI.DiscordLog("Watermark Updated", ("By %s: %s"):format(GetPlayerName(src) or src, msg), 0x57F287)
end, "Set global watermark text.")
