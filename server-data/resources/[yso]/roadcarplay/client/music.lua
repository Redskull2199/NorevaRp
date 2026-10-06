-- ============================================================
-- roadcarplay/client/music.lua  (full rewrite)
--
-- Architecture:
--   • Player triggers play → server stores state + broadcasts to ALL clients
--   • Each client receives (plate, url, volume) and finds the vehicle
--     by plate in their own game pool — NO server entity handles
--   • 100ms position-sync thread updates 3D audio to follow the vehicle
--   • onPlayEnd callback fires auto-advance to NUI
--   • All IsPedInAnyVehicle checks return bool (not 1/0)
-- ============================================================

-- ── State ────────────────────────────────────────────────────
-- activeSounds[plate] = { vehicleNetId, isPaused }
local activeSounds   = {}
local isMusicPlaying = false
local isStreamerMode = false
local currentPlate   = nil
-- playSeq[plate] increments on every new play request for that plate.
-- Each play thread captures its seq value and aborts if it no longer matches,
-- meaning a newer play request has already taken over.
local playSeq        = {}

-- ── Helpers ──────────────────────────────────────────────────

-- Find a vehicle entity in the game pool that matches a plate.
-- Returns the entity handle or nil.
local function findVehicleByPlate(plate)
    for _, veh in ipairs(GetGamePool("CVehicle")) do
        if GetVehicleNumberPlateText(veh) == plate then
            return veh
        end
    end
    return nil
end

-- Get a normalised 0.0–1.0 volume from a 0–100 percent value
local function normVol(pct)
    return math.max(0.0, math.min(1.0, (tonumber(pct) or 50) / 100))
end

-- ── Disable radio helper ──────────────────────────────────────
local function disableRadio()
    if Config.DisableRadioMusic then
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            SetVehRadioStation(GetVehiclePedIsIn(ped, false), "OFF")
        end
    end
end

-- ============================================================
-- NUI CALLBACK: playMusic
-- Player wants to play a track.  Send request to server.
-- ============================================================
RegisterNUICallback("playMusic", function(data, cb)
    if isStreamerMode then cb("ok") return end

    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then cb("ok") return end

    disableRadio()

    local vehicle = GetVehiclePedIsIn(ped, false)
    local plate   = GetVehicleNumberPlateText(vehicle)
    local pos     = GetEntityCoords(vehicle)
    local netId   = NetworkGetNetworkIdFromEntity(vehicle)

    -- Build canonical stream URL
    local urlType = data.url_type or "youtube"
    local url
    if urlType == "direct" and data.musicid then
        url = data.musicid
    else
        url = "https://youtube.com/watch?v=" .. (data.musicid or "")
    end

    TriggerServerEvent("roadcarplay:music:play", {
        plate        = plate,
        netId        = netId,
        url          = url,
        url_type     = urlType,
        musicid      = data.musicid,
        trackname    = data.trackname    or "Unknown",
        trackartist  = data.trackartist  or "Unknown",
        trackimage   = data.trackimage   or "/public/img/music/noplaying.png",
        volume       = data.volume       or 50,
        currentSongs = data.currentSongs or {},
    })
    isMusicPlaying = true
    cb("ok")
end)

