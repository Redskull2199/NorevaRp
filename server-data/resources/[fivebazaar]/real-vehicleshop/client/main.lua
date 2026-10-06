frameworkObject = nil

Citizen.CreateThread(function()
    frameworkObject, Config.Framework = GetCore()
    while not frameworkObject do
        Citizen.Wait(0)
    end
    Citizen.Wait(1500)
    SendNUIMessage({
        action = 'Setup',
        language = Locales[Config.Language],
        colorstable = Config.Colors,
        bossmenucategories = Config.BossmenuCategories,
        checkprofanities = Config.CheckProfanities,
        profanities = Config.Profanities,
        feedbackcharacters = Config.FeedbackCharacterCheck,
        complaintcharacters = Config.ComplaintCharacterCheck,
        testdriveprice = Config.TestDrivePrice,
        platechange = Config.PlateChange,
        platechangeprice = Config.PlateChangePrice,
    })
end)

function CloseUI(status)
    RenderScriptCams(false)
    DestroyCam(cam, true)
    SetEntityVisible(PlayerPedId(), true)
    SetNuiFocus(false, false)
    IsInteriorView = false
    camAngle = 0.0
    CurrentFov = 50.0
    InsideCameraX = -0.2
    InsideCameraZ = 0.5
    cam = nil
    SelectedVehicleProps = nil
    if CreatedSelectedVehicle then
        DeleteVehicle(CreatedSelectedVehicle)
    end
    if status then
        SetEntityCoords(PlayerPedId(), Config.Vehicleshops[CurrentVehicleshop].ShopOpenCoords, true)
    end
    CurrentVehicleshop = nil
end

function CloseBossmenu()
    TriggerServerEvent('real-vehicleshop:RemoveFromSrcTable', CurrentVehicleshop)
    CurrentVehicleshop = nil
    SetNuiFocus(false, false)
end

function CheckPlayerJob(k)
    while not frameworkObject do
        Citizen.Wait(0)
    end
    for k, v in pairs(Config.Vehicleshops[k].Jobs) do
        if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if frameworkObject.Functions.GetPlayerData().job and frameworkObject.Functions.GetPlayerData().job.name == v or v == 'all' then
                return true
            else
                print("PlayerData problem when checking player job.")
            end
        else
            if frameworkObject.PlayerData.job and frameworkObject.PlayerData.job.name == v or v == 'all' then
                return true
            else
                print("PlayerData problem when checking player job.")
            end
        end
    end
    return false
end

function SetNuiFocusUI(boolean)
    SetNuiFocus(boolean, boolean)
end

function SendNormalNotify(data)
    Config.Notification(data.text, data.type, false)
end

RegisterNetEvent('real-vehicleshop:SendUINotify', function(type, text, ms)
    SendNUIMessage({
        action = 'ShowNotify',
        type = type,
        text = text,
        ms = ms
    })
end)

RegisterNUICallback('CloseUI', CloseUI)
RegisterNUICallback('CloseBossmenu', CloseBossmenu)
RegisterNUICallback('SetNuiFocus', SetNuiFocusUI)
RegisterNUICallback('SendNormalNotify', SendNormalNotify)