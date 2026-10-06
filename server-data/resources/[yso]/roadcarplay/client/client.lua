-- ============================================================
-- roadcarplay/client/client.lua
-- Main client-side logic for Road CarPlay
-- Deobfuscated from obfuscated Lua variable-assignment style
-- ============================================================

-- Module-level state
-- isCarPlayOpen: tracks whether the CarPlay UI is currently displayed
local isCarPlayOpen = false

-- ============================================================
-- INPUT LOCK THREAD
-- While CarPlay is open, block every game control each frame so
-- the player cannot move, shoot, open the map, etc.
-- SetNuiFocus already routes mouse/cursor clicks to the NUI, so
-- this only prevents keyboard / gamepad actions bleeding through.
-- ============================================================
CreateThread(function()
    while true do
        if isCarPlayOpen then
            -- Kill all input contexts every frame while the UI is visible
            DisableAllControlActions(0)  -- on-foot
            DisableAllControlActions(1)  -- vehicle
            DisableAllControlActions(2)  -- camera
            Wait(0)   -- yield every frame while open
        else
            Wait(500) -- sleep longer when closed to avoid wasting CPU
        end
    end
end)

-- ============================================================
-- STARTUP THREAD: Wait for Bridge + player job to be ready
-- ============================================================
CreateThread(function()
    Bridge.WaitForReady()
    -- Poll until the player's job data is available
    while true do
        local playerData = Bridge.GetPlayerData()
        if playerData.job ~= nil then
            break
        end
        Wait(100)
    end
end)

-- ============================================================
-- BRIDGE NETWORK EVENTS: PlayerUnload / PlayerLoaded / JobUpdate
-- ============================================================
Bridge.Events.OnNet("PlayerUnload", function()
    -- Reserved for future cleanup on player unload
end)

Bridge.Events.OnNet("PlayerLoaded", function(xPlayer)
    -- Reserved for future logic on player load
end)

Bridge.Events.OnNet("JobUpdate", function(newJob)
    -- Reserved for future logic on job update
end)

-- ============================================================
-- KEYBIND: Config.OpenKey — toggle CarPlay UI open / closed
-- Players can rebind this in GTA V key bindings settings.
-- Pressing the key while CarPlay is already open will close it.
-- ============================================================
RegisterCommand("toggleCarplay", function()
    if isCarPlayOpen then
        closeCarPlay()
    else
        openCarPlay()
    end
end, false)

RegisterKeyMapping("toggleCarplay", "Toggle CarPlay", "keyboard", Config.OpenKey)

-- ============================================================
-- NET EVENT: roadcarplay:sendOffNotification
-- Receives a notification text and displays it
-- ============================================================
RegisterNetEvent("roadcarplay:sendOffNotification", function(text)
    sendNotification(text)
end)

-- ============================================================
-- NET EVENT: roadcarplay:client:remove
-- Handles CarPlay unit removal (uninstall) flow with job + install check
-- ============================================================
RegisterNetEvent("roadcarplay:client:remove", function()
    local playerPed  = PlayerPedId()
    local vehicle    = GetVehiclePedIsIn(playerPed, false)
    local plate      = GetVehicleNumberPlateText(vehicle)

    -- First verify the player has the required mechanic job
    Bridge.TriggerCallback("roadcarplay:server:checkJob", function(hasJob)
        if hasJob then
            -- Then verify the vehicle actually has CarPlay installed
            Bridge.TriggerCallback("roadcarplay:server:checkInstalled", function(isInstalled)
                if isInstalled then
                    if DoesEntityExist(vehicle) then
                        if IsEntityAVehicle(vehicle) then
                            -- If no build-in animation configured, skip animation and remove directly
                            if not Config.BuildInAnimation then
                                TriggerServerEvent("roadcarplay:server:remove", plate)
                                return
                            end
                            -- Play exit-vehicle animation, then start removal sequence
                            TaskLeaveVehicle(playerPed, vehicle, 0)
                            Citizen.SetTimeout(2500, function()
                                startRemove(vehicle, plate)
                            end)
                        else
                            -- Entity exists but is not a vehicle
                            TriggerEvent("roadcarplay:sendOffNotification", _U("go_inside"))
                        end
                    else
                        -- Vehicle entity no longer exists
                        TriggerEvent("roadcarplay:sendOffNotification", _U("go_inside"))
                    end
                else
                    -- CarPlay not installed on this vehicle
                    TriggerEvent("roadcarplay:sendOffNotification", _U("notinstalled"))
                end
            end, plate)
        end
    end, plate)
end)

