frameworkObject = nil
CurrentVehicleshop = nil
cam = nil
SelectedVehicleProps = nil
camAngle = 0.0
CurrentFov = 50.0
InsideCameraX = -0.2
InsideCameraZ = 0.5
IsInteriorView = false
TestDriveActive = false

Citizen.CreateThread(function()
    frameworkObject, Config.Framework = GetCore()
    while not frameworkObject do
        Citizen.Wait(0)
    end
end)

function OpenVehicleshop(k)
    local data = Callback('real-vehicleshop:GetVehicleshopData', k)
    local OwnerStatus = nil
    if Config.Vehicleshops[k].Owner == "" then
        OwnerStatus = false
    else
        OwnerStatus = true
    end

    if data then
        DisplayRadar(false)
        DisplayHud(false)
        SetEntityCoords(PlayerPedId(), Config.Vehicleshops[k].CamSettings.PlayerPos)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Vehicleshops[k].CamSettings.Coords.x, Config.Vehicleshops[k].CamSettings.Coords.y,Config.Vehicleshops[k].CamSettings.Coords.z, 0.00, 0.00, 120.00, 50.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
        SetEntityVisible(PlayerPedId(), false)
        SendNUIMessage({
            action = 'OpenVehicleshop',
            allvehiclestable = Config.VehiclesData[Config.Vehicleshops[k].Type],
            hasowner = OwnerStatus,
            playername = data.Name,
            playermoney = data.Money,
            playerpfp = data.Pfp,
            vehicleshop = k,
            vehicleshopname = Config.Vehicleshops[k].CompanyName,
            vehicleshopdescription = Config.Vehicleshops[k].CompanyDescriptionText,
            vehicleshoprating = Config.Vehicleshops[k].Rating,
            vehicles = OwnerStatus and Config.Vehicleshops[k].Vehicles or Config.VehiclesData[Config.Vehicleshops[k].Type],
            categories = OwnerStatus and Config.Vehicleshops[k].Categories or Config.Categories[Config.Vehicleshops[k].Type],
            feedbacks = Config.Vehicleshops[k].Feedbacks,
            discount = Config.Vehicleshops[k].Discount,
            raise = Config.Vehicleshops[k].Raise,
        })
        SetNuiFocus(true, true)
        CurrentVehicleshop = k
    end
end

local function f(n)
	return (n + 0.00001)
end

function MoveCam(pos,x,y,z)
	SetCamActive(cam, true)
	local veh = GetVehiclePedIsIn(PlayerPedId(), false)
	local vx,vy,vz = table.unpack(GetEntityCoords(veh))
	local d = GetModelDimensions(GetEntityModel(veh))
	local length,width,height = d.y*-2, d.x*-2, d.z*-2
	local ox,oy,oz
	if pos == 'front' then
		ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), (length/2)+ f(y), f(z)))
	elseif pos == "front-top" then
		ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), (length/2) + f(y),(height) + f(z)))
	elseif pos == "back" then
		ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), -(length/2) + f(y),f(z)))
	elseif pos == "back-top" then
		ox,oy,oz= table.unpack(GetOffsetFromEntityInWorldCoords(veh, f(x), -(length/2) + f(y),(height/2) + f(z)))
	end
	SetCamCoord(cam, ox, oy, oz)
	PointCamAtCoord(cam,GetOffsetFromEntityInWorldCoords(veh, 0, 0, f(0)))
	RenderScriptCams( 1, 0, 1000, 0, 0)
end

function CamControl(c)
	if c == "back" then
		MoveCam('back', 0, -2, 1)
    elseif c == "reset" then
        ResetCam()
        MoveCamAroundVehicle()
    end
end

function ResetCam()
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Vehicleshops[CurrentVehicleshop].CamSettings.Coords.x, Config.Vehicleshops[CurrentVehicleshop].CamSettings.Coords.y, Config.Vehicleshops[CurrentVehicleshop].CamSettings.Coords.z, 0.00, 0.00, 90.00, 50.00, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1000, true, true)
    MoveCamAroundVehicle()
end

