local cfgRaw = LoadResourceFile(GetCurrentResourceName(), "config.lua")
assert(cfgRaw, "[evo_jobs] config.lua missing")
local Config = assert(load(cfgRaw))()

local players = {}

local function getJob(src) return (players[src] and players[src].job) or "civ" end
local function setJob(src, job)
    players[src] = players[src] or { job = "civ", duty = false }
    players[src].job = job
    TriggerClientEvent("evo_jobs:setJob", src, job, players[src].duty)
end
local function setDuty(src, state)
    players[src] = players[src] or { job = "civ", duty = false }
    players[src].duty = state and true or false
    TriggerClientEvent("evo_jobs:setJob", src, players[src].job, players[src].duty)
end

local function hasDiscordRole(src, roleId)
    if not Config.Whitelist or not roleId then return true end
    if GetResourceState('Badger_Discord_API') ~= 'started' then return true end
    local ok, result = pcall(function()
        return exports['Badger_Discord_API']:IsRolePresent(src, tostring(roleId))
    end)
    return ok and result or true
end

RegisterCommand("job", function(source, args)
    local src = source
    local job = args[1] and args[1]:lower() or "civ"
    local jobData = Config.Jobs[job]
    if not jobData then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1JOBS", "Invalid job." } })
        return
    end
    if jobData.whitelisted then
        local roleId = Config.DiscordRoles[job]
        if not hasDiscordRole(src, roleId) then
            TriggerClientEvent("chat:addMessage", src, { args = { "^1JOBS", "Not whitelisted for "..jobData.label } })
            return
        end
    end
    setJob(src, job)
    setDuty(src, job ~= "civ")
    TriggerClientEvent("evo_jobs:giveLoadout", src, jobData.loadout or {})
    TriggerClientEvent("chat:addMessage", src, { args = { "^2JOBS", "You are now "..(players[src].duty and "on" or "off").." duty as "..jobData.label } })
end, false)

RegisterCommand("duty", function(source)
    local src = source
    local duty = players[src] and players[src].duty or false
    setDuty(src, not duty)
    TriggerClientEvent("chat:addMessage", src, { args = { "^2JOBS", "Duty: "..tostring(players[src].duty) } })
end, false)

RegisterCommand("jobcar", function(source, args)
    local src = source
    local job = getJob(src)
    local garage = Config.Garages[job]
    if not garage then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1JOBS", "Your job has no garage." } })
        return
    end
    local index = tonumber(args[1] or "1") or 1
    local model = garage.vehicles[index]
    if not model then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1JOBS", "Invalid vehicle index." } })
        return
    end
    TriggerClientEvent("evo_jobs:spawnJobVehicle", src, model, garage.blip.x, garage.blip.y, garage.blip.z, garage.heading or 0.0)
end, false)

RegisterCommand("revive", function(source, args)
    local src = source
    local job = getJob(src)
    if job ~= "ems" and job ~= "police" and job ~= "fire" then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1EMS", "You are not EMS/PD/Fire." } })
        return
    end
    if not (players[src] and players[src].duty) then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1EMS", "Go on duty." } })
        return
    end
    local target = tonumber(args[1] or "-1") or -1
    if target < 0 then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1EMS", "Usage: /revive [id]" } })
        return
    end
    TriggerClientEvent("evo_jobs:doRevive", target)
end, false)

RegisterCommand("heal", function(source, args)
    local src = source
    local job = getJob(src)
    if job ~= "ems" and job ~= "police" and job ~= "fire" then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1EMS", "You are not EMS/PD/Fire." } })
        return
    end
    if not (players[src] and players[src].duty) then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1EMS", "Go on duty." } })
        return
    end
    local target = tonumber(args[1] or "-1") or -1
    if target < 0 then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1EMS", "Usage: /heal [id]" } })
        return
    end
    TriggerClientEvent("evo_jobs:doHeal", target)
end, false)

RegisterCommand("ticket", function(source, args)
    local src = source
    local job = getJob(src)
    if job ~= "police" then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1PD", "Only police can ticket." } })
        return
    end
    if not (players[src] and players[src].duty) then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1PD", "Go on duty." } })
        return
    end
    local target = tonumber(args[1] or "-1") or -1
    local amount = tonumber(args[2] or "0") or 0
    if target < 0 or amount <= 0 then
        TriggerClientEvent("chat:addMessage", src, { args = { "^1PD", "Usage: /ticket <id> <amount> <reason>" } })
        return
    end
    local reason = table.concat(args, " ", 3)
    TriggerClientEvent("evo_jobs:ticketNotify", target, amount, reason, GetPlayerName(src))
end, false)

AddEventHandler("playerDropped", function()
    players[source] = nil
end)