-- ============================================================
-- NET EVENT: roadcarplay:client:install
-- Handles CarPlay unit installation flow with job + install check
-- ============================================================
RegisterNetEvent("roadcarplay:client:install", function()
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)
    local plate     = GetVehicleNumberPlateText(vehicle)

    -- First verify the player has the required mechanic job
    Bridge.TriggerCallback("roadcarplay:server:checkJob", function(hasJob)
        if hasJob then
            -- Then verify CarPlay is NOT already installed
            Bridge.TriggerCallback("roadcarplay:server:checkInstalled", function(isInstalled)
                if not isInstalled then
                    if DoesEntityExist(vehicle) then
                        if IsEntityAVehicle(vehicle) then
                            -- If no animation configured, install directly
                            if not Config.BuildInAnimation then
                                TriggerServerEvent("roadcarplay:server:install", plate)
                                return
                            end
                            -- Play exit-vehicle animation, then start install animation
                            TaskLeaveVehicle(playerPed, vehicle, 0)
                            Citizen.SetTimeout(2500, function()
                                startRepair(vehicle, plate)
                            end)
                        else
                            -- Not a vehicle
                            TriggerEvent("roadcarplay:sendOffNotification", _U("go_inside"))
                            return
                        end
                    else
                        -- Entity doesn't exist
                        TriggerEvent("roadcarplay:sendOffNotification", _U("go_inside"))
                        return
                    end
                else
                    -- Already installed
                    TriggerEvent("roadcarplay:sendOffNotification", _U("already_installed"))
                end
            end, plate)
        end
    end, plate)
end)

-- ============================================================
-- openCarPlay()
-- Main function to open the CarPlay UI.
-- Runs many checks before displaying: in vehicle, only driver,
-- not dead, not paused, not blocked, vehicle health, install check.
-- ============================================================
local function openCarPlay_impl()
    -- Must be in a vehicle
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        return
    end

    -- Prevent re-opening if already open
    if isCarPlayOpen then
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)

    -- If OnlyDriver is enabled, check seat (unless AllOccupantsCanControl is on)
    if Config.OnlyDriver then
        if not Config.AllOccupantsCanControl then
            local driverPed = GetPedInVehicleSeat(vehicle, -1)
            if driverPed ~= playerPed then
                TriggerEvent("roadcarplay:sendOffNotification", _U("notdriver"))
                return
            end
        end
    end

    -- Check player is not dead, not in pause menu, not blocked
    if checkPlayerDead() then return end
    if IsPauseMenuActive() then return end
    if blockCarPlay() then return end

    -- Check vehicle body health threshold
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    if Config.DamageUse then
        local healthPct = bodyHealth / 10
        if healthPct < Config.MinimumCarHealth then
            TriggerEvent("roadcarplay:sendOffNotification", _U("damaged"))
            return
        end
    end

    -- Send autopilot settings to NUI
    SendNUIMessage({
        event        = "setAutopilot",
        needAccess   = Config.AutopilotNeedAccess,
        accessCars   = Config.AutopilotAccessCars,
    })

    -- If install requirement is on, verify via callback before showing
    if Config.NeedInstall then
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
        Bridge.TriggerCallback("roadcarplay:checkinstalled", function(installed)
            if installed ~= false then
                SetDisplay(true)
            else
                TriggerEvent("roadcarplay:sendOffNotification", _U("notinstalled"))
            end
        end, plate)
        return
    end

    SetDisplay(true)
end
openCarPlay = openCarPlay_impl

-- NUI Callback: UI requests to close CarPlay
RegisterNUICallback("closeCarPlay", function(data, cb)
    closeCarPlay()
    cb("ok")
end)

-- closeCarPlay(): hides the CarPlay UI
local function closeCarPlay_impl()
    SetDisplay(false)
end
closeCarPlay = closeCarPlay_impl

-- ============================================================
-- SetDisplay(show)
-- Shows or hides the NUI, updates NUI focus, and tracks state
-- ============================================================
local function SetDisplay_impl(show)
    SetNuiFocus(show, show)
    SetNuiFocusKeepInput(show)
    SendNUIMessage({ show = show })
    isCarPlayOpen = show
end
SetDisplay = SetDisplay_impl

-- ============================================================
-- NUI CALLBACKS: Vehicle action controls
-- ============================================================

-- Engine toggle
RegisterNUICallback("engine", function(data, cb)
    EngineControl()
    cb("ok")
end)

-- Interior light toggle
RegisterNUICallback("interiorLight", function(data, cb)
    InteriorLightControl()
    cb("ok")
end)

-- Individual door open/close
RegisterNUICallback("doors", function(data, cb)
    DoorControl(data.door)
    cb("ok")
end)

-- Move to a different seat
RegisterNUICallback("seatchange", function(data, cb)
    SeatControl(data.seat)
    cb("ok")
end)

-- Individual window roll up/down
RegisterNUICallback("windows", function(data, cb)
    WindowControl(data.window, data.door)
    cb("ok")
end)

-- Bomb bay doors toggle (aircraft)
RegisterNUICallback("bombbay", function(data, cb)
    BombBayControl()
    cb("ok")
end)

-- Lock vehicle doors
RegisterNUICallback("lockdoors", function(data, cb)
    lockDoors()
    cb("ok")
end)

-- Set headlight xenon color
RegisterNUICallback("headlightcolor", function(data, cb)
    setHeadlightColor(data.color)
    cb("ok")
end)

