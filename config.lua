
Config = {}

-- Branding
Config.FrameworkName = "EvoAPI"

-- Debug mode (owner can toggle via /evoapi_debug on/off)
Config.Debug = false

-- Notifications: feed only (no NUI in core build)
Config.UseToasts = false

-- Watermark HUD (client, DrawText-based, no NUI)
Config.Watermark = {
    Enabled = true,
    Text = "Evo RP",
    X = 0.98,
    Y = 0.95,
    Scale = 0.5,
    Rainbow = true,
    Speed = 0.0015
}

-- Permission groups (add your identifiers)
Config.Groups = {
    ["owner"] = {
        "discord:1407547116045209612"
    },
    ["admin"] = {
        "discord:1407547116045209612"
    },
    ["mod"] = {
        -- "discord:123456789012345678"
    },
    ["user"] = { }
}

-- Database / Discord
Config.UseDatabase = true -- oxmysql required
Config.DiscordWebhook = "" -- optional webhook for logs (joins, leaves, staff actions)
