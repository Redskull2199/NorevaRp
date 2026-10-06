-- ============================================================
-- roadcarplay/client/rearcamera.lua  (v5 — accurate proximity)
-- ============================================================
-- ROOT CAUSE FIX (NUI visibility):
--   SetDisplay(false) calls SetNuiFocusKeepInput(false) which shuts
--   NUI rendering off. Fix: call SetNuiFocusKeepInput(true) on camera
--   start so the overlay stays visible while the game retains input.
--
-- PROXIMITY ACCURACY FIXES (v5):
--   1. Multi-lateral origins — rays cast from 5 positions ACROSS the
--      full bumper width (left-edge → right-edge). This is the primary
--      fix for trees and props at vehicle corners being completely missed
--      when only the centre was used.
--   2. Bumper-face compensation — ray origin sits BUMPER_INSET metres
--      inside the bumper to prevent self-hit. This offset is subtracted
--      from every result so distance always = bumper-face → obstacle.
--   3. Wider angle sweep (±90°, 17 rays) catches objects directly
--      beside the rear corners of the vehicle.
--   4. 6 Z-heights cover everything from low curbs (0.06 m) to roof
--      level (1.65 m) including mid-bumper, door, and window heights.
--   5. Upward-angled rays at the top two heights detect overhanging
--      ledges, low bridges, and tall sign gantries.
--   6. Adaptive poll rate: 16 ms when < 1.0 m, 33 ms when < 2.0 m,
--      66 ms when < 3.5 m, 100 ms otherwise.
-- ============================================================

if Config.RearCamera.registerKeyMapping then
    RegisterKeyMapping("rearcam", "Toggle Rear Camera", "keyboard", "LSHIFT")
end

-- ─── State ────────────────────────────────────────────────────
local isCameraActive = false
local cameraHandle   = nil
local wasFromCarPlay = false

-- ─── Helpers ─────────────────────────────────────────────────

local function GetVehicleModelDimensions_impl(vehicle)
    local modelHash = GetEntityModel(vehicle)
    local minDim, maxDim = GetModelDimensions(modelHash)
    return minDim, maxDim
end
GetVehicleModelDimensions = GetVehicleModelDimensions_impl

local function CalculateCameraPosition_impl(vehicle)
    local minDim, maxDim = GetVehicleModelDimensions(vehicle)
    local vehicleLength  = maxDim.y - minDim.y
    local vehicleHeight  = maxDim.z - minDim.z
    local rearOffset     = Config.RearCamera.cameraDistance - (vehicleLength * 0.15)
    local heightOffset   = Config.RearCamera.cameraHeight   + (vehicleHeight * 0.1)
    return rearOffset, heightOffset
end
CalculateCameraPosition = CalculateCameraPosition_impl

-- ─── Proximity raycasting ─────────────────────────────────────
--
-- IntersectOptions bitmask for StartShapeTestRay:
--   1   = map geometry  (buildings, walls, roads, curbs, bridges)
--   2   = mission entities
--   4   = peds
--   8   = vehicles
--   16  = props / world objects (trees, bollards, barriers, etc.)
--   256 = extra world-static geometry
-- 287 = 1+2+4+8+16+256 → hits everything in the game world
--
local RAY_FLAGS  = 287
local RAY_LEN    = 9.0   -- max scan range in metres

-- BUMPER_INSET: how far inside the bumper face the ray starts.
-- Prevents self-hit. Subtracted from raw hit distances so the final
-- value always represents bumper-face → obstacle in metres.
local BUMPER_INSET = 0.05

-- 17 angles covering a full 180° rear arc (±90°).
-- Dense in the critical centre zone, sparser toward the sides.
local SWEEP_ANGLES = { -90, -72, -56, -42, -30, -20, -10, -3, 0, 3, 10, 20, 30, 42, 56, 72, 90 }

-- 6 Z-heights in vehicle-local space (metres above vehicle origin):
--   0.06  = ground / curb / low bollard
--   0.28  = licence-plate / low bumper
--   0.55  = mid bumper / lower body
--   0.90  = door / main body
--   1.30  = window / upper body
--   1.65  = roof edge (catches low bridges, sign gantries)
local SWEEP_LOCAL_Z = { 0.06, 0.28, 0.55, 0.90, 1.30, 1.65 }