-- Return player's current world X/Y coordinates to NUI (for GPS map)
RegisterNUICallback("getLocation", function(data, cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb({ x = coords.x, y = coords.y })
end)

-- Set waypoint on minimap from NUI navigation request
RegisterNUICallback("navigate", function(data, cb)
    SetNewWaypoint(tonumber(data.lng), tonumber(data.lat))
    cb("ok")
end)

-- ============================================================
-- BRIDGE EVENT: PlayerDeath — close CarPlay on death
-- ============================================================
Bridge.Events.On("PlayerDeath", function(data)
    closeCarPlay()
end)

-- ============================================================
-- getCarPlayActive()
-- Returns whether CarPlay UI is currently open
-- ============================================================
local function getCarPlayActive_impl()
    return isCarPlayOpen
end
getCarPlayActive = getCarPlayActive_impl

-- ============================================================
-- THREAD: Periodic vehicle health/status data push to NUI (every 5s)
-- ============================================================
CreateThread(function()
    while true do
        Wait(5000)

        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle then
                -- Resolve display name, checking custom name overrides first
                local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                local customNames = getVehicleNames()
                if modelName and customNames then
                    for _, entry in pairs(customNames) do
                        if entry[1] == modelName then
                            modelName = entry[2]
                        end
                    end
                end

                -- Gather vehicle metrics
                local dirtLevel     = GetVehicleDirtLevel(vehicle)
                local temperature   = GetVehicleEngineTemperature(vehicle)
                local fuel          = getVehicleFuel()
                local engineHealth  = GetVehicleEngineHealth(vehicle)
                local bodyHealth    = GetVehicleBodyHealth(vehicle)

                -- Push data to NUI
                SendNUIMessage({
                    event        = "setHealthData",
                    dirtlevel    = dirtLevel,
                    temperature  = temperature,
                    fuel         = fuel,
                    enginehealth = engineHealth,
                    carhealth    = bodyHealth,
                    carmodel     = modelName,
                })
            end
        end
    end
end)

-- ============================================================
-- NUI CALLBACK: loadPlayer
-- Triggers player profile + phone/account data load into NUI
-- ============================================================
RegisterNUICallback("loadPlayer", function(data, cb)
    loadPlayer()
    cb("ok")
end)

-- ============================================================
-- loadPlayer()
-- Sends product config flags and loads lb-phone contacts,
-- messages, and music admin status into NUI
-- ============================================================
local function loadPlayer_impl()
    -- Tell NUI which products are enabled
    SendNUIMessage({
        event      = "useProducts",
        useLBPhone = Config.LBPhone,
        useRoadPad = Config.RoadPad,
    })

    -- If lb-phone integration is active, delegate all data loading to
    -- messages.lua which uses real SQL-backed server callbacks.
    -- (lb-phone 2.5.3 has no GetConversations / GetContacts client exports)
    if Config.LBPhone then
        loadLBPhoneData()
    end

    -- Load music admin status
    Bridge.TriggerCallback("roadcarplay:music:isMusicAdmin", function(isAdmin)
        SendNUIMessage({
            event   = "setMusicAdmin",
            isAdmin = isAdmin,
        })
    end)
end
loadPlayer = loadPlayer_impl

-- ============================================================
-- NET EVENT: roadcarplay:music:setMusicAdmin
-- Updates music admin flag in NUI
-- ============================================================
RegisterNetEvent("roadcarplay:music:setMusicAdmin")
AddEventHandler("roadcarplay:music:setMusicAdmin", function(isAdmin)
    SendNUIMessage({
        event   = "setMusicAdmin",
        isAdmin = isAdmin,
    })
end)

-- ============================================================
-- NET EVENT: roadcarplay:setUpdate
-- Sends version update info to NUI
-- ============================================================
RegisterNetEvent("roadcarplay:setUpdate")
AddEventHandler("roadcarplay:setUpdate", function(updateAvailable, version)
    SendNUIMessage({
        event           = "setUpdate",
        updateAvailable = updateAvailable,
        version         = version,
    })
end)

-- ============================================================
-- NUI CALLBACK: searchMusicProxy
-- Routes music-search fetch() calls from the NUI through
-- FiveM's server-side PerformHttpRequest (bypasses CORS).
-- music-search-override.js intercepts window.fetch() calls
-- aimed at Invidious/YouTube and redirects here instead.
-- ============================================================
local _musicProxyCallbacks = {}   -- [reqId] = { cb, expiry }
local _musicProxyCounter   = 0
local PROXY_TIMEOUT_MS     = 15000  -- 15 second callback timeout

RegisterNUICallback("searchMusicProxy", function(data, cb)
    if not data or not data.query or type(data.query) ~= "string" or #data.query < 1 then
        cb({ ok = false })
        return
    end

    _musicProxyCounter = _musicProxyCounter + 1
    local reqId  = _musicProxyCounter
    local expiry = GetGameTimer() + PROXY_TIMEOUT_MS

    _musicProxyCallbacks[reqId] = { cb = cb, expiry = expiry }

    TriggerServerEvent("roadcarplay:proxyMusicSearch", reqId, data.query)
end)

RegisterNetEvent("roadcarplay:proxyMusicResult")
AddEventHandler("roadcarplay:proxyMusicResult", function(reqId, ok, body)
    local entry = _musicProxyCallbacks[reqId]
    if entry then
        _musicProxyCallbacks[reqId] = nil
        entry.cb(ok and { ok = true, body = body } or { ok = false })
    end
end)

-- Sweep expired callbacks so the table never leaks
CreateThread(function()
    while true do
        Wait(5000)
        local now = GetGameTimer()
        for reqId, entry in pairs(_musicProxyCallbacks) do
            if now > entry.expiry then
                _musicProxyCallbacks[reqId] = nil
                pcall(entry.cb, { ok = false })
            end
        end
    end
end)

-- ============================================================
-- NUI CALLBACK: fetchVideoMeta
-- Called by the NUI when a YouTube URL is pasted into the music
-- app. Asks the server for title, artist, duration, thumbnail
-- via YouTube oEmbed + Piped /streams — no API key needed.
-- ============================================================
local _metaProxyCallbacks = {}
local _metaProxyCounter   = 0

RegisterNUICallback("fetchVideoMeta", function(data, cb)
    if not data or not data.videoId or type(data.videoId) ~= "string" or #data.videoId < 5 then
        cb({ ok = false })
        return
    end

    _metaProxyCounter = _metaProxyCounter + 1
    local reqId  = _metaProxyCounter
    local expiry = GetGameTimer() + 15000

    _metaProxyCallbacks[reqId] = { cb = cb, expiry = expiry }
    TriggerServerEvent("roadcarplay:fetchVideoMeta", reqId, data.videoId)
end)

RegisterNetEvent("roadcarplay:videoMetaResult")
AddEventHandler("roadcarplay:videoMetaResult", function(reqId, ok, body)
    local entry = _metaProxyCallbacks[reqId]
    if entry then
        _metaProxyCallbacks[reqId] = nil
        entry.cb(ok and { ok = true, body = body } or { ok = false })
    end
end)

-- Sweep expired meta callbacks
CreateThread(function()
    while true do
        Wait(5000)
        local now = GetGameTimer()
        for reqId, entry in pairs(_metaProxyCallbacks) do
            if now > entry.expiry then
                _metaProxyCallbacks[reqId] = nil
                pcall(entry.cb, { ok = false })
            end
        end
    end
end)

-- NUI Callback: check for update from server
RegisterNUICallback("checkUpdate", function(data, cb)
    Bridge.TriggerCallback("roadcarplay:checkUpdate", function(result)
        cb(result)
    end)
end)

-- ============================================================
-- NET EVENT: roadcarplay:setWeather
-- Forwards weather data to NUI
-- ============================================================
RegisterNetEvent("roadcarplay:setWeather")
AddEventHandler("roadcarplay:setWeather", function(weatherData)
    SendNUIMessage({
        event   = "setWeather",
        weather = weatherData,
    })
end)

-- ============================================================
-- WEATHER CHECK (server-relay mode, active when Config.LBPhone = true)
-- Converts GTA weather hash to a readable name, then pushes to server
-- ============================================================
if Config.LBPhone then
    RegisterNetEvent("roadcarplay:checkWeather")
    AddEventHandler("roadcarplay:checkWeather", function()
        local weatherHash, _, _ = GetWeatherTypeTransition()
        local weatherName = nil

        -- Map weather hashes to readable names (for server-side calc)
        if     weatherHash == -1750463879 then weatherName = "ExtraSunny"
        elseif weatherHash ==  916995460  then weatherName = "Clear"
        elseif weatherHash == -1530260698 then weatherName = "Neutral"
        elseif weatherHash ==  282916021  then weatherName = "Smog"
        elseif weatherHash == -1368164796 then weatherName = "Foggy"
        elseif weatherHash ==  821931868  then weatherName = "Clouds"
        elseif weatherHash == -1148613331 then weatherName = "Overcast"
        elseif weatherHash ==  1840358669 then weatherName = "Clearing"
        elseif weatherHash ==  1420204096 then weatherName = "Raining"
        elseif weatherHash == -1233681761 then weatherName = "ThunderStorm"
        elseif weatherHash ==  669657108  then weatherName = "Blizzard"
        elseif weatherHash == -273223690  then weatherName = "Snowing"
        elseif weatherHash ==  603685163  then weatherName = "Snowlight"
        elseif weatherHash == -1429616491 then weatherName = "Christmas"
        elseif weatherHash == -921030142  then weatherName = "Halloween"
        end

        TriggerServerEvent("roadcarplay:calcweather", weatherName)
    end)
end

-- ============================================================
-- ACCOUNT NUI CALLBACKS
-- ============================================================

-- Login to cloud account
RegisterNUICallback("loginCloudAccount", function(data, cb)
    TriggerServerEvent("roadcarplay:account:login", data.mail, data.password)
    cb("ok")
end)

-- Check whether a given email is valid/available
RegisterNUICallback("checkValidMail", function(data, cb)
    Bridge.TriggerCallback("roadcarplay:account:checkValidMail", function(isValid)
        cb(isValid and true or false)
    end, data.mail)
end)

-- Create a new cloud account
RegisterNUICallback("createCloudAccount", function(data, cb)
    TriggerServerEvent(
        "roadcarplay:account:create",
        data.firstname, data.lastname,
        data.birth, data.mail, data.password
    )
    cb("ok")
end)

-- ============================================================
-- NET EVENT: roadcarplay:loginAccount
-- Sets full account info in NUI after successful login
-- ============================================================
RegisterNetEvent("roadcarplay:loginAccount")
AddEventHandler("roadcarplay:loginAccount", function(id, firstname, lastname, mail, profile, birth)
    SendNUIMessage({
        event     = "SetAccountInfos",
        id        = id,
        firstname = firstname,
        lastname  = lastname,
        mail      = mail,
        profile   = profile,
        birth     = birth,
    })
end)

-- NUI Callback: fetch and set account info by account ID
RegisterNUICallback("setAccount", function(data, cb)
    Bridge.TriggerCallback("roadcarplay:account:getaccountinfos", function(accountData)
        if accountData then
            SendNUIMessage({
                event     = "SetAccountInfos",
                id        = accountData.id,
                firstname = accountData.firstname,
                lastname  = accountData.lastname,
                mail      = accountData.mail,
                profile   = accountData.profile,
                birth     = accountData.birth,
            })
        else
            SendNUIMessage({ event = "SetNoAccount" })
        end
    end, data.id)
    cb("ok")
end)

-- ============================================================
-- ObjectInFront(vehicle, coords)
-- Casts a ray from slightly in front of the vehicle to detect
-- any entity blocking the path ahead.
-- Returns: the entity handle hit, or nil
-- ============================================================
local function ObjectInFront(vehicle, coords)
    -- Cast ray from 1.5m ahead of vehicle
    local rayStart = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 1.5, 0.0)
    local rayHandle = CastRayPointToPoint(
        coords.x, coords.y, coords.z,
        rayStart.x, rayStart.y, rayStart.z,
        30, vehicle, 0
    )
    local _, _, _, _, hitEntity = GetRaycastResult(rayHandle)
    return hitEntity
