-- Bridge Vehicle Utilities (Client-Side)
-- Provides framework-agnostic vehicle functions

Bridge = Bridge or {}
Bridge.Vehicle = Bridge.Vehicle or {}

-- Spawn a vehicle (ESX.Game.SpawnVehicle / QBCore.Functions.SpawnVehicle equivalent)
function Bridge.Vehicle.Spawn(model, coords, heading, callback)
    local modelHash = type(model) == 'number' and model or GetHashKey(model)

    -- Request model
    if not IsModelInCdimage(modelHash) then
        if callback then callback(nil) end
        return
    end

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    if not HasModelLoaded(modelHash) then
        if callback then callback(nil) end
        return
    end

    -- Create vehicle
    local x, y, z = coords.x, coords.y, coords.z
    local vehicle = CreateVehicle(modelHash, x, y, z, heading or 0.0, true, false)

    -- Wait for vehicle to exist
    timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    -- Set as mission entity
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetModelAsNoLongerNeeded(modelHash)

    if callback then
        callback(vehicle)
    end

    return vehicle
end

-- Set vehicle properties (ESX.Game.SetVehicleProperties / QBCore.Functions.SetVehicleProperties equivalent)
function Bridge.Vehicle.SetProperties(vehicle, props)
    if not DoesEntityExist(vehicle) then return end
    if not props then return end

    -- Use framework's SetVehicleProperties if available (more reliable)
    if Bridge.Framework == 'esx' and Bridge.FrameworkObject and Bridge.FrameworkObject.Game then
        if Bridge.FrameworkObject.Game.SetVehicleProperties then
            Bridge.FrameworkObject.Game.SetVehicleProperties(vehicle, props)
            return
        end
    elseif (Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox') and Bridge.FrameworkObject then
        if Bridge.FrameworkObject.Functions and Bridge.FrameworkObject.Functions.SetVehicleProperties then
            Bridge.FrameworkObject.Functions.SetVehicleProperties(vehicle, props)
            return
        end
    end

    -- Fallback: Native implementation
    if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
    if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
    if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end

    if props.color1 then
        local color1, color2 = GetVehicleColours(vehicle)
        SetVehicleColours(vehicle, props.color1, props.color2 or color2)
    end

    if props.pearlescentColor then
        local _, wheelColor = GetVehicleExtraColours(vehicle)
        SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor or wheelColor)
    end

    if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
    if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

    if props.neonEnabled then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1] or false)
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2] or false)
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3] or false)
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4] or false)
    end

    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1] or 0, props.neonColor[2] or 0, props.neonColor[3] or 0)
    end

    if props.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1] or 0, props.tyreSmokeColor[2] or 0, props.tyreSmokeColor[3] or 0)
    end

    if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
    if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
    if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
    if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
    if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
    if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
    if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
    if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
    if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
    if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
    if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
    if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
    if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
    if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
    if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
    if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
    if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
    if props.modTurbo then ToggleVehicleMod(vehicle, 18, props.modTurbo) end
    if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled) end
    if props.modXenon then ToggleVehicleMod(vehicle, 22, props.modXenon) end
    if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
    if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
    if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
    if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
    if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
    if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
    if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
    if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
    if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
    if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
    if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
    if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
    if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
    if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
    if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
    if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
    if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
    if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
    if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
    if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
    if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
    if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
    if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
    if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end
    if props.modLivery then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.extras then
        for id, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(id), not enabled)
        end
    end
end

-- Get vehicle properties (ESX.Game.GetVehicleProperties equivalent)
function Bridge.Vehicle.GetProperties(vehicle)
    if not DoesEntityExist(vehicle) then return nil end

    -- Use framework's GetVehicleProperties if available (more reliable)
    if Bridge.Framework == 'esx' and Bridge.FrameworkObject and Bridge.FrameworkObject.Game then
        if Bridge.FrameworkObject.Game.GetVehicleProperties then
            return Bridge.FrameworkObject.Game.GetVehicleProperties(vehicle)
        end
    elseif (Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox') and Bridge.FrameworkObject then
        if Bridge.FrameworkObject.Functions and Bridge.FrameworkObject.Functions.GetVehicleProperties then
            return Bridge.FrameworkObject.Functions.GetVehicleProperties(vehicle)
        end
    end

    -- Fallback: Native implementation
    local color1, color2 = GetVehicleColours(vehicle)
    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local extras = {}

    for i = 0, 12 do
        if DoesExtraExist(vehicle, i) then
            extras[tostring(i)] = IsVehicleExtraTurnedOn(vehicle, i)
        end
    end

    return {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = GetVehicleBodyHealth(vehicle),
        engineHealth = GetVehicleEngineHealth(vehicle),
        tankHealth = GetVehiclePetrolTankHealth(vehicle),
        fuelLevel = GetVehicleFuelLevel(vehicle),
        dirtLevel = GetVehicleDirtLevel(vehicle),
        color1 = color1,
        color2 = color2,
        pearlescentColor = pearlescentColor,
        wheelColor = wheelColor,
        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        neonEnabled = {
            IsVehicleNeonLightEnabled(vehicle, 0),
            IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2),
            IsVehicleNeonLightEnabled(vehicle, 3)
        },
        neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),
        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),
        modFrontWheels = GetVehicleMod(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modLivery = GetVehicleLivery(vehicle),
        extras = extras
    }
end