function CreateSelectedVehicle(vehiclehash)
    local Player = PlayerPedId()
    RequestModel(GetHashKey(vehiclehash))
    while not HasModelLoaded(vehiclehash) do
        Wait(0)
    end
    if CreatedSelectedVehicle then
        DeleteVehicle(CreatedSelectedVehicle)
    end
    CreatedSelectedVehicle = CreateVehicle(vehiclehash, Config.Vehicleshops[CurrentVehicleshop].CamSettings.VehiclePos, false, true)
    TaskWarpPedIntoVehicle(Player, CreatedSelectedVehicle, -1)
    local Heading = GetEntityHeading(CreatedSelectedVehicle)
    SetPedIntoVehicle(Player, CreatedSelectedVehicle, -1)
    CamControl('reset')
    SetEntityHeading(Player, Heading)
    local plate = GeneratePlate()
    SetVehicleNumberPlateText(CreatedSelectedVehicle, plate)
    SetVehicleRadioEnabled(CreatedSelectedVehicle, false)
    SetVehicleFixed(CreatedSelectedVehicle)
    SetVehicleDirtLevel(CreatedSelectedVehicle, 0.1)
    FreezeEntityPosition(CreatedSelectedVehicle, true)
    SelectedVehicleProps = GetVehicleProperties(CreatedSelectedVehicle)
    SendNUIMessage({
        action = 'UpdateCreateSelectedVehicle',
        speed = math.floor(GetVehicleHandlingFloat(CreatedSelectedVehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')),
        brake = math.floor(GetVehicleHandlingFloat(CreatedSelectedVehicle, "CHandlingData", "fBrakeForce") * GetVehicleHandlingFloat(CreatedSelectedVehicle, "CHandlingData", "fBrakeBiasFront") * 100 + 0.5),
        acceleration = math.floor(GetVehicleHandlingFloat(CreatedSelectedVehicle, "CHandlingData", "fInitialDriveMaxFlatVel") * GetVehicleHandlingFloat(CreatedSelectedVehicle, "CHandlingData", "fInitialDriveForce") + 0.5),
        suspension = math.floor(GetVehicleHandlingFloat(CreatedSelectedVehicle, 'CHandlingData', 'fSuspensionForce') + 0.5),
        handling = math.floor((GetVehicleHandlingFloat(CreatedSelectedVehicle, "CHandlingData", "fSteeringLock") + GetVehicleHandlingFloat(CreatedSelectedVehicle, "CHandlingData", "fTractionBiasFront") - GetVehicleHandlingFloat(CreatedSelectedVehicle, "CHandlingData", "fTractionLossMult")) * 2 + 0.5),
        plate = plate,
        color = GetVehicleColours(CreatedSelectedVehicle)
    })
end

function ChangeVehicleColor(color)
    color = tonumber(color)
    SetVehicleColours(CreatedSelectedVehicle, color, color)
    SetVehicleExtraColours(CreatedSelectedVehicle, 0, 0)
    SendNUIMessage({
        action = 'ChangeCurrentVehicleColorStatus',
        color = GetVehicleColours(CreatedSelectedVehicle)
    })
end

function ShowPlateCamera()
    CamControl('back')
end

function ChangePlate(plate)
    local result = Callback('real-vehicleshop:CheckPlateStatus', plate)
    if not result then
        SetVehicleNumberPlateText(CreatedSelectedVehicle, plate)
        SelectedVehicleProps = GetVehicleProperties(CreatedSelectedVehicle)
    end
end

function CheckNewPlateStatus(plate)
    local result = Callback('real-vehicleshop:CheckPlateStatus', plate)
    if not result then
        SendNUIMessage({ action = 'ChangePlateAccepted' })
    else
        TriggerEvent('real-vehicleshop:SendUINotify', 'error', Language('plate_already_exist'), 2000)
    end
end

function ZoomIn()
    CurrentFov = CurrentFov - 5.0
    if CurrentFov < 10.0 then
        CurrentFov = 10.0
    end
    SetCamFov(cam, CurrentFov)
end

function ZoomOut()
    CurrentFov = CurrentFov + 5.0
    if CurrentFov > 100.0 then
        CurrentFov = 100.0
    end
    SetCamFov(cam, CurrentFov)
end

function MoveCamAroundVehicle()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehCoords = GetEntityCoords(veh)
    local radius
    if Config.Vehicleshops[CurrentVehicleshop].Type == 'car' then
        radius = 7.0
    elseif Config.Vehicleshops[CurrentVehicleshop].Type == 'boat' then
        radius = 11.0
    elseif Config.Vehicleshops[CurrentVehicleshop].Type == 'aircraft' then
        radius = 16.0
    end

    local camX = vehCoords.x + radius * math.cos(camAngle)
    local camY = vehCoords.y + radius * math.sin(camAngle)
    local camZ  -- Camera height
    if Config.Vehicleshops[CurrentVehicleshop].Type == 'car' then
        camZ = vehCoords.z + 0.5
    elseif Config.Vehicleshops[CurrentVehicleshop].Type == 'boat' then
        camZ = vehCoords.z + 1.5
    elseif Config.Vehicleshops[CurrentVehicleshop].Type == 'aircraft' then
        camZ = vehCoords.z + 2.0
    end

    SetCamCoord(cam, camX, camY, camZ)
    PointCamAtCoord(cam, vehCoords.x, vehCoords.y, vehCoords.z)
end

function MoveCamInsideVehicle()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local vehCoords = GetEntityCoords(veh)
    local camX, camY, camZ = table.unpack(GetOffsetFromEntityInWorldCoords(veh, -0.4, -0.4, 0.6))

    SetCamCoord(cam, camX, camY, camZ)
    SetCamRot(cam, 0.0, 0.0, camAngle, 2)
    PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(veh, -0.2, 1.0, 0.5))
end

function RotateCameraLeft()
    if IsInteriorView then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        InsideCameraX = InsideCameraX - 0.05
        PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(veh, InsideCameraX, 1.0, InsideCameraZ))
    else
        camAngle = camAngle - math.rad(2.0)
        MoveCamAroundVehicle()
    end