end
ObjectInFront = ObjectInFront

-- ============================================================
-- GetVehicleInDirection(entity, coords)
-- Uses a shape-test ray to detect a vehicle 5m ahead of entity.
-- Returns: vehicle entity handle if found, else nil
-- ============================================================
local function GetVehicleInDirection_impl(entity, coords)
    local ahead = GetOffsetFromEntityInWorldCoords(entity, 0.0, 5.0, 0.0)
    local handle = StartShapeTestRay(coords, ahead, 10, entity, 0)
    local _, result, _, _, hitEntity = GetShapeTestResult(handle)
    if result == 1 then
        if GetEntityType(hitEntity) == 2 then -- 2 = vehicle
            return hitEntity
        end
    end
    return nil
end
GetVehicleInDirection = GetVehicleInDirection_impl

-- ============================================================
-- Animation dictionaries used by the install/remove sequences
-- ============================================================
local animDicts = {
    "mp_car_bomb",
    "move_crawl",
    "amb@world_human_vehicle_mechanic@male@base",
}

-- loadAnim(dictList)
-- Requests and waits for a list of animation dictionaries to load
local function loadAnim(dictList)
    for i = 1, #dictList do
        local dict = dictList[i]
        if not HasAnimDictLoaded(dict) then
            RequestAnimDict(dict)
            if coroutine.isyieldable() then
                while not HasAnimDictLoaded(dict) do
                    Wait(10)
                end
            end
        end
    end
