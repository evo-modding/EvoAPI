
Config = {}

-- Framework branding
Config.FrameworkName = "EvoAPI"

-- Notifications
Config.UseToasts = true -- NUI toast notifications

-- Watermark HUD (client)
Config.Watermark = {
    Enabled = true,
    Text = "Evo RP",
    X = 0.98,  -- right-left
    Y = 0.95,  -- up-down
    Scale = 0.5,
    Rainbow = true,
    Speed = 0.0015
}

-- Permission groups (edit these identifiers)
Config.Groups = {
    ["owner"] = {
        "discord:1407547116045209612" -- you
    },
    ["admin"] = { },
    ["mod"] = { },
    ["user"] = { }
}

-- vMenu integration
Config.VMenu = {
    ToggleKey = "F1",
    UsePermissions = true,
    BanDefaults = false,
    PermissionMap = {
        owner = { "vMenu.Everything" },
        admin = { },
        mod = { },
        user = { }
    }
}

-- Web Panel (beta)
Config.WebPanel = {
    Enabled = true,
    Token = "CHANGE_ME_TO_A_RANDOM_SECRET", -- REQUIRED: set a long random token
    BasePath = "/evoapi" -- panel at http://<ip>:30120/evoapi/panel
}

-- Database / Webhook
Config.UseDatabase = true -- requires oxmysql
Config.DiscordWebhook = "" -- optional: Discord logging