-- ============================================================
-- NET EVENT: client-music-play
-- Server tells every client to start a sound for a given plate.
-- Payload: plate, url, volume (0-100), netId
-- ============================================================
RegisterNetEvent("client-music-play")
AddEventHandler("client-music-play", function(plate, url, volumePct, netId)
    -- Each new play request for this plate gets a unique sequence number.
    -- Any older in-flight play thread will see its seq is stale and abort.
    playSeq[plate] = (playSeq[plate] or 0) + 1
    local mySeq = playSeq[plate]

    CreateThread(function()
        -- Tear down whatever was playing on this plate
        if activeSounds[plate] then
            AudioLib.FadeOut(plate, 300)
            Wait(320)
            AudioLib.Destroy(plate)
            activeSounds[plate] = nil
        end

        -- Abort if a newer play arrived while we were fading
        if playSeq[plate] ~= mySeq then return end

        -- Find vehicle; retry once if not yet streamed
        local vehicle = findVehicleByPlate(plate)
        if not vehicle then
            Wait(2000)
            if playSeq[plate] ~= mySeq then return end
            vehicle = findVehicleByPlate(plate)
            if not vehicle then return end
        end

        if playSeq[plate] ~= mySeq then return end

        local coords = GetEntityCoords(vehicle)
        AudioLib.Play(plate, url, normVol(volumePct), coords, netId or 0)

        -- Capture the sequence number at the moment this sound starts.
        -- If playSeq changes before onPlayEnd fires (because the user switched
        -- or stopped the song manually), we suppress the auto-advance so the
        -- NUI does NOT treat a deliberate stop/switch as a natural track end.
        local seqAtPlay = mySeq
        AudioLib.OnEnd(plate, function()
            if playSeq[plate] == seqAtPlay then
                TriggerEvent("roadcarplay:music:trackEnded", plate)
            end
        end)

        activeSounds[plate] = { isPaused = false, netId = netId or 0 }
        disableRadio()
    end)
end)

-- When a track ends naturally, tell the NUI
AddEventHandler("roadcarplay:music:trackEnded", function(plate)
    if plate == currentPlate then
        SendNUIMessage({ event = "musicTrackEnded", plate = plate })
    end
    activeSounds[plate] = nil
end)

-- ============================================================
-- NET EVENT: client-music-destroy
-- ============================================================
RegisterNetEvent("client-music-destroy")
AddEventHandler("client-music-destroy", function(plate)
    -- Bump seq so any active play thread aborts
    playSeq[plate] = (playSeq[plate] or 0) + 1
    local mySeq = playSeq[plate]

    if activeSounds[plate] then
        AudioLib.FadeOut(plate, 500)
        CreateThread(function()
            Wait(520)
            if playSeq[plate] ~= mySeq then return end
            AudioLib.Destroy(plate)
            activeSounds[plate] = nil
            if plate == currentPlate then
                isMusicPlaying = false
            end
        end)
    else
        if plate == currentPlate then
            isMusicPlaying = false
        end
    end
end)

-- ============================================================
-- NET EVENT: client-music-pause
-- ============================================================
RegisterNetEvent("client-music-pause")
AddEventHandler("client-music-pause", function(plate)
    if activeSounds[plate] and not activeSounds[plate].isPaused then
        activeSounds[plate].isPaused = true
        AudioLib.Pause(plate)
    end
end)

-- ============================================================
-- NET EVENT: client-music-continue
-- ============================================================
RegisterNetEvent("client-music-continue")
AddEventHandler("client-music-continue", function(plate)
    if activeSounds[plate] and activeSounds[plate].isPaused then
        activeSounds[plate].isPaused = false
        AudioLib.Resume(plate)
        disableRadio()
    end
end)

-- ============================================================
-- NET EVENT: roadcarplay:ChangeVolume
-- ============================================================
RegisterNetEvent("roadcarplay:ChangeVolume")
AddEventHandler("roadcarplay:ChangeVolume", function(plate, volumePct)
    if activeSounds[plate] then
        AudioLib.SetVolume(plate, normVol(volumePct))
    end
end)

-- ============================================================
-- NET EVENT: roadcarplay:music:syncUI
-- ============================================================
RegisterNetEvent("roadcarplay:music:syncUI")
AddEventHandler("roadcarplay:music:syncUI", function(state)
    SendNUIMessage({
        event        = "syncMusicState",
        trackname    = state.trackname,
        trackartist  = state.trackartist,
        trackimage   = state.trackimage,
        volume       = state.volume,
        isPaused     = state.isPaused,
        musicid      = state.musicid,
        currentSongs = state.currentSongs,
    })
end)

-- ============================================================
-- NUI CALLBACKS: transport controls
-- ============================================================
RegisterNUICallback("pauseMusic", function(data, cb)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false))
        TriggerServerEvent("roadcarplay:music:pause", plate)
    end
    cb("ok")
end)

RegisterNUICallback("continuemusic", function(data, cb)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        disableRadio()
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false))
        TriggerServerEvent("roadcarplay:music:continue", plate)
    end
    cb("ok")