end
loadAnim = loadAnim

-- ============================================================
-- startRepair(vehicle, plate)
-- Plays the full mechanic install animation sequence.
-- The ped crawls under the vehicle and performs work animations,
-- then triggers the server install event when done.
-- ============================================================
local function startRepair_impl(vehicle, plate)
    loadAnim(animDicts)

    local playerPed     = PlayerPedId()
    local pedCoords     = GetEntityCoords(playerPed)
    local animDict      = "mp_car_bomb"
    local propModel     = "prop_carjack"
    local slideTarget   = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -2.0, 0.0)
    local heading       = GetEntityHeading(playerPed)
    local vehicleCoords = GetEntityCoords(vehicle)
    local nearVehicle   = GetVehicleInDirection(playerPed, pedCoords)

    -- Ensure prop model is loaded
    if not HasModelLoaded(propModel) then
        RequestModel(propModel)
        if coroutine.isyieldable() then
            while not HasModelLoaded(propModel) do Wait(10) end
        end
    end

    -- Ensure animation dict is loaded
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        if coroutine.isyieldable() then
            while not HasAnimDictLoaded(animDict) do Wait(10) end
        end
    end

    -- Freeze the target vehicle in place for the animation
    FreezeEntityPosition(vehicle, true)

    -- Create the prop_carjack object for animation attachment
    local prop = CreateObject(joaat(propModel), 0, 0, 0, true, true, true)
    SetEntityCoords(prop, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z - 0.5, false, false, false, false)

    -- Show first progress bar segment (9.25s)
    Config.ProgressBar(9250, _U("progress_bar_text"))

    -- Attach prop to vehicle undercarriage
    AttachEntityToEntity(prop, vehicle, 0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)

    -- ---- Phase 1: Ped approaches vehicle (mp_car_bomb dict) ----
    -- Play mechanic anim at initial position, moving vehicle coords up progressively
    local function playMechanicAnim(dict, zOffset, duration, startFraction)
        TaskPlayAnimAdvanced(playerPed, dict, "car_bomb_mechanic",
            pedCoords.x, pedCoords.y, pedCoords.z,
            0.0, 0.0, heading,
            1.0, 0.5, duration, 1, startFraction, 1, 1)
        Wait(duration)
        SetEntityCoordsNoOffset(vehicle,
            vehicleCoords.x, vehicleCoords.y,
            vehicleCoords.z + zOffset,
            true, true, true)
    end

    playMechanicAnim("mp_car_bomb", 0.01,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.025, 1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.05,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.1,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.15,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.2,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.3,   1000, 0.25)
    animDict = "move_crawl"
    playMechanicAnim("move_crawl",  0.4,   1000, 0.25)

    -- Raise vehicle to final approach height
    SetEntityCoordsNoOffset(vehicle,
        vehicleCoords.x, vehicleCoords.y,
        vehicleCoords.z + 0.5,
        true, true, true)

    -- Disable collision so ped can slide under
    SetEntityCollision(vehicle, false, false)
    TaskPedSlideToCoord(playerPed, slideTarget.x, slideTarget.y, slideTarget.z, heading, 1000)
    Wait(1000)

    -- Show second progress bar segment (11s)
    Config.ProgressBar(11000, _U("progress_bar_text"))

    -- ---- Phase 2: Ped is under vehicle (move_crawl dict) ----
    TaskPlayAnimAdvanced(playerPed, "move_crawl", "onback_bwd",
        pedCoords.x, pedCoords.y, pedCoords.z,
        0.0, 0.0, heading - 180,
        1.0, 0.5, 3000, 1, 0.0, 1, 1)
    animDict = "amb@world_human_vehicle_mechanic@male@base"
    Wait(3000)

    -- ---- Phase 3: Ped does mechanic base animation ----
    TaskPlayAnim(playerPed, "amb@world_human_vehicle_mechanic@male@base", "base",
        8.0, -8.0, 5000, 1, 0, false, false, false)
    animDict = "move_crawl"
    Wait(4000)

    -- Re-enable vehicle & engine
    SetVehicleUndriveable(nearVehicle, false)
    SetVehicleEngineOn(nearVehicle, true, true, false)
    Wait(1000)

    -- ---- Phase 4: Ped crawls forward out from under ----
    local currentPedCoords = GetEntityCoords(playerPed)
    TaskPlayAnimAdvanced(playerPed, "move_crawl", "onback_fwd",
        currentPedCoords.x, currentPedCoords.y, currentPedCoords.z,
        0.0, 0.0, heading - 180,
        1.0, 0.5, 2000, 1, 0.0, 1, 1)
    Wait(3000)

    -- Show third progress bar segment (8.25s)
    animDict = "mp_car_bomb"
    Config.ProgressBar(8250, _U("progress_bar_text"))

    -- ---- Phase 5: Final approach animation (reverse of phase 1) ----
    playMechanicAnim("mp_car_bomb", 0.4,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.3,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.2,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.15,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.1,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.05,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.025, 1000, 0.25)
    animDict = "move_crawl"
    playMechanicAnim("move_crawl",  0.01,  1000, 0.25)

    -- Lower vehicle back to ground
    SetEntityCoordsNoOffset(vehicle,
        vehicleCoords.x, vehicleCoords.y, vehicleCoords.z,
        true, true, true)

    -- Unfreeze vehicle, clean up prop
    FreezeEntityPosition(vehicle, false)
    Wait(100)
    DetachEntity(prop, true, false)
    SetEntityCollision(prop, false, false)
    DeleteEntity(prop)
    SetEntityCollision(vehicle, true, true)

    -- Tell server: installation complete
    TriggerServerEvent("roadcarplay:server:install", plate)
