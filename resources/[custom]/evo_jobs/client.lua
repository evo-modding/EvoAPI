local cfgRaw = LoadResourceFile(GetCurrentResourceName(), "config.lua")
assert(cfgRaw, "[evo_jobs] config.lua missing")
local Config = assert(load(cfgRaw))()

local currentJob = "civ"
local onDuty = false

CreateThread(function()
    for dept, g in pairs(Config.Garages) do
        local b = AddBlipForCoord(g.blip.x + 0.0, g.blip.y + 0.0, g.blip.z + 0.0)
        SetBlipSprite(b, g.blip.sprite or 357)
        SetBlipColour(b, g.blip.color or 0)
        SetBlipAsShortRange(b, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(g.blip.name or (dept.." Garage"))
        EndTextCommandSetBlipName(b)
    end
end)

RegisterNetEvent("evo_jobs:setJob", function(job, duty)
    currentJob = job or "civ"
    onDuty = duty and true or false
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(("~g~Job: ~w~%s  ~g~Duty: ~w~%s"):format(currentJob, tostring(onDuty)))
    EndTextCommandThefeedPostTicker(false, true)
end)

RegisterNetEvent("evo_jobs:giveLoadout", function(list)
    local ped = PlayerPedId()
    if type(list) ~= "table" then return end
    for _, w in ipairs(list) do
        GiveWeaponToPed(ped, joaat(w), 250, false, true)
    end
end)

RegisterNetEvent("evo_jobs:spawnJobVehicle", function(model, x, y, z, h)
    local m = joaat(model)
    RequestModel(m)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(m) and GetGameTimer() < timeout do Wait(50) RequestModel(m) end
    if not HasModelLoaded(m) then
        TriggerEvent("chat:addMessage", { args = { "^1VEH", "Model failed to load: "..tostring(model) } })
        return
    end
    local veh = CreateVehicle(m, x + 0.0, y + 0.0, z + 0.5, h or 0.0, true, false)
    SetVehicleOnGroundProperly(veh)
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(m)
end)

RegisterNetEvent("evo_jobs:doRevive", function()
    local ped = PlayerPedId()
    NetworkResurrectLocalPlayer(GetEntityCoords(ped), GetEntityHeading(ped), true, true, false)
    SetEntityHealth(ped, 200)
    ClearPedTasksImmediately(ped)
    ClearPedBloodDamage(ped)
end)

RegisterNetEvent("evo_jobs:doHeal", function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
end)

RegisterNetEvent("evo_jobs:ticketNotify", function(amount, reason, officerName)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(("~y~You received a ticket: ~w~$%d
~c~Reason: %s
~c~Officer: %s"):format(amount, reason or "N/A", officerName or "Unknown"))
    EndTextCommandThefeedPostTicker(false, true)
end)

-- === EVO RP Auto Respawn Handler ===
CreateThread(function()
    -- Disable default dead screen, keep chat working
    exports.spawnmanager:setAutoSpawn(false)
    while true do
        Wait(500)
        local ped = PlayerPedId()
        if IsEntityDead(ped) then
            Wait(3000) -- 3 second delay before respawn

            -- Get death coords or default to Pillbox hospital
            local coords = GetEntityCoords(ped)
            if coords == vector3(0,0,0) then
                coords = vector3(307.0, -1433.4, 29.9) -- Pillbox spawn
            end

            -- Actually respawn
            NetworkResurrectLocalPlayer(coords, GetEntityHeading(ped), true, true, false)
            SetEntityInvincible(ped, false)
            ClearPedBloodDamage(ped)
            SetEntityHealth(ped, 200)

            -- Force cleanup to avoid black screen
            DoScreenFadeOut(500)
            Wait(500)
            DoScreenFadeIn(1000)

            -- Tell FiveM you're fully alive
            TriggerEvent("playerSpawned")
        end
    end
end)

