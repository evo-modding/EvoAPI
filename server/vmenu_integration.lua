
-- EvoAPI vMenu Integration
local function buildPermissionsFile()
    local lines = {}
    -- Base: prevent /quit for admins/owners
    table.insert(lines, "add_ace group.admin command allow")
    table.insert(lines, "add_ace group.admin command.quit deny")
    table.insert(lines, "add_ace group.owner command allow")
    table.insert(lines, "add_ace group.owner command.quit deny")

    -- vMenu nodes per group
    local map = Config.VMenu and Config.VMenu.PermissionMap or {}
    for group, nodes in pairs(map) do
        for _, node in ipairs(nodes or {}) do
            table.insert(lines, ("add_ace group.%s \"%s\" allow"):format(group, node))
        end
    end

    -- Principals from Config.Groups
    for group, idents in pairs(Config.Groups or {}) do
        for _, id in ipairs(idents or {}) do
            table.insert(lines, ("add_principal %s group.%s"):format(id, group))
        end
    end

    return table.concat(lines, "\n") .. "\n"
end

local function applyAceLive()
    -- Apply convars
    if Config.VMenu then
        SetConvar("vmenu_menu_toggle_key", tostring(Config.VMenu.ToggleKey or "F1"))
        SetConvar("vmenu_use_permissions", Config.VMenu.UsePermissions and "true" or "false")
        SetConvar("vmenu_ban_defaults", Config.VMenu.BanDefaults and "true" or "false")
    end
    -- Apply ACE rules live
    local content = buildPermissionsFile()
    for line in string.gmatch(content, "[^\r\n]+") do
        if line:match("%S") then
            ExecuteCommand(line)
        end
    end
end

AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end
    -- Save generated permissions file inside EvoAPI so you can exec it if desired
    local perms = buildPermissionsFile()
    SaveResourceFile(GetCurrentResourceName(), "permissions.vmenu.cfg", perms, -1)
    applyAceLive()
    EvoAPI.Log("vMenu integration applied (key=" .. (Config.VMenu.ToggleKey or "F1") .. ").")
end)

-- Re-apply on /evoapi_reload
RegisterNetEvent("EvoAPI:ApplyVMenuPerms")
AddEventHandler("EvoAPI:ApplyVMenuPerms", function()
    applyAceLive()
    EvoAPI.Log("vMenu permissions reapplied from config.")
end)