end
startRepair = startRepair_impl

-- ============================================================
-- startRemove(vehicle, plate)
-- Identical animation sequence to startRepair, but fires the
-- remove server event at the end instead of install.
-- ============================================================
local function startRemove_impl(vehicle, plate)
    loadAnim(animDicts)

    local playerPed     = PlayerPedId()
    local pedCoords     = GetEntityCoords(playerPed)
    local animDict      = "mp_car_bomb"
    local propModel     = "prop_carjack"
    local slideTarget   = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, -2.0, 0.0)
    local heading       = GetEntityHeading(playerPed)
    local vehicleCoords = GetEntityCoords(vehicle)
    local nearVehicle   = GetVehicleInDirection(playerPed, pedCoords)

    if not HasModelLoaded(propModel) then
        RequestModel(propModel)
        if coroutine.isyieldable() then
            while not HasModelLoaded(propModel) do Wait(10) end
        end
    end

    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        if coroutine.isyieldable() then
            while not HasAnimDictLoaded(animDict) do Wait(10) end
        end
    end

    FreezeEntityPosition(vehicle, true)

    local prop = CreateObject(joaat(propModel), 0, 0, 0, true, true, true)
    SetEntityCoords(prop, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z - 0.5, false, false, false, false)

    Config.ProgressBar(9250, _U("progress_bar_text"))

    AttachEntityToEntity(prop, vehicle, 0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)

    local function playMechanicAnim(dict, zOffset, duration, startFraction)
        TaskPlayAnimAdvanced(playerPed, dict, "car_bomb_mechanic",
            pedCoords.x, pedCoords.y, pedCoords.z,
            0.0, 0.0, heading,
            1.0, 0.5, duration, 1, startFraction, 1, 1)
        Wait(duration)
        SetEntityCoordsNoOffset(vehicle,
            vehicleCoords.x, vehicleCoords.y,
            vehicleCoords.z + zOffset,
            true, true, true)
    end

    playMechanicAnim("mp_car_bomb", 0.01,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.025, 1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.05,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.1,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.15,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.2,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.3,   1000, 0.25)
    animDict = "move_crawl"
    playMechanicAnim("move_crawl",  0.4,   1000, 0.25)

    SetEntityCoordsNoOffset(vehicle,
        vehicleCoords.x, vehicleCoords.y,
        vehicleCoords.z + 0.5,
        true, true, true)

    SetEntityCollision(vehicle, false, false)
    TaskPedSlideToCoord(playerPed, slideTarget.x, slideTarget.y, slideTarget.z, heading, 1000)
    Wait(1000)

    Config.ProgressBar(11000, _U("progress_bar_text"))

    TaskPlayAnimAdvanced(playerPed, "move_crawl", "onback_bwd",
        pedCoords.x, pedCoords.y, pedCoords.z,
        0.0, 0.0, heading - 180,
        1.0, 0.5, 3000, 1, 0.0, 1, 1)
    animDict = "amb@world_human_vehicle_mechanic@male@base"
    Wait(3000)

    TaskPlayAnim(playerPed, "amb@world_human_vehicle_mechanic@male@base", "base",
        8.0, -8.0, 5000, 1, 0, false, false, false)
    animDict = "move_crawl"
    Wait(4000)

    SetVehicleUndriveable(nearVehicle, false)
    SetVehicleEngineOn(nearVehicle, true, true, false)
    Wait(1000)

    local currentPedCoords = GetEntityCoords(playerPed)
    TaskPlayAnimAdvanced(playerPed, "move_crawl", "onback_fwd",
        currentPedCoords.x, currentPedCoords.y, currentPedCoords.z,
        0.0, 0.0, heading - 180,
        1.0, 0.5, 2000, 1, 0.0, 1, 1)
    Wait(3000)

    animDict = "mp_car_bomb"
    Config.ProgressBar(8250, _U("progress_bar_text"))

    playMechanicAnim("mp_car_bomb", 0.4,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.3,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.2,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.15,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.1,   1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.05,  1000, 0.25)
    playMechanicAnim("mp_car_bomb", 0.025, 1000, 0.25)
    animDict = "move_crawl"
    playMechanicAnim("move_crawl",  0.01,  1000, 0.25)

    SetEntityCoordsNoOffset(vehicle,
        vehicleCoords.x, vehicleCoords.y, vehicleCoords.z,
        true, true, true)

    FreezeEntityPosition(vehicle, false)
    Wait(100)
    DetachEntity(prop, true, false)
    SetEntityCollision(prop, false, false)
    DeleteEntity(prop)
    SetEntityCollision(vehicle, true, true)

    -- Tell server: removal complete
    TriggerServerEvent("roadcarplay:server:remove", plate)
