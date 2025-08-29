
-- EvoAPI Client Exports
exports("Notify", function(msg, ntype)
    TriggerEvent("EvoAPI:Notify", msg, ntype)
end)

exports("ShowUI", function(title, message)
    TriggerEvent("EvoAPI:ShowUI", title, message)
end)
