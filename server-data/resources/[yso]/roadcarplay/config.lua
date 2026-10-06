-- Framework is auto-detected by Bridge (ESX, QBCore, Qbox, or Standalone)

Config = {}

-- ─── Phone integration ────────────────────────────────────────────────────────
-- RoadPhone has been removed. Set Config.LBPhone = true to use lb-phone.
Config.LBPhone  = false  -- Set to true if you use lb-phone for messages/contacts.
Config.RoadPad  = false -- If you use RoadPad, set the value to true.

Config.OpenKey = "none"

Config.Locale = 'en' --DEFAULT LUA CODE LANGUAGE

Config.Fahrenheit = false --Set to true if you want to use Fahrenheit instead of Celsius

Config.Items = {
    'carplay'
}

Config.RemoveItems = {
    'removecarplay'
}

Config.OnlyDriver = false --If you want that only the driver can use Carplay, set the value to true.
Config.DamageUse = true --If you want that Carplay is only usable when the car is not damaged, set the value to true.
Config.MinimumCarHealth = 80 --If you want that Carplay is only usable when the car health is higher than the value ( 80 = 80% ), set the value to the value you want. Works only with DamageUse = true


--Carplay install
Config.NeedInstall = false --If you want that people need to install Carplay before they can use it, set the value to true.
Config.RemoveCarPlayAfterInstall = false --If you want that Carplay is removed after the installation, set the value to true.
Config.NeedJob = false --Set true to if you want that only mechanics can install Carplay.
Config.Jobs = { --Only works with NeedJob true
    "mechanic"
}
Config.BuildInAnimation = true

Config.useProgressBar = false --if you want to use a progress bar, set the value to true.

Config.ProgressBar = function(time, txt)
    if Config.useProgressBar then
        exports['progressBars']:startUI(time, txt)  --change if you use different progress bar script
    end
end


--Music

Config.AudioLibrary = 'xsound' -- 'xsound' or 'mxsurround'
Config.AllOccupantsCanControl = true -- Allow all vehicle occupants to control music and use CarPlay
Config.DefaultMusicValue = 0.5
Config.DefaultMusicRange = 2.0
Config.DefaultMusicRangeBrokenWindow = 10


--AutoPilot

Config.AutoMaxSpeed = 30.0 --If you want to set the max speed of the autopilot, set the value to the value you want. ( 30.0 = 108 km/h )
Config.AutoFlagsUsed = 316 --447 is default the most careful driving flag u can use, try what fits you best ;)
Config.AutopilotNeedAccess = false --If you want that only specific cars can use the autopilot, set the value to true.
Config.AutopilotAccessCars = { --Only works with AutopilotNeedAccess true
    "adder",
    "zentorno"
}


Config.DisableSeatShuffle = true --If you want to disable the automatic seat shuffle, set the value to true.

Config.Cameraeffect = true --If you want that the camera effect is active, set the value to true.
Config.DisableRadioMusic = true --If you want to disable the the radio when starting music, set the value to true.

Config.VisnAre = false --Set to true if you use VisnAre script
Config.BrutalAmbulanceJob = false

Config.RearCamera = {
    active = true,            -- Set to false to disable the rear camera feature
    cameraFOV = 80.0,           -- Field of view for the camera
    cameraHeight = 0.2,         -- Height offset from vehicle
    cameraDistance = -4.5,      -- Distance behind vehicle
    cameraRotationX = -15.0,    -- Downward angle
    needCarplayInstalled = true, --If you want that the rear camera only works when carplay is installed, set the value to true.
    toggleKey = 21,             -- LEFT SHIFT by default (change as needed)
    holdToView = false,         -- Set to true if you want hold-to-view instead of toggle
    registerKeyMapping = true, --If you want a toggle, key can be personalised by every player ( works best with holdToView = false )
    showInFirstPerson = false, -- Show camera when in first person view
    autoWhenReversing = true, -- Automatically switch to rear camera when reversing
    renderDistance = 50.0,      -- Render distance for the camera
    shakeIntensity = 0.0,        -- Camera shake (0.0 = no shake),
    cameraEffect = true,
    vehicleTypes = {
        "automobile",
        "bike"
    }
}
