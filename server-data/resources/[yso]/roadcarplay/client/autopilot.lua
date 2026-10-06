-- ============================================================
-- roadcarplay/client/autopilot.lua
-- CarPlay autopilot: drives the player's vehicle to a map waypoint.
-- Uses TaskVehicleDriveToCoordLongrange, monitors arrival,
-- and stops if the player presses W (accelerate).
-- ============================================================

-- State
local autopilotActive  = false
local waypointX        = 0.0
local waypointY        = 0.0
local waypointZ        = 0.0

-- ============================================================
-- NUI CALLBACK: autopilot
-- If autopilot is already active, cancel it.
-- Otherwise, fire the start event.
-- ============================================================
RegisterNUICallback("autopilot", function(data, cb)
    if autopilotActive then
        -- Cancel autopilot if player is in a vehicle
        if IsPedInAnyVehicle(PlayerPedId()) then
            ClearPedTasks(PlayerPedId())
            SendNUIMessage({ event = "autopilot", autopilot = false })
            autopilotActive = false
        end
        return
    end

    TriggerEvent("autopilot:start")
    cb("ok")
end)

-- ============================================================
-- EVENT: autopilot:start
-- Gets the current GPS waypoint blip, drives the vehicle there.
-- ============================================================
RegisterNetEvent("autopilot:start")
AddEventHandler("autopilot:start", function(data)
    local playerPed   = PlayerPedId()
    local vehicle     = GetVehiclePedIsIn(playerPed, false)
    local modelHash   = GetEntityModel(vehicle)
    local modelName   = GetDisplayNameFromVehicleModel(modelHash)

    -- Look up the GPS waypoint blip (type 8)
    local waypointBlip = GetFirstBlipInfoId(8)

    if waypointBlip and waypointBlip ~= 0 then
        -- Store waypoint coordinates
        local blipCoords = GetBlipCoords(waypointBlip)
        waypointX = blipCoords.x
        waypointY = blipCoords.y
        waypointZ = blipCoords.z

        -- Command the vehicle to drive to the waypoint
        TaskVehicleDriveToCoordLongrange(
            playerPed, vehicle,
            waypointX, waypointY, waypointZ,
            Config.AutoMaxSpeed,
            Config.AutoFlagsUsed,
            2.0   -- stop radius
        )

        autopilotActive = true

        -- Notify NUI that autopilot is engaged
        SendNUIMessage({ event = "autopilot", autopilot = true })

        -- Start arrival monitor and cancel-on-W monitor threads
        checkDrivingToEnd()
        checkPressW()
    else
        -- No waypoint set — notify player
        sendNotification(_U("autopilot_no_waypoint"))
    end
end)

-- ============================================================
-- checkDrivingToEnd()
-- Spawns a thread that monitors distance to waypoint.
-- When within 10 units, gradually slows the vehicle to a stop.
-- ============================================================
local function checkDrivingToEnd_impl()
    CreateThread(function()
        while true do
            -- Exit thread when autopilot is cancelled
            if not autopilotActive then break end

            Wait(200)

            local playerPed   = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local blip        = GetFirstBlipInfoId(8)

            -- Check distance from player to stored waypoint
            local dist = Vdist(
                playerCoords.x, playerCoords.y, playerCoords.z,
                waypointX, waypointY, playerCoords.z   -- flat distance
            )

            if dist <= 10 then
                -- Arrived — stop the vehicle progressively
                local ped     = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(ped, false)

                ClearPedTasks(ped)

                -- Gradual speed reduction sequence
                SetVehicleForwardSpeed(vehicle, 19.0) Wait(200)
                SetVehicleForwardSpeed(vehicle, 15.0) Wait(200)
                SetVehicleForwardSpeed(vehicle, 11.0) Wait(200)
                SetVehicleForwardSpeed(vehicle,  6.0) Wait(200)
                SetVehicleForwardSpeed(vehicle,  0.0)

                autopilotActive = false
                sendNotification(_U("autopilot_reached_destionation"))
                SendNUIMessage({ event = "autopilot", autopilot = false })
            end
        end
    end)
end
checkDrivingToEnd = checkDrivingToEnd_impl

-- ============================================================
-- checkPressW()
-- Spawns a thread that cancels autopilot when the player
-- presses W (control 32 = accelerate / move forward).
-- ============================================================
local function checkPressW_impl()
    CreateThread(function()
        while true do
            -- Exit thread when autopilot is cancelled
            if not autopilotActive then break end

            Wait(0)

            -- Control 32 = INPUT_VEH_ACCELERATE (W key while in vehicle)
            if IsControlPressed(0, 32) then
                local playerPed = PlayerPedId()
                ClearPedTasks(playerPed)
                autopilotActive = false
                sendNotification(_U("autopilot_disengaged"))
                SendNUIMessage({ event = "autopilot", autopilot = false })
            end
        end
    end)
end
checkPressW = checkPressW_impl
