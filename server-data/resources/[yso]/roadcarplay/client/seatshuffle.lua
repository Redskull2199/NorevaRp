-- ============================================================
-- roadcarplay/client/seatshuffle.lua
-- Prevents the game's automatic seat-shuffle behaviour
-- (where an NPC/passenger slides into the driver seat when
-- the driver exits). Also overrides SeatControl to briefly
-- disable the flag around a manual seat change.
-- ============================================================

-- Flag to suppress PedConfigFlag 184 (AUTO_SHUFFLE_TO_DRIVER_SEAT)
-- while a manual seat switch is in progress
local suppressShuffleDuringSwitch = false

-- ============================================================
-- SEAT SHUFFLE PREVENTION THREAD
-- Only runs when Config.DisableSeatShuffle is true.
-- Every 150 ms, sets PedConfigFlag 184 to true when the
-- player is the driver, disabling the shuffle behaviour.
-- ============================================================
if Config.DisableSeatShuffle then
    CreateThread(function()
        while true do
            local playerPed    = PlayerPedId()
            local shouldBlock  = false

            if IsPedInAnyVehicle(playerPed, false) then
                if not suppressShuffleDuringSwitch then
                    -- Only block shuffle when player is in the driver seat (seat 0)
                    local vehicle    = GetVehiclePedIsIn(playerPed, false)
                    local driverSeat = GetPedInVehicleSeat(vehicle, 0)
                    if driverSeat == playerPed then
                        shouldBlock = true
                    end
                end
            end

            -- PedConfigFlag 184 = DISABLE_SHUFFLE_TO_NEXT_VEHICLE_DOOR
            SetPedConfigFlag(playerPed, 184, shouldBlock)
            Wait(150)
        end
    end)
end

-- ============================================================
-- SeatControl(seatIndex)
-- Moves the player into a different empty seat.
-- Briefly sets suppressShuffleDuringSwitch = true so the
-- shuffle-prevention loop doesn't interfere with the switch.
-- ============================================================
local function SeatControl_impl(seatIndex)
    local playerPed = PlayerPedId()
    if not IsPedSittingInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if IsVehicleSeatFree(vehicle, seatIndex) then
        -- Suppress shuffle flag briefly while we initiate the seat change
        CreateThread(function()
            suppressShuffleDuringSwitch = true
            SetPedIntoVehicle(PlayerPedId(), vehicle, seatIndex)
            Wait(50)
            suppressShuffleDuringSwitch = false
        end)

        -- Also issue the native call directly
        SetPedIntoVehicle(PlayerPedId(), vehicle, seatIndex)
    end
end
SeatControl = SeatControl_impl
