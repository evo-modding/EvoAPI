
function EvoAPI.IsAdmin(src)
    local grp = EvoAPI.GetGroup(src)
    return (grp == "owner" or grp == "admin")
end

exports("IsAdmin", EvoAPI.IsAdmin)
exports("GetGroup", EvoAPI.GetGroup)
exports("HasGroup", EvoAPI.HasGroup)