end)

RegisterNUICallback("youtstop", function(data, cb)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false))
        TriggerServerEvent("roadcarplay:music:destroy", plate)
    end
    isMusicPlaying = false
    cb("ok")
end)

RegisterNUICallback("musicvolume", function(data, cb)
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false))
        TriggerServerEvent("roadcarplay:music:volume", plate, data.volume)
    end
    cb("ok")
end)

RegisterNUICallback("streamerMod", function(data, cb)
    isStreamerMode = data.streamerMod
    if isStreamerMode then
        -- Stop all active sounds
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false))
            TriggerServerEvent("roadcarplay:music:destroy", plate)
        end
    end
    AudioLib.Streamer(isStreamerMode)
    cb("ok")
end)

-- ============================================================
-- VEHICLE EVENTS: enter / exit
-- ============================================================
Bridge.Events.On("VehicleEntered", function(vehicle, plate, seat, ...)
    currentPlate = plate
    disableRadio()
    TriggerServerEvent("roadcarplay:music:enterVehicle", plate)

    -- Fetch and sync current track state for this vehicle
    Bridge.TriggerCallback("roadcarplay:music:getVehicleState", function(state)
        if state and state.musicid then
            SendNUIMessage({
                event        = "syncMusicState",
                trackname    = state.trackname,
                trackartist  = state.trackartist,
                trackimage   = state.trackimage,
                volume       = state.volume,
                isPaused     = state.isPaused,
                musicid      = state.musicid,
                currentSongs = state.currentSongs,
            })
        end
    end, plate)
end)

Bridge.Events.On("VehicleExited", function(...)
    if currentPlate then
        TriggerServerEvent("roadcarplay:music:exitVehicle", currentPlate)
        currentPlate = nil
    end
    SendNUIMessage({ event = "resetMusicState" })
    isMusicPlaying = false
end)

-- ============================================================
-- POSITIONAL AUDIO SYNC THREAD
-- Runs every 100ms when close to a sound-emitting vehicle,
-- every 2000ms when far away.
-- Uses vehicle plate lookup instead of stale entity handles.
-- ============================================================
CreateThread(function()
    local syncMs = 100
    while true do
        Wait(syncMs)

        if Config.AudioLibrary == "mxsurround" then
            -- mx-surround auto-follows its attached entity
            syncMs = 2000
        else
            local xs = exports.xsound
            syncMs   = 2000  -- default to slow; speed up when close

            for plate, state in pairs(activeSounds) do
                if state.isPaused then goto continue end
                if not AudioLib.Exists(plate) then
                    activeSounds[plate] = nil
                    goto continue
                end

                local vehicle = findVehicleByPlate(plate)
                if not vehicle then
                    -- Vehicle gone — destroy sound
                    AudioLib.Destroy(plate)
                    activeSounds[plate] = nil
                    goto continue
                end

                local soundPos  = GetEntityCoords(vehicle)
                local playerPos = GetEntityCoords(PlayerPedId())
                local dist      = #(playerPos - soundPos)

                if dist < 200 then
                    syncMs = 100
                    AudioLib.SetPosition(plate, soundPos)

                    -- Dynamic hearing distance based on speed / windows
                    local speedKmh = GetEntitySpeed(vehicle) * 3.6
                    local newDist

                    if     speedKmh > 200 then newDist = 140
                    elseif speedKmh > 150 then newDist = 125
                    elseif speedKmh > 110 then newDist = 100
                    elseif speedKmh > 90  then newDist = 80
                    elseif speedKmh > 60  then newDist = 65
                    elseif speedKmh > 30  then newDist = 40
                    else
                        -- Check windows / doors for "leak" effect
                        local broken0 = not IsVehicleWindowIntact(vehicle, 0)
                        local broken1 = not IsVehicleWindowIntact(vehicle, 1)
                        local door0   = GetVehicleDoorAngleRatio(vehicle, 0) > 0.0
                        local door1   = GetVehicleDoorAngleRatio(vehicle, 1) > 0.0

                        if broken0 or broken1 or door0 or door1 then
                            newDist = Config.DefaultMusicRangeBrokenWindow
                        else
                            newDist = Config.DefaultMusicRange
                        end
                    end

                    AudioLib.SetDistance(plate, newDist)
                else
                    AudioLib.SetPosition(plate, soundPos)
                end

                ::continue::
            end
        end
    end
end)

