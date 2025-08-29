
local function buildPermissionsFile()
    local lines = {}
    table.insert(lines, "add_ace group.admin command allow")
    table.insert(lines, "add_ace group.admin command.quit deny")
    table.insert(lines, "add_ace group.owner command allow")
    table.insert(lines, "add_ace group.owner command.quit deny")

    local map = Config.VMenu and Config.VMenu.PermissionMap or {}
    for group, nodes in pairs(map) do
        for _, node in ipairs(nodes or {}) do
            table.insert(lines, ("add_ace group.%s \"%s\" allow"):format(group, node))
        end
    end

    for group, idents in pairs(Config.Groups or {}) do
        for _, id in ipairs(idents or {}) do
            table.insert(lines, ("add_principal %s group.%s"):format(id, group))
        end
    end

    return table.concat(lines, "\n") .. "\n"
end

local function applyAceLive()
    if Config.VMenu then
        SetConvar("vmenu_menu_toggle_key", tostring(Config.VMenu.ToggleKey or "F1"))
        SetConvar("vmenu_use_permissions", Config.VMenu.UsePermissions and "true" or "false")
        SetConvar("vmenu_ban_defaults", Config.VMenu.BanDefaults and "true" or "false")
    end
    local content = buildPermissionsFile()
    for line in string.gmatch(content, "[^\r\n]+") do
        if line:match("%S") then ExecuteCommand(line) end
    end
end

AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end
    local perms = buildPermissionsFile()
    SaveResourceFile(GetCurrentResourceName(), "permissions.vmenu.cfg", perms, -1)
    applyAceLive()
    EvoAPI.Log("vMenu integration applied (key=" .. (Config.VMenu.ToggleKey or "F1") .. ").")
end)

RegisterNetEvent("EvoAPI:ApplyVMenuPerms")
AddEventHandler("EvoAPI:ApplyVMenuPerms", function()
    applyAceLive()
    EvoAPI.Log("vMenu permissions reapplied from config.")
end)
