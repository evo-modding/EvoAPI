
local function send(webhook, payload)
    if not webhook or webhook == "" then return end
    PerformHttpRequest(webhook, function() end, "POST", json.encode(payload), {["Content-Type"]="application/json"})
end

function EvoAPI.DiscordLog(title, description, color)
    local webhook = Config.DiscordWebhook
    if not webhook or webhook == "" then return end
    local embed = {{
        ["title"] = tostring(title or "EvoAPI"),
        ["description"] = tostring(description or ""),
        ["color"] = tonumber(color or 0x5865F2),
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
    send(webhook, { username = "EvoAPI", embeds = embed })
end

exports("DiscordLog", EvoAPI.DiscordLog)