end

function RotateCameraRight()
    if IsInteriorView then
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        InsideCameraX = InsideCameraX + 0.05
        PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(veh, InsideCameraX, 1.0, InsideCameraZ))
    else
        camAngle = camAngle + math.rad(2.0)
        MoveCamAroundVehicle()
    end
end

function RotateCameraUp()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    InsideCameraZ = InsideCameraZ + 0.05
    PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(veh, InsideCameraX, 1.0, InsideCameraZ))
end

function RotateCameraDown()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    InsideCameraZ = InsideCameraZ - 0.05
    PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(veh, InsideCameraX, 1.0, InsideCameraZ))
end

function MoveCamToInterior()
    IsInteriorView = true
    camAngle = GetEntityHeading(PlayerPedId())
    MoveCamInsideVehicle()
end

function MoveCamToExterior()
    IsInteriorView = false
    camAngle = 0.0
    CurrentFov = 50.0
    MoveCamAroundVehicle()
end

function ResetCameraAngle()
    IsInteriorView = false
    camAngle = 0.0
    CurrentFov = 50.0
    InsideCameraX = -0.2
    InsideCameraZ = 0.5
end

function ResetCameraToNormal()
    CamControl('reset')
end

function GenerateNewPlate()
    local plate = GeneratePlate()
    SetVehicleNumberPlateText(CreatedSelectedVehicle, plate)
    SendNUIMessage({
        action = 'UpdatePlateInput',
        value = plate
    })
    SelectedVehicleProps = GetVehicleProperties(CreatedSelectedVehicle)
end

