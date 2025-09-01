-- =============================
-- EVO RP CORE - FIXED CLIENT
-- Handles spawning, respawn, watermark, and vMenu compatibility
-- =============================

-- === Player Spawn / Respawn ===
local function doSpawn(x, y, z, h)
    local ped = PlayerPedId()

    -- Move player to coords
    RequestCollisionAtCoord(x, y, z)
    SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
    SetEntityHeading(ped, h or 0.0)

    -- Reset health, remove freeze
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    SetEntityHealth(ped, 200)
    ClearPedTasksImmediately(ped)
    ClearPedBloodDamage(ped)

    -- Wait for map collisions before unfreeze
    while not HasCollisionLoadedAroundEntity(ped) do
        Wait(50)
    end

    -- Remove loading screen
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
end

-- Default spawn position (Pillbox)
local defaultSpawn = vector3(307.0, -1433.4, 29.9)
local defaultHeading = 70.0

-- Override spawnmanager to auto-respawn
CreateThread(function()
    exports.spawnmanager:setAutoSpawn(false)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    while not NetworkIsPlayerActive(PlayerId()) do Wait(50) end

    -- Initial spawn
    doSpawn(defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, defaultHeading)
end)

-- Auto-respawn system
CreateThread(function()
    local respawnDelay = 3000 -- 3 seconds
    while true do
        Wait(500)
        local ped = PlayerPedId()
        if IsEntityDead(ped) then
            Wait(respawnDelay)
            doSpawn(defaultSpawn.x, defaultSpawn.y, defaultSpawn.z, defaultHeading)

            -- Reset wanted level & enable chat again
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
            DisplayRadar(true)
            SetPauseMenuActive(false)

            TriggerEvent("chat:clear")
            TriggerEvent("chat:addMessage", {
                color = {0, 255, 0},
                args = {"^2SYSTEM", "You have been automatically respawned"}
            })

            TriggerEvent("playerSpawned")
        end
    end
end)

-- Block wanted level permanently
CreateThread(function()
    while true do
        Wait(0)
        if GetPlayerWantedLevel(PlayerId()) ~= 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
    end
end)

-- Disable unused events
RegisterNetEvent('vmenu_rp_core:duty', function(_) end)
RegisterNetEvent('vmenu_rp_core:dept', function(_) end)

-- =============================
-- EVO API Rainbow Watermark (HUD)
-- =============================

local enabled = true
local text = "EVO API"
local x, y, scale = Config.Watermark.X, Config.Watermark.Y, Config.Watermark.Scale
local rainbow = Config.Watermark.Rainbow
local speed = Config.Watermark.Speed
local hue = 0.0

-- HSV → RGB conversion
local function HSVToRGB(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    local r, g, b
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q end
    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

local function DrawBottomRight(txt)
    local r, g, b = 255, 255, 255
    if rainbow then
        r, g, b = HSVToRGB(hue, 1, 1)
        hue = hue + (speed or 0.0015)
        if hue > 1 then hue = 0 end
    end
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextRightJustify(true)
    SetTextWrap(0.0, x)
    SetTextEntry("STRING")
    AddTextComponentString(txt)
    DrawText(x, y)
end

-- Allow server to change watermark dynamically
RegisterNetEvent("EvoAPI:Watermark:Set", function(newText)
    text = tostring(newText or text or "Evo RP")
end)

-- Allow manual editing via command
RegisterCommand("evoapi_wm", function(_, args)
    local msg = table.concat(args or {}, " ")
    if msg ~= "" then text = msg end
end, false)

-- Draw watermark constantly
CreateThread(function()
    while true do
        Wait(0)
        if enabled and text and text ~= "" then
            DrawBottomRight(text)
        else
            Wait(500)
        end
    end
end)
