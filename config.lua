---@type AimlabConfig
local Config = {}

Config.openCommandName = "aimlab"
Config.openCommandKey = "F6"

-- Set to true if you don't want to use the built in weapon system and instead let players use their own weapons.
Config.ownWeapon = false

---@type AimlabUIConfig
Config.UI = {
    hudPosition  = 'center-right',
    primaryColor = '#E53935',
}

-- set enabled to false if you dont want to override weather and time
---@type AimlabWeatherConfig
Config.Weather = {
    enabled = true,
    weather = 'EXTRASUNNY',
    time    = { hours = 13, mins = 0 },
}

Config.Aimlab = lib.require 'config.aimlab'

return Config