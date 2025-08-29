
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
    ["admin"] = {
        -- "license:xxxxxxxxxxxxxxxxx"
    },
    ["mod"] = {
        -- "discord:123456789012345678"
    },
    ["user"] = { }
}

-- vMenu integration settings
Config.VMenu = {
    ToggleKey = "F1",
    UsePermissions = true,
    BanDefaults = false,

    -- vMenu ACE nodes per group.
    -- IMPORTANT: vMenu supports many granular permissions. By default we give:
    --   - owner: vMenu.Everything
    --   - admin/mod: (none; add what you need below)
    -- You can add nodes like "vMenu.NoClip", "vMenu.VehicleSpawner.Menu", etc.
    PermissionMap = {
        owner = { "vMenu.Everything" },
        admin = {
            -- "vMenu.NoClip",
            -- "vMenu.Teleport.Menu",
        },
        mod = {
            -- "vMenu.VehicleOptions.Menu",
        },
        user = { }
    }
}

-- Database / Webhook
Config.UseDatabase = true -- requires oxmysql
Config.DiscordWebhook = "" -- optional: add your Discord webhook URL
