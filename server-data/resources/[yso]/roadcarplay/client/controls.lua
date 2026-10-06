-- ============================================================
-- roadcarplay/client/controls.lua
-- Vehicle control functions: windows, engine, doors, seats,
-- headlights, bomb bay
-- ============================================================

-- Per-window "up" state flags (true = window is up/closed)
local windowFrontLeft  = true   -- window index 0
local windowFrontRight = true   -- window index 1
local windowRearLeft   = true   -- window index 2
local windowRearRight  = true   -- window index 3

-- ============================================================
-- AllWindowControl()
-- Toggles ALL four windows at once.
-- If any window flag is true, rolls all down.
-- Otherwise rolls all up.
-- ============================================================
local function AllWindowControl_impl()
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if windowFrontLeft or windowFrontRight or windowRearLeft or windowRearRight then
        -- At least one window is closed — roll them all down
        RollDownWindow(vehicle, 0)
        RollDownWindow(vehicle, 1)
        RollDownWindow(vehicle, 2)
        RollDownWindow(vehicle, 3)
        windowFrontLeft  = false
        windowFrontRight = false
        windowRearLeft   = false
        windowRearRight  = false
    else
        -- All windows are down — roll them all up
        RollUpWindow(vehicle, 0)
        RollUpWindow(vehicle, 1)
        RollUpWindow(vehicle, 2)
        RollUpWindow(vehicle, 3)
        windowFrontLeft  = true
        windowFrontRight = true
        windowRearLeft   = true
        windowRearRight  = true
    end
end
AllWindowControl = AllWindowControl_impl

-- ============================================================
-- EngineControl()
-- Toggles the vehicle engine on/off for the player's current vehicle.
-- Only works from front passenger seat (index 0) or driver seat.
-- ============================================================
local function EngineControl_impl()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == nil or vehicle == 0 then return end

    -- Only the ped in seat 0 (front passenger/driver context) may toggle
    local pedInSeat = GetPedInVehicleSeat(vehicle, 0)
    if pedInSeat then
        local isRunning = GetIsVehicleEngineRunning(vehicle)
        SetVehicleEngineOn(vehicle, not isRunning, false, true)
    end
end
EngineControl = EngineControl_impl

-- ============================================================
-- InteriorLightControl()
-- Toggles the vehicle interior dome light.
-- ============================================================
local function InteriorLightControl_impl()
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if IsVehicleInteriorLightOn(vehicle) then
        SetVehicleInteriorlight(vehicle, false)
    else
        SetVehicleInteriorlight(vehicle, true)
    end
end
InteriorLightControl = InteriorLightControl_impl

-- ============================================================
-- DoorControl(doorIndex)
-- Toggles a specific vehicle door open or closed.
-- doorIndex: 0=front-left, 1=front-right, 2=rear-left, 3=rear-right, etc.
-- ============================================================
local function DoorControl_impl(doorIndex)
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle   = GetVehiclePedIsIn(playerPed, false)
    local doorAngle = GetVehicleDoorAngleRatio(vehicle, doorIndex)

    if doorAngle > 0.0 then
        -- Door is open — close it
        SetVehicleDoorShut(vehicle, doorIndex, false)
    else
        -- Door is closed — open it
        SetVehicleDoorOpen(vehicle, doorIndex, false)
    end
end
DoorControl = DoorControl_impl

-- ============================================================
-- setHeadlightColor(colorIndex)
-- Enables xenon headlights (mod 22) and sets their color.
-- colorIndex: the xenon light color ID
-- ============================================================
local function setHeadlightColor_impl(colorIndex)
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    ToggleVehicleMod(vehicle, 22, true)        -- enable xenon headlights mod
    SetVehicleXenonLightsColor(vehicle, colorIndex)
end
setHeadlightColor = setHeadlightColor_impl

-- ============================================================
-- SeatControl(seatIndex)
-- Moves the player into a different empty seat in their vehicle.
-- seatIndex: the seat index to move to
-- ============================================================
local function SeatControl_impl(seatIndex)
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if IsVehicleSeatFree(vehicle, seatIndex) then
        SetPedIntoVehicle(PlayerPedId(), vehicle, seatIndex)
    end
end
SeatControl = SeatControl_impl

-- ============================================================
-- WindowControl(windowIndex, doorIndex)
-- Toggles a single window up or down.
-- windowIndex: which window (0-3)
-- doorIndex: used to check if vehicle has a door at that position
-- State flags: windowFrontLeft/Right and windowRearLeft/Right
-- ============================================================
local function WindowControl_impl(windowIndex, doorIndex)
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if windowIndex == 0 then
        if windowFrontLeft == true then
            -- Roll down if vehicle has this door
            if DoesVehicleHaveDoor(vehicle, doorIndex) then
                RollDownWindow(vehicle, windowIndex)
                windowFrontLeft = false
            end
        else
            RollUpWindow(vehicle, windowIndex)
            windowFrontLeft = true
        end

    elseif windowIndex == 1 then
        if windowFrontRight == true then
            if DoesVehicleHaveDoor(vehicle, doorIndex) then
                RollDownWindow(vehicle, windowIndex)
                windowFrontRight = false
            end
        else
            RollUpWindow(vehicle, windowIndex)
            windowFrontRight = true
        end

    elseif windowIndex == 2 then
        if windowRearLeft == true then
            if DoesVehicleHaveDoor(vehicle, doorIndex) then
                RollDownWindow(vehicle, windowIndex)
                windowRearLeft = false
            end
        else
            RollUpWindow(vehicle, windowIndex)
            windowRearLeft = true
        end

    elseif windowIndex == 3 then
        if windowRearRight == true then
            if DoesVehicleHaveDoor(vehicle, doorIndex) then
                RollDownWindow(vehicle, windowIndex)
                windowRearRight = false
            end
        else
            RollUpWindow(vehicle, windowIndex)
            windowRearRight = true
        end
    end
end
WindowControl = WindowControl_impl

-- ============================================================
-- FrontWindowControl()
-- Toggles the two front windows (0 and 1) together.
-- ============================================================
local function FrontWindowControl_impl()
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if windowFrontLeft or windowFrontRight then
        -- Roll front windows down
        RollDownWindow(vehicle, 0)
        RollDownWindow(vehicle, 1)
        windowFrontLeft  = false
        windowFrontRight = false
    else
        -- Roll front windows up
        RollUpWindow(vehicle, 0)
        RollUpWindow(vehicle, 1)
        windowFrontLeft  = true
        windowFrontRight = true
    end
end
FrontWindowControl = FrontWindowControl_impl

-- ============================================================
-- BackWindowControl()
-- Toggles the two rear windows (2 and 3) together.
-- ============================================================
local function BackWindowControl_impl()
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if windowRearLeft or windowRearRight then
        -- Roll rear windows down
        RollDownWindow(vehicle, 2)
        RollDownWindow(vehicle, 3)
        windowRearLeft  = false
        windowRearRight = false
    else
        -- Roll rear windows up
        RollUpWindow(vehicle, 2)
        RollUpWindow(vehicle, 3)
        windowRearLeft  = true
        windowRearRight = true
    end
end
BackWindowControl = BackWindowControl_impl

-- ============================================================
-- BombBayControl()
-- Toggles the aircraft bomb bay doors open or closed.
-- ============================================================
local function BombBayControl_impl()
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if AreBombBayDoorsOpen(vehicle) then
        CloseBombBayDoors(vehicle)
    else
        OpenBombBayDoors(vehicle)
    end
end
BombBayControl = BombBayControl_impl
