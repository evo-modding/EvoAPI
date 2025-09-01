-- =======================================
-- EVO RP CORE - SERVER (FINAL FIX)
-- =======================================

-- Default spawn coords (Pillbox)
local defaultSpawn = vector3(307.0, -1433.4, 29.9)
local defaultHeading = 70.0

-- Force instant spawn on join
RegisterNetEvent('vmenu_rp_core:requestSpawn', function()
    local src = source
    TriggerClientEvent('vmenu_rp_core:spawn', src, defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, defaultHeading)
end)

-- Optional duty toggle
local onDuty = {}

RegisterCommand('duty', function(source)
    local src = source
    onDuty[src] = not onDuty[src]
    TriggerClientEvent('vmenu_rp_core:duty', src, onDuty[src])
end)

-- Optional department setting
RegisterCommand('dept', function(source, args)
    local src = source
    local dept = args[1] and tostring(args[1]):lower() or 'civ'
    TriggerClientEvent('vmenu_rp_core:dept', src, dept)
end)

-- Cleanup duty when players leave
AddEventHandler('playerDropped', function()
    onDuty[source] = nil
end)