local function GetRearProximity(vehicle)
    local modelHash      = GetEntityModel(vehicle)
    local minDim, maxDim = GetModelDimensions(modelHash)
    local heading        = GetEntityHeading(vehicle)

    -- Rear-bumper local Y: minDim.y is negative (rear extent).
    -- Adding BUMPER_INSET moves the origin just inside so it won't
    -- immediately self-hit the vehicle's own collision mesh.
    local rearLocalY = minDim.y + BUMPER_INSET

    -- 5 lateral positions evenly distributed across the bumper width.
    -- minDim.x = left edge (negative value), maxDim.x = right edge.
    local lateralOffsets = {
        minDim.x * 0.92,    -- near left edge
        minDim.x * 0.48,    -- left of centre
        0.0,                 -- dead centre
        maxDim.x * 0.48,    -- right of centre
        maxDim.x * 0.92,    -- near right edge
    }

    local minDist = RAY_LEN

    for _, localX in ipairs(lateralOffsets) do
        for _, angleDeg in ipairs(SWEEP_ANGLES) do
            -- World-space backward direction for this sweep angle.
            local worldRad = math.rad(heading + angleDeg + 180.0)
            local dirX     = math.sin(worldRad)
            local dirY     = -math.cos(worldRad)

            for zIdx, localZ in ipairs(SWEEP_LOCAL_Z) do
                -- GetOffsetFromEntityInWorldCoords handles vehicle heading,
                -- pitch AND roll — correct for any vehicle orientation.
                local sp = GetOffsetFromEntityInWorldCoords(vehicle, localX, rearLocalY, localZ)

                -- ── Primary horizontal ray ──────────────────────────────
                local ex = sp.x + dirX * RAY_LEN
                local ey = sp.y + dirY * RAY_LEN
                local ez = sp.z

                local ray = StartShapeTestRay(sp.x, sp.y, sp.z, ex, ey, ez, RAY_FLAGS, vehicle, 0)
                local _, hit, hitCoords = GetShapeTestResult(ray)
                if hit == 1 then
                    local rawD = #(vector3(sp.x, sp.y, sp.z) - hitCoords)
                    local d    = math.max(0.0, rawD - BUMPER_INSET)
                    if d < minDist then minDist = d end
                end

                -- ── Downward-angled ray (lowest Z only) ─────────────────
                -- Catches curbs, speed bumps, and low bollards on sloped
                -- or uneven ground that a flat horizontal ray skims over.
                if zIdx == 1 then
                    local dRay = StartShapeTestRay(
                        sp.x, sp.y, sp.z,
                        ex, ey, sp.z - 0.55,
                        RAY_FLAGS, vehicle, 0
                    )
                    local _, dHit, dCoords = GetShapeTestResult(dRay)
                    if dHit == 1 then
                        local hd = math.sqrt((sp.x - dCoords.x)^2 + (sp.y - dCoords.y)^2)
                        local d  = math.max(0.0, hd - BUMPER_INSET)
                        if d < minDist then minDist = d end
                    end
                end

                -- ── Upward-angled ray (two highest Z heights only) ───────
                -- Catches overhanging ledges, low bridges, wall tops, and
                -- tall signs whose lower face the horizontal ray misses.
                if zIdx == 5 or zIdx == 6 then
                    local uRay = StartShapeTestRay(
                        sp.x, sp.y, sp.z,
                        ex, ey, sp.z + 0.45,
                        RAY_FLAGS, vehicle, 0
                    )
                    local _, uHit, uCoords = GetShapeTestResult(uRay)
                    if uHit == 1 then
                        local hd = math.sqrt((sp.x - uCoords.x)^2 + (sp.y - uCoords.y)^2)
                        local d  = math.max(0.0, hd - BUMPER_INSET)
                        if d < minDist then minDist = d end
                    end
                end
            end
        end
    end

    return math.max(0.0, minDist)
end

-- ─── NUI overlay ─────────────────────────────────────────────
local function ShowCameraOverlay(show)
    if show then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(true)
        SendNUIMessage({ show = true })
    else
        SetNuiFocusKeepInput(false)
    end
    SendNUIMessage({ event = "SetCameraRearView", cameraRearView = show })
