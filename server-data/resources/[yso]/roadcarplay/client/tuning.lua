-- ============================================================
-- roadcarplay/client/tuning.lua
-- Reads current vehicle tuning/modification data and returns
-- it to the NUI Tuning Overview screen.
-- ============================================================

-- ============================================================
-- NUI CALLBACK: tuning:getData
-- Collects all mod indices, colors, and toggles from the
-- player's current vehicle and returns them as a table.
-- ============================================================
RegisterNUICallback("tuning:getData", function(data, cb)
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        cb({ success = false, error = "Not in vehicle" })
        return
    end

    -- Basic vehicle info
    local modelHash  = GetEntityModel(vehicle)
    local modelName  = GetDisplayNameFromVehicleModel(modelHash)

    -- Colors
    local primaryColor, secondaryColor = GetVehicleColours(vehicle)
    local pearlColor,   wheelColor     = GetVehicleExtraColours(vehicle)

    -- Build tuning data table
    local tuningData = {}
    tuningData.vehicleName = modelName

    -- Performance mods (mod indices from SetVehicleMod)
    tuningData.engine       = GetVehicleMod(vehicle, 11)
    tuningData.brakes       = GetVehicleMod(vehicle, 12)
    tuningData.transmission = GetVehicleMod(vehicle, 13)
    tuningData.suspension   = GetVehicleMod(vehicle, 15)
    tuningData.armor        = GetVehicleMod(vehicle, 16)
    tuningData.turbo        = IsToggleModOn(vehicle, 18)    -- turbo = toggle mod 18

    -- Visual/bodywork mods
    tuningData.spoiler      = GetVehicleMod(vehicle, 0)
    tuningData.frontBumper  = GetVehicleMod(vehicle, 1)
    tuningData.rearBumper   = GetVehicleMod(vehicle, 2)
    tuningData.sideSkirt    = GetVehicleMod(vehicle, 3)
    tuningData.exhaust      = GetVehicleMod(vehicle, 4)
    tuningData.frame        = GetVehicleMod(vehicle, 5)
    tuningData.grille       = GetVehicleMod(vehicle, 6)
    tuningData.hood         = GetVehicleMod(vehicle, 7)
    tuningData.fender       = GetVehicleMod(vehicle, 8)
    tuningData.rightFender  = GetVehicleMod(vehicle, 9)
    tuningData.roof         = GetVehicleMod(vehicle, 10)

    -- Wheels
    tuningData.wheelType    = GetVehicleWheelType(vehicle)
    tuningData.frontWheels  = GetVehicleMod(vehicle, 23)
    tuningData.backWheels   = GetVehicleMod(vehicle, 24)

    -- Colors
    tuningData.primaryColor   = primaryColor
    tuningData.secondaryColor = secondaryColor
    tuningData.pearlColor     = pearlColor
    tuningData.wheelColor     = wheelColor

    -- Window tint and livery
    tuningData.windowTint   = GetVehicleWindowTint(vehicle)
    tuningData.livery       = GetVehicleLivery(vehicle)

    -- Other mods
    tuningData.horn         = GetVehicleMod(vehicle, 14)
    tuningData.xenon        = IsToggleModOn(vehicle, 22)   -- xenon lights = toggle mod 22
    tuningData.smoke        = IsToggleModOn(vehicle, 20)   -- tyre smoke    = toggle mod 20

    cb({ success = true, data = tuningData })
end)