function StartTestDrive(data)
    local CheckPlayerMoney = Callback('real-vehicleshop:RemoveMoneyForTestDrive')
    if CheckPlayerMoney then
        if CreatedSelectedVehicle then
            DeleteVehicle(CreatedSelectedVehicle)
        end
        TestDriveActive = true
        local veh = CreateVehicle(data.vehicle, Config.Vehicleshops[data.vehicleshop].TestDriveLocation, true, false)
        while not DoesEntityExist(veh) do
            Wait(10)
        end
        SetVehicleOnGroundProperly(veh)
        SetVehicleNumberPlateText(veh, Config.TestDrivePlate)
        SetVehicleEngineOn(veh, true, true, false)
        SetVehicleEngineCanDegrade(veh, false)
        SetVehicleDirtLevel(veh, 0.1)
        SetVehicleUndriveable(veh, false)
        SetVehicleDoorsLocked(veh, 1)
        SetVehicleColours(veh, tonumber(data.color), tonumber(data.color))
        SetVehicleExtraColours(veh, 0, 0)
        SetPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityVisible(PlayerPedId(), true, 0)
        Config.GiveVehicleKeys(GetVehicleNumberPlateText(veh), data.vehicle, veh)
        TriggerServerEvent('real-vehicleshop:TestDrive', true, NetworkGetNetworkIdFromEntity(veh))
        local RealTime = GetGameTimer()
        Citizen.CreateThread(function()
            while TestDriveActive do
                if DoesEntityExist(veh) then
                    DisableControlAction(0, 75, true)
                    local RightNow = GetGameTimer()
                    local TimeLeft = Config.TestDriveTime - ((RightNow - RealTime) / 1000)
                    ShowHelpNotification(Language('cancel_testdrive'))
                    if TimeLeft > 0 then
                        if TimeLeft <= Config.TestDriveTime then
                            SendNUIMessage({
                                action = 'ShowTestDriveTime',
                                time = math.ceil(TimeLeft)
                            })
                        end
                    else
                        DeleteEntity(veh)
                        DeleteVehicle(veh)
                        SetEntityCoords(PlayerPedId(), Config.Vehicleshops[data.vehicleshop].ShopOpenCoords)
                        TriggerServerEvent('real-vehicleshop:TestDrive', false)
                        TestDriveActive = false
                        SendNUIMessage({ action = 'CloseTimer' })
                    end
                    if IsControlJustReleased(0, 11) then
                        DeleteEntity(veh)
                        DeleteVehicle(veh)
                        SetEntityCoords(PlayerPedId(), Config.Vehicleshops[data.vehicleshop].ShopOpenCoords)
                        TriggerServerEvent('real-vehicleshop:TestDrive', false)
                        TestDriveActive = false
                        SendNUIMessage({ action = 'CloseTimer' })
                    end
                else
                    SetEntityCoords(PlayerPedId(), Config.Vehicleshops[data.vehicleshop].ShopOpenCoords)
                    TriggerServerEvent('real-vehicleshop:TestDrive', false)
                    TestDriveActive = false
                    SendNUIMessage({ action = 'CloseTimer' })
                end
                Wait(0)
            end
        end)
    end
end

function BuyPlayerVehicle(data)
    local Player = PlayerPedId()
    local vehicleshop = data.vehicleshop
    local model = data.model
    local price = data.price
    local stock = data.stock
    local plate = data.plate
    local color = data.color
    local props = SelectedVehicleProps
    local SendData = {
        id = vehicleshop,
        model = model,
        price = price,
        stock = stock,
        plate = plate,
        color = color,
        props = props
    }
    local datas = Callback('real-vehicleshop:BuyPlayerVehicle', SendData)
    if datas then
        SendNUIMessage({ action = 'CloseUI', status = false })
        Citizen.Wait(100)
        SetEntityCoords(Player, Config.Vehicleshops[vehicleshop].SpawnCoords, true)
        local Vehicle = CreateVehicle(model, Config.Vehicleshops[vehicleshop].SpawnCoords, true, true)
        SetVehicleProperties(Vehicle, props)
        SetVehicleColours(Vehicle, color, color)
        SetVehicleExtraColours(Vehicle, 0, 0)
        SetPedIntoVehicle(Player, Vehicle, -1)
        Config.GiveVehicleKeys(data.plate, model, Vehicle)
    end
end

function PreOrderVehicle(data)
    TriggerServerEvent('real-vehicleshop:PreOrderVehicle', data, SelectedVehicleProps)
end

RegisterNUICallback('CreateSelectedVehicle', CreateSelectedVehicle)
RegisterNUICallback('ChangeVehicleColor', ChangeVehicleColor)
RegisterNUICallback('ShowPlateCamera', ShowPlateCamera)
RegisterNUICallback('ChangePlate', ChangePlate)
RegisterNUICallback('ZoomIn', ZoomIn)
RegisterNUICallback('ZoomOut', ZoomOut)
RegisterNUICallback('RotateCameraLeft', RotateCameraLeft)
RegisterNUICallback('RotateCameraRight', RotateCameraRight)
RegisterNUICallback('MoveCamToInterior', MoveCamToInterior)
RegisterNUICallback('MoveCamToExterior', MoveCamToExterior)
RegisterNUICallback('ResetCameraAngle', ResetCameraAngle)
RegisterNUICallback('RotateCameraUp', RotateCameraUp)
RegisterNUICallback('RotateCameraDown', RotateCameraDown)
RegisterNUICallback('ResetCameraToNormal', ResetCameraToNormal)
RegisterNUICallback('GenerateNewPlate', GenerateNewPlate)
RegisterNUICallback('CheckNewPlateStatus', CheckNewPlateStatus)
RegisterNUICallback('StartTestDrive', StartTestDrive)
RegisterNUICallback('BuyPlayerVehicle', BuyPlayerVehicle)
RegisterNUICallback('PreOrderVehicle', PreOrderVehicle)