end

-- ─── Proximity update thread ─────────────────────────────────
local proximityThreadActive = false

local function StartProximityThread()
    if proximityThreadActive then return end
    proximityThreadActive = true

    CreateThread(function()
        while isCameraActive do
            local ped     = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            local waitMs  = 100

            if vehicle ~= 0 then
                local dist     = GetRearProximity(vehicle)
                local speedVec = GetEntitySpeedVector(vehicle, true)
                local reverseSpeed = math.max(0.0, -speedVec.y)

                -- Adaptive poll rate: tighten as the vehicle closes in.
                if dist < 1.0 then
                    waitMs = 16     -- ~60 fps polling when about to make contact
                elseif dist < 2.0 then
                    waitMs = 33     -- ~30 fps
                elseif dist < 3.5 then
                    waitMs = 66     -- ~15 fps
                end

                SendNUIMessage({
                    event        = "UpdateCameraDistance",
                    distance     = dist,
                    reverseSpeed = reverseSpeed
                })
            end

            Wait(waitMs)
            if not isCameraActive then break end
        end
        proximityThreadActive = false
    end)
end

-- ─── Camera create / destroy ──────────────────────────────────

local function DestroyRearCamera_impl()
    if not cameraHandle then return end

    ClearTimecycleModifier()
    RenderScriptCams(false, true, 500, true, false)
    SetCamActive(cameraHandle, false)
    DestroyCam(cameraHandle, true)
    cameraHandle   = nil
    isCameraActive = false

    ShowCameraOverlay(false)
end
DestroyRearCamera = DestroyRearCamera_impl

local function CreateRearCamera_impl(vehicle)
    if cameraHandle then DestroyRearCamera() end

    cameraHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    local rearOffset, heightOffset = CalculateCameraPosition(vehicle)
    AttachCamToEntity(cameraHandle, vehicle, 0.0, rearOffset, heightOffset, true)
    SetCamFov(cameraHandle, Config.RearCamera.cameraFOV)

    local vehicleHeading = GetEntityHeading(vehicle)
    SetCamRot(cameraHandle,
        Config.RearCamera.cameraRotationX,
        0.0,
        vehicleHeading + 180.0,
        2)

    SetCamActive(cameraHandle, true)
    RenderScriptCams(true, true, 500, true, false)

    if Config.RearCamera.cameraEffect then
        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(2.0)
    else
        SetTimecycleModifier("security_camera")
        SetTimecycleModifierStrength(0.5)
    end

    isCameraActive = true
    ShowCameraOverlay(true)
    StartProximityThread()
end
CreateRearCamera = CreateRearCamera_impl

-- ─── Toggle ───────────────────────────────────────────────────

local function ToggleRearCamera_impl()
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then return end

    local driverPed = GetPedInVehicleSeat(vehicle, -1)
    if driverPed ~= playerPed then return end

    if checkVehicleTypes(vehicle) == false then return end

    if Config.RearCamera.needCarplayInstalled then
        local plate = GetVehicleNumberPlateText(vehicle)
        if not getCarHasAccessByPlate(plate) then return end
    end

    if isCameraActive then
        DestroyRearCamera()
    else
        CreateRearCamera(vehicle)
    end
end
ToggleRearCamera = ToggleRearCamera_impl

-- ─── Frame update ─────────────────────────────────────────────

local function UpdateRearCamera_impl()
    if not isCameraActive or not cameraHandle then return end

    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then
        local vehicleHeading = GetEntityHeading(vehicle)
        SetCamRot(cameraHandle,
            Config.RearCamera.cameraRotationX,
            0.0,
            vehicleHeading + 180.0,
            2)

        if Config.RearCamera.shakeIntensity > 0.0 then
            local speed = GetEntitySpeed(vehicle)
            if speed > 5.0 then
                ShakeCam(cameraHandle, "HAND_SHAKE",
                    Config.RearCamera.shakeIntensity * (speed / 50.0))
            end
        end
    else
        DestroyRearCamera()
    end
end
UpdateRearCamera = UpdateRearCamera_impl

