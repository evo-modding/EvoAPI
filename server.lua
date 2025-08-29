
-- EvoAPI v1.3.3 server patch
local function hasGroup(src, group)
    return exports.EvoAPI:HasGroup(src, group)
end

-- NUI open request with permission check
RegisterNetEvent("EvoAPIPanel:RequestOpen")
AddEventHandler("EvoAPIPanel:RequestOpen", function()
    local src = source
    if not hasGroup(src, "mod") then
        TriggerClientEvent("EvoAPI:Notify", src, { msg = "No permission to open EvoAPI admin panel", type = "error" })
        return
    end
    TriggerClientEvent("EvoAPIPanel:Open", src)
end)

-- NUI fetch players
RegisterNUICallback("fetchPlayers", function(_, cb)
    local src = source
    if not hasGroup(src, "mod") then
        cb({ ok=false, error="forbidden" }); return
    end
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        local name = GetPlayerName(id) or "?"
        local ping = GetPlayerPing(id) or 0
        local group = exports.EvoAPI:GetGroup(id) or "user"
        local ident = exports.EvoAPI:PrimaryIdentifier(id) or "unknown"
        players[#players+1] = { id=tonumber(id), name=name, ping=ping, group=group, identifier=ident }
    end
    cb({ ok=true, players=players })
end)

-- Set watermark globally
RegisterNUICallback("actionSetWatermark", function(data, cb)
    local src = source
    if not hasGroup(src, "admin") then
        cb({ ok=false, error="forbidden" }); return
    end
    local msg = tostring(data.text or "")
    if msg == "" then cb({ ok=false, error="text required" }); return end
    TriggerClientEvent("EvoAPI:Watermark:Set", -1, msg)
    exports.EvoAPI:LogAction("Watermark", src, "", "", "Set to: "..msg, 0x57F287)
    cb({ ok=true })
end)
