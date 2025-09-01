return {
  Whitelist = true,
  DiscordRoles = {
    police = "1411872009494724780",
    ems    = "1411872060103462912",
    fire   = "1411872041283485879",
    dot    = "1411872115057229914",
  },

  TicketWebhook = nil,

  Jobs = {
    civ = { label = "Civilian", whitelisted = false, loadout = {} },
    police = {
      label = "Police",
      whitelisted = true,
      loadout = { "WEAPON_STUNGUN", "WEAPON_COMBATPISTOL", "WEAPON_FLASHLIGHT" }
    },
    ems = {
      label = "EMS",
      whitelisted = true,
      loadout = { "WEAPON_FLASHLIGHT", "WEAPON_FIREEXTINGUISHER" }
    },
    fire = {
      label = "Fire",
      whitelisted = true,
      loadout = { "WEAPON_FLASHLIGHT", "WEAPON_FIREEXTINGUISHER" }
    },
    dot = {
      label = "DOT",
      whitelisted = true,
      loadout = { "WEAPON_FLASHLIGHT" }
    },
  },

  Garages = {
    police = {
      blip = { x = 441.7, y = -982.1, z = 30.7, sprite = 60, color = 3, name = "Police Garage" },
      vehicles = { "police", "police2", "police3" },
      heading = 90.0
    },
    ems = {
      blip = { x = 302.7, y = -1434.5, z = 29.8, sprite = 61, color = 1, name = "EMS Garage" },
      vehicles = { "ambulance" },
      heading = 320.0
    },
    fire = {
      blip = { x = 1200.5, y = -1473.6, z = 34.8, sprite = 436, color = 1, name = "Fire Garage" },
      vehicles = { "firetruk" },
      heading = 0.0
    },
    dot = {
      blip = { x = -356.4, y = -134.1, z = 39.0, sprite = 68, color = 5, name = "DOT Garage" },
      vehicles = { "flatbed" },
      heading = 180.0
    }
  }
}