-- ============================================================
-- PLAYLIST MANAGEMENT NUI CALLBACKS
-- ============================================================
RegisterNUICallback("addPlaylistMusic", function(data, cb)
    TriggerServerEvent("roadcarplay:music:addPlaylistMusic",
        data.playlistid, data.musicid,
        data.musicname, data.musicartist,
        data.musicimage, data.musiclength)
    cb("ok")
end)

RegisterNUICallback("createPlaylist", function(data, cb)
    TriggerServerEvent("roadcarplay:music:createPlaylist", data.title)
    cb("ok")
end)

RegisterNUICallback("deletePlaylist", function(data, cb)
    TriggerServerEvent("roadcarplay:music:deletePlaylist", data.id)
    cb("ok")
end)

RegisterNUICallback("loadPlaylists", function(data, cb)
    Bridge.TriggerCallback("roadcarplay:music:loadPlaylists", function(playlists)
        SendNUIMessage({ event = "setPlaylists", playlists = playlists })
    end)
    cb("ok")
end)

RegisterNetEvent("roadcarplay:music:setPlaylists")
AddEventHandler("roadcarplay:music:setPlaylists", function(playlists)
    SendNUIMessage({ event = "setPlaylists", playlists = playlists })
end)

RegisterNUICallback("copyPlaylist", function(data, cb)
    TriggerServerEvent("roadcarplay:music:copyPlaylist", data.playlist, data.title, data.image)
    cb("ok")
end)

RegisterNUICallback("editPlaylist", function(data, cb)
    TriggerServerEvent("roadcarplay:music:changePlaylist", data.id, data.title, data.image)
    cb("ok")
end)

RegisterNUICallback("removeMusicFromPlaylist", function(data, cb)
    TriggerServerEvent("roadcarplay:music:removePlaylistMusic", data.playlistid, data.musicid)
    cb("ok")
end)

-- Fixed: was RegisterNuiCallback (lowercase u — broken typo in original)
RegisterNUICallback("getMusicSearch", function(data, cb)
    Bridge.TriggerCallback("roadcarplay:music:getSearch", function(results)
        cb(results)
    end, data.search)
end)

RegisterNUICallback("submitMusic", function(data, cb)
    TriggerServerEvent("roadcarplay:music:submitSong",
        data.songid, data.url_type,
        data.title, data.artist,
        data.thumbnail, data.length)
    cb("ok")
end)

RegisterNUICallback("checkMusicAdmin", function(data, cb)
    Bridge.TriggerCallback("roadcarplay:music:isMusicAdmin", function(isAdmin)
        SendNUIMessage({ event = "setMusicAdmin", isAdmin = isAdmin })
        cb(isAdmin)
    end)
end)

RegisterNUICallback("getSubmissions", function(data, cb)
    Bridge.TriggerCallback("roadcarplay:music:getSubmissions", function(subs)
        SendNUIMessage({ event = "setSubmissions", submissions = subs })
        cb(subs)
    end)
end)

RegisterNUICallback("approveSubmission", function(data, cb)
    TriggerServerEvent("roadcarplay:music:approveSubmission", data.id, data.overrides)
    cb("ok")
end)

RegisterNUICallback("rejectSubmission", function(data, cb)
    TriggerServerEvent("roadcarplay:music:rejectSubmission", data.id)
    cb("ok")
end)

RegisterNUICallback("deleteLibrarySong", function(data, cb)
    TriggerServerEvent("roadcarplay:music:deleteLibrarySong", data.id)
    cb("ok")
end)

RegisterNUICallback("addLibrarySong", function(data, cb)
    TriggerServerEvent("roadcarplay:music:addLibrarySong",
        data.songid, data.url_type,
        data.title, data.artist,
        data.thumbnail, data.length)
    cb("ok")
end)
