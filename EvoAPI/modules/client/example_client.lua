
-- EvoAPI Example Client Module
RegisterCommand("evoapi_ping", function()
    TriggerServerEvent("EvoAPI:Example:Ping", {})
end, false)