local function ShowNotification_impl(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end
ShowNotification = ShowNotification_impl

-- ─── Main control thread ──────────────────────────────────────

if Config.RearCamera.active then
    CreateThread(function()
        while true do
            Wait(0)
            local playerPed = PlayerPedId()
            local vehicle   = GetVehiclePedIsIn(playerPed, false)

            if vehicle ~= 0 then
                local driverPed = GetPedInVehicleSeat(vehicle, -1)
                if driverPed == playerPed then
                    if checkVehicleTypes(vehicle) then

                        if Config.RearCamera.holdToView then
                            if IsControlPressed(0, Config.RearCamera.toggleKey) then
                                if not cameraHandle then
                                    if Config.RearCamera.needCarplayInstalled then
                                        local plate = GetVehicleNumberPlateText(vehicle)
                                        if getCarHasAccessByPlate(plate) then
                                            CreateRearCamera(vehicle)
                                        end
                                    elseif not isCameraActive then
                                        CreateRearCamera(vehicle)
                                    end
                                end
                            else
                                if isCameraActive then DestroyRearCamera() end
                            end

                        elseif not Config.RearCamera.registerKeyMapping then
                            if IsControlJustPressed(0, Config.RearCamera.toggleKey) then
                                ToggleRearCamera()
                            end
                        end

                        UpdateRearCamera()

                        if IsControlJustPressed(0, 177) and wasFromCarPlay then
                            DestroyRearCamera()
                            SetDisplay(true)
                            wasFromCarPlay = false
                        end
                    end
                end
            else
                if isCameraActive then DestroyRearCamera() end
            end
        end
    end)
end

-- ─── Resource stop cleanup ────────────────────────────────────

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DestroyRearCamera()
    end
end)

-- ─── NUI CALLBACK: CarPlay camera button ─────────────────────

RegisterNUICallback("startCamera", function(data, cb)
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then cb("ok") return end

    wasFromCarPlay = true
    if isCameraActive then DestroyRearCamera() end
    CreateRearCamera(vehicle)
    cb("ok")
end)

-- ─── Command (keyboard mapping) ──────────────────────────────

if Config.RearCamera.registerKeyMapping then
    RegisterCommand("rearcam", function()
        ToggleRearCamera()
    end, false)
end

-- ─── Auto-on-reverse thread ───────────────────────────────────

if Config.RearCamera.active and Config.RearCamera.autoWhenReversing then
    CreateThread(function()
        local wasAutoCreated = false
        while true do
            Wait(100)
            local playerPed = PlayerPedId()
            local vehicle   = GetVehiclePedIsIn(playerPed, false)

            if vehicle ~= 0 then
                local driverPed = GetPedInVehicleSeat(vehicle, -1)
                if driverPed == playerPed and checkVehicleTypes(vehicle) then
                    local speedVec    = GetEntitySpeedVector(vehicle, true)
                    local speed       = GetEntitySpeed(vehicle)
                    local isReversing = speedVec.y < -1.0 and speed > 1.0

                    if isReversing and not wasAutoCreated then
                        if not isCameraActive then
                            if Config.RearCamera.needCarplayInstalled then
                                local plate = GetVehicleNumberPlateText(vehicle)
                                if getCarHasAccessByPlate(plate) then
                                    CreateRearCamera(vehicle)
                                    wasAutoCreated = true
                                end
                            else
                                CreateRearCamera(vehicle)
                                wasAutoCreated = true
                            end
                        end
                    elseif not isReversing and wasAutoCreated then
                        if isCameraActive then
                            DestroyRearCamera()
                            wasAutoCreated = false
                        end
                    end
                end
            else
                wasAutoCreated = false
            end
        end
    end)
end

-- ─── Exports ─────────────────────────────────────────────────

exports("IsRearCameraActive", function() return isCameraActive end)
exports("ToggleRearCamera",   function() ToggleRearCamera() end)

-- ─── checkVehicleTypes ────────────────────────────────────────

local function checkVehicleTypes_impl(vehicle)
    local vehicleType = GetVehicleType(vehicle)
    for _, allowedType in ipairs(Config.RearCamera.vehicleTypes) do
        if allowedType == vehicleType then return true end
    end
    return false
end
checkVehicleTypes = checkVehicleTypes_impl
