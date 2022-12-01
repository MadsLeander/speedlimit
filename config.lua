Config = {}

-- Whether or not it is enabled by default (if false people have to use the /speedlimit command to enable it)
Config.Enabled = true

-- The type of sign and advisory sign to use (see the bottom of this file for a list of possible signs)
Config.SignType = 'us-standard'
Config.AdvisoryType = 'us-advisory' -- or false (no quotes) to disable

-- If set to true, only the driver of the vehicle will be able to see the speedlimit
Config.DriverOnly = false

-- If set to true, it will only display the speedlimit for x amount of time when it changes before it fades away
Config.DisplayOnlyOnChange = false
Config.ChangeDisplayTime = 3000 -- ms the speedlimit should be displayed after change if Config.DisplayOnlyOnChange is set to true

-- Speedlimits for certain areas. NOTE: Not every road draws it speed limit from these.
Config.Speedlimits = {
    Default = 35,
    DirtRoads = 35, -- Most, but not all dirt roads
    PaletoBay = 35,
    SandyShores = 35,
    Freeway = 60
}

-- Localization for the notifications
Config.Localization = {
    ShowSpeedlimit = "The speedlimit is now shown!",
    HideSpeedlimit = "The speedlimit is now hidden!"
}

-- Blacklisted vehicle classes
--[[
13: Cycles
14: Boats
15: Helicopters
16: Planes
]]--
Config.BlacklistedClasses = {
    [13] = true, [14] = true, [15] = true, [16] = true
}

--[[
List of possible signs.

Regular Speedlimit Signs:
us-standard
us-oregon
us-metric
canada-standard
canada-ontario
canada-yt-bc (Yukon and British Columbia)
germany
japan
united-kingdom
amber (Sweden, Finland, Iceland etc.)
australia

Advisory/Recomended Speedlimit Signs:
us-advisory
eu-advisory
sweden-advisory
uk-advisory
]]--
