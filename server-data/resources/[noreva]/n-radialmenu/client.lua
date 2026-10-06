local isMenuOpen = false

local openKey = Config.OpenKey:lower()
local cmdName = '+radialmenu_' .. openKey

RegisterCommand(cmdName, function()
    ToggleMenu()
end, false)

RegisterCommand('-radialmenu_' .. openKey, function()
end, false)

RegisterKeyMapping(cmdName, 'Radial Menü Aç', 'keyboard', Config.OpenKey)

function ToggleMenu()
    isMenuOpen = not isMenuOpen

    if isMenuOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'toggle',
            data = {
                show = true,
                items = Config.MenuItems
            }
        })
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'toggle',
            data = {
                show = false,
                items = {}
            }
        })
    end
end

RegisterNUICallback('closeMenu', function(data, cb)
    cb('ok')
    isMenuOpen = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('selectItem', function(data, cb)
    cb('ok')

    if data.shouldClose then
        isMenuOpen = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SendNUIMessage({
            action = 'toggle',
            data = {
                show = false,
                items = {}
            }
        })
    end

    Citizen.Wait(50)
    if data.event then
        if data.type == 'client' then
            TriggerEvent(data.event, data)
        elseif data.type == 'server' then
            TriggerServerEvent(data.event, data)
        end
    end
end)

RegisterNUICallback('playSound', function(data, cb)
    cb('ok')
    if data.name == 'hover' then
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif data.name == 'click' then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
end)

RegisterNetEvent('vehicle:toggleEngine', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        local engineOn = GetIsVehicleEngineRunning(vehicle)
        SetVehicleEngineOn(vehicle, not engineOn, false, true)
    end
end)

RegisterNetEvent('vehicle:toggleDoors', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        for i = 0, 5 do
            if GetVehicleDoorAngleRatio(vehicle, i) > 0.0 then
                SetVehicleDoorShut(vehicle, i, false)
            else
                SetVehicleDoorOpen(vehicle, i, false, false)
            end
        end
    end
end)

RegisterNetEvent('vehicle:toggleTrunk', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        if GetVehicleDoorAngleRatio(vehicle, 5) > 0.0 then
            SetVehicleDoorShut(vehicle, 5, false)
        else
            SetVehicleDoorOpen(vehicle, 5, false, false)
        end
    end
end)

local clothingData = {
    top = {component = 11, texture = 0},
    pants = {component = 4, texture = 0},
    shoes = {component = 6, texture = 0},
    hat = {component = 0, prop = true},
    glasses = {component = 1, prop = true},
    mask = {component = 1, texture = 0}
}

RegisterNetEvent('clothing:toggleTop', function()
    local ped = PlayerPedId()
    local current = GetPedDrawableVariation(ped, 11)
    if current == 15 or current == 0 then
        SetPedComponentVariation(ped, 11, 0, 0, 0)
    else
        SetPedComponentVariation(ped, 11, 15, 0, 0)
    end
end)

RegisterNetEvent('clothing:togglePants', function()
    local ped = PlayerPedId()
    local current = GetPedDrawableVariation(ped, 4)
    if current == 21 or current == 0 then
        SetPedComponentVariation(ped, 4, 0, 0, 0)
    else
        SetPedComponentVariation(ped, 4, 21, 0, 0)
    end
end)

RegisterNetEvent('clothing:toggleShoes', function()
    local ped = PlayerPedId()
    local current = GetPedDrawableVariation(ped, 6)
    if current == 34 or current == 0 then
        SetPedComponentVariation(ped, 6, 0, 0, 0)
    else
        SetPedComponentVariation(ped, 6, 34, 0, 0)
    end
end)

RegisterNetEvent('clothing:toggleHat', function()
    local ped = PlayerPedId()
    local current = GetPedPropIndex(ped, 0)
    if current == -1 then
        SetPedPropIndex(ped, 0, 0, 0, true)
    else
        ClearPedProp(ped, 0)
    end
end)

RegisterNetEvent('clothing:toggleGlasses', function()
    local ped = PlayerPedId()
    local current = GetPedPropIndex(ped, 1)
    if current == -1 then
        SetPedPropIndex(ped, 1, 0, 0, true)
    else
        ClearPedProp(ped, 1)
    end
end)

RegisterNetEvent('clothing:toggleMask', function()
    local ped = PlayerPedId()
    local current = GetPedDrawableVariation(ped, 1)
    if current == 0 then
        SetPedComponentVariation(ped, 1, 0, 0, 0)
    else
        SetPedComponentVariation(ped, 1, 0, 0, 0)
    end
end)
