Config = {}

Config.Debug = false           -- If you want to see the debug messages in the console, you can make it true.

Config.Lang = 'en'             -- [locales/.lua]

Config.PerformanceMode = false --  true (optional)

Config.CleanZone = false       --  true (optional) (for zombie servers)

Config.HideRadar = false       --  true (optional)

Config.Logs = {
    Status = false,    --  true (optional)
    Logger = 'discord' -- 'discord', 'fivemerr', 'ox' (ox support: fivemanage, datadog, grafana loki logging )
}

Config.DeleteButton = true

Config.DefaultSlots = 1

-- if 'set um:NewPlayerApartmentInsideStart false in server.cfg' this coords will be used.
Config.NewPlayerNoApartmentStartCoords = vector4(-1037.11, -2736.96, 20.17, 323.76)

Config.NoSpawnMenuOnlyLastLocation = {
    Status = true,                -- If you make it true, the character will spawn at Last Location.
    gtaVNativeAndCutScene = true, -- true / false
}

--[[
    customExport = true, comp qbx_idcard, um-idcard bl_idcard or custom
    for custom: server > editable > functions.lua
]]
Config.StarterItems = {
    { item = 'phone',          amount = 1 },
    { item = 'id_card',        amount = 1, customExport = false },
    { item = 'driver_license', amount = 1, customExport = false },
}

Config.CustomHud = function(bool)
    if bool then
        -- Example: exports['myhud']:SetDisplay(false)
        Debug('Hud is hidden', 'debug')
    else
        -- Example: exports['myhud']:SetDisplay(true)
        Debug('Hud is show', 'debug')
    end
end


Config.Dob = {
    Lowest = 1900,
    Highest = 2006,
    Notify = {
        invalid = 'Invalid date of birth %s',
        exploit = 'Special Character Detected %s'
    }
}

-----------------------------------------------------------------------------------------------------------------
-- UM - Multi Character | Customize Settings
-----------------------------------------------------------------------------------------------------------------

Config.CinematicMode = false -- If you want to use cinematic mode, you can make it true (um special?)

Config.BackgroundMusic = {
    Status = false,       -- If you want to use background music, you can make it true.
    Name = 'bgmusic.mp3', -- [web/build/audio/]
    Volume = 0.2
}

Config.Pages = {
    Credits = {
        Status = true,
        List = Credits.List -- [list/creditslist.lua]
    },
    Store = {
        Status = false,
        URL = 'https://cr5m.com'
    }
}

Config.Coords = {
    Single = Coords.List[5], -- If random false [list/coordslist.lua] | all coords = https://alp1x.github.io/um-multi-coords/
    Random = false
}

Config.Effects = {
    Status = false,          -- If you want to use effects, you can make it true.
    Single = Effect.List[6], -- If random false [list/effectlist.lua]
    Random = false
}
--decrypt by cr leak discord.gg/fxd
Config.Animation = {
    -- If you have a custom animation menu, customize the export in animationlist.lua or use scenario
    Status = false,             -- If you want to use animations, you can make it true.
    Single = Animation.List[1], -- If random false [list/animationlist.lua]
    Random = false,
    Scenario = {
        Status = false,                     -- If you want to use scenario, you can make it true.
        Single = Animation.ScenarioList[2], -- If random false [list/animationlist.lua]
        Random = false
    }
}

Config.TimeSettings = {
    SyncStatus = false, -- false: Custom Time & Weather | true: Server Time
    Time = 17,          -- recommended 10-23 | not 00 or 00:00
    Weather =
    'CLEAR'              -- CLEAR, EXTRASUNNY, CLOUDS, OVERCAST, RAIN, CLEARING , THUNDER, SMOG, FOGGY, XMAS , SNOWLIGHT, BLIZZARD
}

Config.Speech = {
    Status = false, -- or true
    Volume = 1,     -- A float that represents the volume value, between 0 (lowest) and 1 (highest.)
    Rate = 2,       -- This feature is used to adjust the loudness or tone of speech. | Default 1
    Pitch = 0,      -- This feature is used to adjust the speed of speech. | Default 1

    -- I suggest using commas
    -- Think of [name] as a variable and don't change its name, you can only change where it is, for example
    -- exp: 오늘 기분이 너무 안 좋아, [name] 넌 어때?
    Texts = {
        "Hello [name], how are you today?",
        "I love you [name], maybe you've never heard that before"
    }
}

-- [[ ! DON'T CHANGE ]]
Config.NewPlayerNoApartmentStartClothingUI = 'qb-clothes:client:CreateFirstCharacter' -- [[ ! DON'T CHANGE ]]
-- [[ ! DON'T CHANGE ]]
