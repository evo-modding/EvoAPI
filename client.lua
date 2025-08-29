
-- EvoAPI Admin Panel Client - v1.3.3
local isOpen = false

-- Open panel when command used
RegisterNetEvent("EvoAPIPanel:Open", function()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openPanel" })
    print("^3[EvoAPI NUI]^0 Panel opened.")
end)

-- Close panel
RegisterNetEvent("EvoAPIPanel:Close", function()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closePanel" })
    print("^3[EvoAPI NUI]^0 Panel closed.")
end)

-- Slash command to toggle
RegisterCommand("evoapi_admin", function()
    if isOpen then
        TriggerEvent("EvoAPIPanel:Close")
    else
        TriggerServerEvent("EvoAPIPanel:RequestOpen")
    end
end, false)

-- Close via ESC
RegisterNUICallback("close", function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

-- Watermark updater
RegisterNetEvent("EvoAPI:Watermark:Set", function(newText)
    SendNUIMessage({ action = "updateWatermark", text = newText })
end)
