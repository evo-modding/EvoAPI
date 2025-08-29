
-- EvoAPI Server Core
EvoAPI = {}
EvoAPI.Events = {}
EvoAPI.Commands = {}

function EvoAPI.Log(msg)
    print(("^4[EvoAPI]^0 %s"):format(tostring(msg)))
end

function EvoAPI.GetIds(src)
    local ids = {license=nil, steam=nil, discord=nil, ip=nil}
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1,8) == "license:" then ids.license = id
        elseif id:sub(1,6) == "steam:" then ids.steam = id
        elseif id:sub(1,8) == "discord:" then ids.discord = id
        elseif id:sub(1,3) == "ip:" then ids.ip = id end
    end
    return ids
end

function EvoAPI.PrimaryIdentifier(src)
    local ids = EvoAPI.GetIds(src)
    return ids.license or ids.steam or ids.discord or ids.ip
end

function EvoAPI.GetGroup(src)
    local ids = GetPlayerIdentifiers(src)
    for group, list in pairs(Config.Groups or {}) do
        for _, want in ipairs(list) do
            for _, have in ipairs(ids) do
                if want == have then return group end
            end
        end
    end
    return "user"
end

function EvoAPI.HasGroup(src, group)
    if group == nil or group == "" then return true end
    if group == "user" then return true end
    local order = { owner=4, admin=3, mod=2, user=1 }
    local have = EvoAPI.GetGroup(src)
    return (order[have] or 0) >= (order[group] or 0)
end

-- Events with optional permission guard
function EvoAPI.RegisterEvent(event, callback, requiredGroup)
    if EvoAPI.Events[event] then return end
    EvoAPI.Events[event] = true
    RegisterNetEvent(event)
    AddEventHandler(event, function(data)
        local src = source
        if requiredGroup and not EvoAPI.HasGroup(src, requiredGroup) then
            TriggerClientEvent("EvoAPI:Notify", src, { msg = "You are not allowed to do that.", type = "error" })
            return
        end
        callback(src, data)
    end)
    EvoAPI.Log(("Registered event: ^3%s^0 (perm: %s)"):format(event, tostring(requiredGroup or "none")))
end

-- Commands with permission guard
function EvoAPI.RegisterCommand(name, requiredGroup, handler, suggestion)
    if EvoAPI.Commands[name] then return end
    RegisterCommand(name, function(src, args, raw)
        if requiredGroup and not EvoAPI.HasGroup(src, requiredGroup) then
            TriggerClientEvent("EvoAPI:Notify", src, { msg = "You are not allowed to use this command.", type = "error" })
            return
        end
        handler(src, args, raw)
    end, false)
    if suggestion then
        TriggerClientEvent('chat:addSuggestion', -1, "/"..name, suggestion)
    end
    EvoAPI.Commands[name] = true
    EvoAPI.Log(("Registered command: /%s (perm: %s)"):format(name, tostring(requiredGroup or "none")))
end

-- Client triggers
function EvoAPI.TriggerClient(event, target, payload) TriggerClientEvent(event, target, payload) end
function EvoAPI.Broadcast(event, payload) for _, id in ipairs(GetPlayers()) do TriggerClientEvent(event, id, payload) end end

-- Client to server gateway
RegisterNetEvent("EvoAPI:TriggerServer")
AddEventHandler("EvoAPI:TriggerServer", function(event, data)
    if EvoAPI.Events[event] then
        TriggerEvent(event, data)
    else
        EvoAPI.Log(("Unknown event: %s"):format(event))
    end
end)
