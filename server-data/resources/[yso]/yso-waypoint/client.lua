local isUiOpen = false
local cachedGroundZ = nil
local lastGroundCheck = 0
local lastWaypointCoords = nil
local GROUND_CHECK_INTERVAL = 3000 -- Her 3 saniyede bir ground Z yenile
local UPDATE_INTERVAL = 100         -- 100ms = ~10 FPS NUI update (0 yerine)

local currentSettings = {
    Enabled = Config.Defaults.Enabled,
    Color = Config.Defaults.Color,
    Shape = Config.Defaults.Shape,
    Unit = Config.Defaults.Unit
}

Citizen.CreateThread(function()
    local savedEnabled = GetResourceKvpInt("wp_enabled")
    local savedColor = GetResourceKvpString("wp_color")
    local savedUnit = GetResourceKvpString("wp_unit")
    local savedShape = GetResourceKvpString("wp_shape")
    local initialized = GetResourceKvpString("wp_initialized")

    if initialized == "true" then
        currentSettings.Enabled = (savedEnabled == 1)
        if savedColor and savedColor ~= "" then currentSettings.Color = savedColor end
        if savedUnit and savedUnit ~= "" then currentSettings.Unit = savedUnit end
        if savedShape and savedShape ~= "" then currentSettings.Shape = savedShape end
    end

    Citizen.Wait(1000)
    SendNUIMessage({
        action = "loadSettings",
        enabled = currentSettings.Enabled,
        shape = currentSettings.Shape,
        color = currentSettings.Color,
        unit = currentSettings.Unit,
        locales = Locales[Config.Locale]
    })
end)

RegisterCommand('waypointsettings', function()
    if not isUiOpen then
        isUiOpen = true
        SetNuiFocus(true, true)

        SendNUIMessage({
            action = "openSettings",
            currentEnabled = currentSettings.Enabled,
            currentColor = currentSettings.Color,
            currentUnit = currentSettings.Unit,
            currentShape = currentSettings.Shape,
            locales = Locales[Config.Locale]
        })
    end
end)

RegisterNUICallback('closeSettings', function(data, cb)
    isUiOpen = false
    SetNuiFocus(false, false)

    if data.save then
        currentSettings.Enabled = data.enabled
        currentSettings.Color = data.color
        currentSettings.Shape = data.shape
        currentSettings.Unit = data.unit
        SetResourceKvpInt("wp_enabled", currentSettings.Enabled and 1 or 0)
        SetResourceKvp("wp_color", currentSettings.Color)
        SetResourceKvp("wp_unit", currentSettings.Unit)
        SetResourceKvp("wp_shape", currentSettings.Shape)
        SetResourceKvp("wp_initialized", "true")
    end

    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        -- Devre disiysa veya waypoint yoksa yavas dongu
        if not currentSettings.Enabled or not IsWaypointActive() then
            SendNUIMessage({ action = "update", show = false })
            Citizen.Wait(1000)
        else
            local waypointBlip = GetFirstBlipInfoId(8)

            if not DoesBlipExist(waypointBlip) then
                SendNUIMessage({ action = "update", show = false })
                Citizen.Wait(500)
            else
                local coords = GetBlipInfoIdCoord(waypointBlip)
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)

                -- Ground Z hesabini cache'le, her frame degil
                local now = GetGameTimer()
                local waypointMoved = lastWaypointCoords == nil
                    or math.abs(lastWaypointCoords.x - coords.x) > 1.0
                    or math.abs(lastWaypointCoords.y - coords.y) > 1.0

                if waypointMoved or (now - lastGroundCheck) > GROUND_CHECK_INTERVAL then
                    local foundGround, zPos = GetGroundZFor_3dCoord(coords.x, coords.y, 2000.0, 0)
                    cachedGroundZ = foundGround and (zPos + 1.0) or playerCoords.z
                    lastGroundCheck = now
                    lastWaypointCoords = coords
                end

                local groundZ = cachedGroundZ or playerCoords.z
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, groundZ)
                local distance = #(playerCoords - vector3(coords.x, coords.y, groundZ))

                SendNUIMessage({
                    action = "update",
                    show = onScreen and distance > 10.0,
                    x = screenX,
                    y = screenY,
                    distance = distance,
                    unitSystem = currentSettings.Unit
                })

                Citizen.Wait(UPDATE_INTERVAL)
            end
        end
    end
end)
