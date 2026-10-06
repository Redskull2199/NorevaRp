RegisterKeyMapping('openCarplay', _U('opencarplay'), 'keyboard', Config.OpenKey)

local isInFocus = false
local isBlocked = false

function blockCarPlay()
    if isBlocked then
        return true
    end

    return false -- return true if you want to block that anyone can open the carplay
end

Bridge.Events.OnNet('PlayerLoaded', function(xPlayer)
    Wait(5000)

    if Config.NeedInstall then
        TriggerServerEvent('roadcarplay:playerLoad', GetPlayerServerId(PlayerId()))
    end
end)

function sendNotification(text)
    Bridge.Notification.Show(text) -- You can edit this event to any Notification System you want
end

CreateThread(function()
    while true do
        if getCarPlayActive() then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 304, true)
            DisableControlAction(0, 101, true)
            DisableControlAction(0, 74, true)
            DisableControlAction(0, 303, true)
            DisableControlAction(0, 311, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 29, true)
            DisableControlAction(0, 322, true)
            DisableControlAction(0, 200, true)
            DisableControlAction(0, 202, true)
            DisableControlAction(0, 177, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 245, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 45, true)
            DisableControlAction(0, 80, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 0, true)
            DisableControlAction(0, 69, true)
            DisableControlAction(0, 70, true)
            DisableControlAction(0, 36, true)
            DisableControlAction(0, 326, true)
            DisableControlAction(0, 341, true)
            DisableControlAction(0, 343, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 288, true)
            DisableControlAction(0, 289, true)
            DisableControlAction(0, 170, true)
            DisableControlAction(0, 167, true)
            DisableControlAction(0, 26, true)
            DisableControlAction(0, 73, true)
            DisableControlAction(0, 199, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 121, true)
            DisableControlAction(0, 114, true)
            DisableControlAction(0, 81, true)
            DisableControlAction(0, 82, true)
            DisableControlAction(0, 99, true)
            DisableControlAction(0, 330, true)
            DisableControlAction(0, 331, true)
            DisableControlAction(0, 100, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 106, true)
            DisableControlAction(0, 115, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 91, true)
            DisableControlAction(0, 92, true)
            DisableControlAction(0, 245, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 157, true)
            DisableControlAction(0, 158, true)
            DisableControlAction(0, 160, true)
            DisableControlAction(0, 164, true)
            DisableControlAction(0, 165, true)
            DisableControlAction(0, 159, true)
            DisableControlAction(0, 161, true)
            DisableControlAction(0, 162, true)
            DisableControlAction(0, 163, true)
            DisableControlAction(0, 182, true)
        end
        Wait(0)
    end
end)


function lockDoors()
    local playerPed = PlayerPedId()
    if IsPedSittingInAnyVehicle(playerPed) then --Maybe add a check if the player is the owner of the vehicle
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        SetVehicleDoorsLocked(vehicle, 2) --Default native to lock the doors, you can edit this if your vehicle key script use another native
    end
end

RegisterNUICallback('inputfocus', function(data, cb) -- Do not change anything here!
    isInFocus = data.focus

    if isInFocus then
        SetNuiFocusKeepInput(false)
    else
        SetNuiFocusKeepInput(true)
    end

    cb('ok')
end)

local IsDead = false

Bridge.Events.On('PlayerDeath', function(data)
    IsDead = true

    SendNUIMessage({
        event = "closeCarPlay"
    })
end)

Bridge.Events.On('PlayerSpawn', function(spawn)
    IsDead = false
end)

function checkPlayerDead()
    if Config.VisnAre then
        local dead = exports['visn_are']:GetHealthBuffer().unconscious

        return dead
    end

    if Config.BrutalAmbulanceJob then
        local dead = exports.brutal_ambulancejob:IsDead()

        return dead
    end


    return IsDead
end

function getVehicleFuel()
    local playerPed = PlayerPedId()
    if IsPedSittingInAnyVehicle(playerPed) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)

        if not vehicle then
            return 0
        end
        local fuel = GetVehicleFuelLevel(vehicle)

        return fuel
    end

    return 0
end

exports('isBlocked', function()
    return blockCarPlay()
end)


exports('blockCarPlay', function()
    isBlocked = true
    return true
end)

exports('unblockCarPlay', function()
    isBlocked = false
    return false
end)

if Config.NeedInstall then
    CreateThread(function()
        while true do
            Wait(500)
            if NetworkIsPlayerActive(PlayerId()) then
                TriggerServerEvent('roadcarplay:playerLoad', GetPlayerServerId(PlayerId()))
                break
            end
        end
    end)
end

if Config.LBPhone then
    function temperatureRanges(weatherType)
        local temperatureRanges = {
            ExtraSunny = { 90, 110 },
            Clear = { 80, 95 },
            Neutral = { 80, 95 },
            Smog = { 90, 95 },
            Foggy = { 80, 90 },
            Clouds = { 80, 90 },
            Overcast = { 80, 80 },
            Clearing = { 75, 85 },
            Raining = { 75, 90 },
            ThunderStorm = { 75, 90 },
            Blizzard = { -15, 10 },
            Snowing = { 0, 32 },
            Snowlight = { 0, 32 },
            Christmas = { -5, 15 },
            Halloween = { 50, 80 }
        }

        -- Fetch the range and get a random temperature within that range
        local minTemp, maxTemp = table.unpack(temperatureRanges[weatherType])
        local randomTemperature = getRandomInt(minTemp, maxTemp)

        -- Convert to Celsius if necessary
        if not Config.Fahrenheit then
            randomTemperature = (randomTemperature - 32) * 5 / 9
        end

        -- Format and return temperature with unit
        return string.format('%.0f°%s', randomTemperature, Config.Fahrenheit and 'F' or 'C')
    end

    CreateThread(function()
        while true do
            Wait(3000)

            TriggerEvent('roadcarplay:checkWeather')

            Wait(120000)
        end
    end)
end
