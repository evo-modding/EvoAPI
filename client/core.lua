
-- EvoAPI Client Core (Core build: no NUI)
local function feed(msg, prefix)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(("%s %s"):format(prefix or "", msg or ""))
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent("EvoAPI:Notify", function(a, b)
    local msg, ntype
    if type(a) == "table" then
        msg = a.msg or "Notification"
        ntype = a.type or "info"
    else
        msg = a or "Notification"
        ntype = b or "info"
    end
    local tag = "~b~[" .. (Config.FrameworkName or "EvoAPI") .. "]~s~"
    feed(msg, tag)
end)
