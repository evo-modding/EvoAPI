
-- EvoAPI Client Core
local UI_FOCUS = false

-- UI open
RegisterNetEvent("EvoAPI:ShowUI", function(a, b)
    local title, message
    if type(a) == "table" then
        title = a.title or Config.FrameworkName or "EvoAPI"
        message = a.message or ""
    else
        title = a or Config.FrameworkName or "EvoAPI"
        message = b or ""
    end
    SendNUIMessage({ action = "showUI", title = title, message = message })
    SetNuiFocus(true, true); UI_FOCUS = true
end)

-- Notifications
RegisterNetEvent("EvoAPI:Notify", function(a, b)
    local msg, ntype
    if type(a) == "table" then
        msg = a.msg or "Notification"
        ntype = a.type or "info"
    else
        msg = a or "Notification"
        ntype = b or "info"
    end

    if Config.UseToasts then
        SendNUIMessage({ action = "toast", message = tostring(msg), ntype = tostring(ntype) })
    else
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(("~b~[%s]~s~ %s"):format(Config.FrameworkName or "EvoAPI", msg))
        EndTextCommandThefeedPostTicker(false, true)
    end
end)

-- Close UI
RegisterNUICallback("closeUI", function(_, cb)
    SetNuiFocus(false, false); UI_FOCUS = false
    if cb then cb({ ok = true }) end
end)

-- Dev: test UI
RegisterCommand("evoapi_test_ui", function()
    TriggerEvent("EvoAPI:ShowUI", { title = "EvoAPI UI", message = "Hello from EvoAPI client!" })
end, false)
