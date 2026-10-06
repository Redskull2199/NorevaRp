local TOW_COMPLETE_STATUS = "Araçlar çekildi.\nYerel çekiciler şehirden ayrıldı."
local TOW_COMPLETE_COLOR = "#e5e5e5"

local countdownActive = false
local menuVisible = false
local countdownTimer = 0
local isExecutor = false
local Framework = "standalone"

CreateThread(function()
    Wait(500)
    if GetResourceState('qbx_core') == 'started' then
        Framework = "qbox"
    elseif GetResourceState('qb-core') == 'started' then
        Framework = "qb-core"
    end
end)

function SendNotification(text, type)
    if GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({
            title = Config.MenuTitle,
            description = text,
            type = type
        })
    elseif Framework == "qbox" then
        exports.qbx_core:Notify(text, type, 5000)
    elseif Framework == "qb-core" then
        exports['qb-core']:GetCoreObject().Functions.Notify(text, type, 5000)
    else
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName("~r~["..Config.MenuTitle.."]~w~ " .. text)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

RegisterNUICallback('closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

function OpenTowMenu()
    if menuVisible then return end
    menuVisible = true
    countdownTimer = Config.CountdownTime

    SendNUIMessage({
        action = "openMenu",
        title = Config.MenuTitle,
        time = countdownTimer
    })
end

function CloseTowMenu()
    if not menuVisible then return end
    menuVisible = false
    SendNUIMessage({ action = "closeMenu" })
end

function StartCountdown()
    if countdownActive then return end
    countdownActive = true
    OpenTowMenu()

    CreateThread(function()
        while countdownTimer > 0 and countdownActive do
            Wait(1000)
            countdownTimer = countdownTimer - 1
            if menuVisible then
                SendNUIMessage({ action = "updateCountdown", time = countdownTimer })
            end
        end

        if countdownActive then
            if isExecutor then
                TowDriverlessVehicles()
            else
                if menuVisible then
                    SendNUIMessage({
                        action = "updateStatus",
                        status = TOW_COMPLETE_STATUS,
                        statusColor = TOW_COMPLETE_COLOR
                    })
                end
                Wait(3500)
                CloseTowMenu()
            end
        end
        countdownActive = false
    end)
end

function TowDriverlessVehicles()
    local playerPed = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local towedCount = 0

    if menuVisible then
        SendNUIMessage({
            action = "updateStatus",
            status = "ARAÇLAR ÇEKİLİYOR...",
            statusColor = "#a3a3a3"
        })
    end

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if DoesEntityExist(vehicle) then
            if not (GetVehiclePedIsIn(playerPed, false) == vehicle) then
                local hasPlayer = false

                local maxSeats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
                for seat = -1, maxSeats - 2 do
                    local ped = GetPedInVehicleSeat(vehicle, seat)
                    if ped ~= 0 and IsPedAPlayer(ped) then
                        hasPlayer = true
                        break
                    end
                end

                if not hasPlayer then
                    local driver = GetPedInVehicleSeat(vehicle, -1)
                    if driver ~= 0 and not IsPedAPlayer(driver) then
                        DeleteEntity(driver)
                    end

                    DeleteVehicleSafe(vehicle)
                    towedCount = towedCount + 1
                end
            end
        end
    end

    TriggerServerEvent('yerel-cekici:verifyAndLog', towedCount)

    if menuVisible then
        SendNUIMessage({
            action = "updateStatus",
            status = TOW_COMPLETE_STATUS,
            statusColor = TOW_COMPLETE_COLOR
        })
    end

    Wait(3500)
    CloseTowMenu()
    countdownActive = false
end

function DeleteVehicleSafe(vehicle)
    if not DoesEntityExist(vehicle) then return end

    if NetworkGetEntityIsNetworked(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local timeout = 0
        while not NetworkHasControlOfEntity(vehicle) and timeout < 20 do
            Wait(0)
            timeout = timeout + 1
        end
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    if DoesEntityExist(vehicle) then
        SetEntityAsNoLongerNeeded(vehicle)
        DeleteEntity(vehicle)
    end
end

RegisterCommand("dvall", function()
    TriggerServerEvent('yerel-cekici:requestTow')
end, false)

RegisterNetEvent('yerel-cekici:startTow', function(executorServerId, isAuto)
    isExecutor = (GetPlayerServerId(PlayerId()) == executorServerId)
    
    if not countdownActive then
        StartCountdown()
    end
end)

RegisterNetEvent('yerel-cekici:noPermission', function()
    SendNotification("Bu komutu kullanmak için yetkiniz yok!", "error")
end)