end
startRemove = startRemove_impl

-- ============================================================
-- EXPORT: useRoadCarPlay
-- Allows external resources to trigger the install flow
-- ============================================================
exports("useRoadCarPlay", function()
    TriggerEvent("roadcarplay:client:install")
end)

-- ============================================================
-- ACCESS LIST MANAGEMENT
-- carsWithAccess: list of {plate = "..."} entries the player can use CarPlay on
-- carHasAccessNow: whether the currently occupied vehicle is in the list
-- ============================================================
local carsWithAccess     = {}
local carHasAccessNow    = false

-- getCarsHaveAccess(plate): returns true if plate is in the access list
local function getCarsHaveAccess_impl(plate)
    for i = 1, #carsWithAccess do
        if carsWithAccess[i].plate == plate then
            return true
        end
    end
    return false
end
getCarsHaveAccess = getCarsHaveAccess_impl

-- NET EVENT: roadcarplay:playerLoaded — receive initial access list from server
RegisterNetEvent("roadcarplay:playerLoaded", function(accessList)
    carsWithAccess = accessList
end)

-- NET EVENT: roadcarplay:addCar — add a plate to access list
RegisterNetEvent("roadcarplay:addCar", function(plate)
    if plate then
        table.insert(carsWithAccess, { plate = plate })
    end
end)

-- NET EVENT: roadcarplay:removeCar — remove a plate from access list
RegisterNetEvent("roadcarplay:removeCar", function(plate)
    if plate then
        for i = 1, #carsWithAccess do
            if carsWithAccess[i].plate == plate then
                table.remove(carsWithAccess, i)
                break
            end
        end
    end
end)

-- BRIDGE EVENT: VehicleEntered — update carHasAccessNow
-- Updates for driver seat always; also updates for any seat when AllOccupantsCanControl is on.
Bridge.Events.On("VehicleEntered", function(vehicle, plate, seat, ...)
    if seat == -1 or Config.AllOccupantsCanControl then
        carHasAccessNow = getCarsHaveAccess(plate)
    end
end)

-- BRIDGE EVENT: VehicleExited — reset access flag
Bridge.Events.On("VehicleExited", function(...)
    carHasAccessNow = false
end)

-- getCarHasAccess(): returns whether the current vehicle has CarPlay access.
-- Does a live plate lookup so it works for drivers AND passengers
-- when Config.AllOccupantsCanControl = true.
local function getCarHasAccess_impl()
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)
    if vehicle == 0 then return false end
    local plate = GetVehicleNumberPlateText(vehicle)
    return getCarsHaveAccess(plate)
end
getCarHasAccess = getCarHasAccess_impl

-- getCarHasAccessByPlate(plate): direct plate check used by rearcamera.lua.
local function getCarHasAccessByPlate_impl(plate)
    return getCarsHaveAccess(plate)
end
getCarHasAccessByPlate = getCarHasAccessByPlate_impl

-- ============================================================
-- WEATHER CHECK (local client-side version, active when Config.LBPhone = true)
-- Calculates weather type + random temperature and sets it in NUI
-- ============================================================
if Config.LBPhone then
    RegisterNetEvent("roadcarplay:checkWeather")
    AddEventHandler("roadcarplay:checkWeather", function()
        local weatherHash, _, _ = GetWeatherTypeTransition()
        local weatherType = nil
        local weatherKey  = nil

        if     weatherHash == -1750463879 then weatherKey = "WEATHER_APP_WEATHER_TYPE_EXTRASUNNY";  weatherType = "ExtraSunny"
        elseif weatherHash ==  916995460  then weatherKey = "WEATHER_APP_WEATHER_TYPE_CLEAR";       weatherType = "Clear"
        elseif weatherHash == -1530260698 then weatherKey = "WEATHER_APP_WEATHER_TYPE_NEUTRAL";     weatherType = "Neutral"
        elseif weatherHash ==  282916021  then weatherKey = "WEATHER_APP_WEATHER_TYPE_SMOG";        weatherType = "Smog"
        elseif weatherHash == -1368164796 then weatherKey = "WEATHER_APP_WEATHER_TYPE_FOGGY";       weatherType = "Foggy"
        elseif weatherHash ==  821931868  then weatherKey = "WEATHER_APP_WEATHER_TYPE_CLOUDS";      weatherType = "Clouds"
        elseif weatherHash == -1148613331 then weatherKey = "WEATHER_APP_WEATHER_TYPE_OVERCAST";    weatherType = "Overcast"
        elseif weatherHash ==  1840358669 then weatherKey = "WEATHER_APP_WEATHER_TYPE_CLEARING";    weatherType = "Clearing"
        elseif weatherHash ==  1420204096 then weatherKey = "WEATHER_APP_WEATHER_TYPE_RAINING";     weatherType = "Raining"
        elseif weatherHash == -1233681761 then weatherKey = "WEATHER_APP_WEATHER_TYPE_THUNDERSTORM"; weatherType = "ThunderStorm"
        elseif weatherHash ==  669657108  then weatherKey = "WEATHER_APP_WEATHER_TYPE_BLIZZARD";    weatherType = "Blizzard"
        elseif weatherHash == -273223690  then weatherKey = "WEATHER_APP_WEATHER_TYPE_SNOWING";     weatherType = "Snowing"
        elseif weatherHash ==  603685163  then weatherKey = "WEATHER_APP_WEATHER_TYPE_SNOWLIGHT";   weatherType = "Snowlight"
        elseif weatherHash == -1429616491 then weatherKey = "WEATHER_APP_WEATHER_TYPE_CHRISTMAS";   weatherType = "Christmas"
        elseif weatherHash == -921030142  then weatherKey = "WEATHER_APP_WEATHER_TYPE_HALLOWEEN";   weatherType = "Halloween"
        end

        local temp = temperatureRanges(weatherType)
        TriggerEvent("roadcarplay:setWeather", { temp = temp, type = weatherKey })
    end)
end

-- ============================================================
-- getRandomInt(min, max)
-- Returns a random integer between min and max (inclusive-ish)
-- ============================================================
local function getRandomInt_impl(minVal, maxVal)
    local lo  = math.ceil(minVal)
    local hi  = math.floor(maxVal)
    local rnd = math.floor(math.random() * (hi - lo))
    return rnd + lo
end
getRandomInt = getRandomInt_impl
