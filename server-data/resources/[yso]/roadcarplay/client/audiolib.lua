-- ============================================================
-- roadcarplay/client/audiolib.lua  (full rewrite)
-- Audio abstraction layer: xsound + mx-surround
--
-- xSound client API (exports.xsound):
--   PlayUrlPos(name, url, volume, Vector3, loop, options)
--   Position(name, Vector3)
--   Distance(name, distance)
--   Destroy(name)
--   Pause(name)
--   Resume(name)
--   setVolumeMax(name, volume)   -- 0.0-1.0, for 3D sound
--   setVolume(name, volume)      -- 0.0-1.0, for non-3D
--   soundExists(name)
--   isPaused(name)
--   isPlaying(name)
--   Streamer(bool)
--   onPlayStart(name, fn)
--   onPlayEnd(name, fn)
--   fadeOut(name, ms)
--   fadeIn(name, ms, volume)
--
-- mx-surround client API (exports["mx-surround"]):
--   Play(name, url, volume, loop, entityOrVec)
--   attachEntity(name, netId)
--   Stop(name)
--   Pause(name)
--   Resume(name)
--   SetVolume(name, volume)
--   SetMaxDistance(name, dist)
-- ============================================================

AudioLib = {}

-- ── Helpers ──────────────────────────────────────────────────
local function xs()  return exports.xsound          end
local function mx()  return exports["mx-surround"]  end

-- ============================================================
-- AudioLib.Play(soundId, url, volume, coords, netId)
--   soundId : unique string (vehicle plate)
--   url     : full stream URL
--   volume  : 0.0–1.0
--   coords  : Vector3 world position (initial)
--   netId   : network entity ID of the vehicle (for mx-surround attach)
-- ============================================================
function AudioLib.Play(soundId, url, volume, coords, netId)
    volume = volume or 0.5

    if Config.AudioLibrary == "mxsurround" then
        mx():Play(soundId, url, volume, false, coords)
        if netId and netId > 0 then
            mx():attachEntity(soundId, netId)
        end
    else
        -- xSound: PlayUrlPos(name, url, volume, Vector3, loop, options)
        xs():PlayUrlPos(soundId, url, volume, coords, false)
        xs():setVolumeMax(soundId, volume)
        xs():Distance(soundId, Config.DefaultMusicRange)
    end
end

-- ============================================================
-- AudioLib.Pause / Resume / Destroy
-- ============================================================
function AudioLib.Pause(soundId)
    if Config.AudioLibrary == "mxsurround" then
        mx():Pause(soundId)
    else
        xs():Pause(soundId)
    end
end

function AudioLib.Resume(soundId)
    if Config.AudioLibrary == "mxsurround" then
        mx():Resume(soundId)
    else
        xs():Resume(soundId)
    end
end

function AudioLib.Destroy(soundId)
    if Config.AudioLibrary == "mxsurround" then
        pcall(function() mx():Stop(soundId) end)
    else
        if xs():soundExists(soundId) then
            xs():Destroy(soundId)
        end
    end
end

-- ============================================================
-- AudioLib.SetVolume(soundId, volume)   volume 0.0–1.0
-- ============================================================
function AudioLib.SetVolume(soundId, volume)
    if Config.AudioLibrary == "mxsurround" then
        pcall(function() mx():SetVolume(soundId, volume) end)
    else
        if xs():soundExists(soundId) then
            xs():setVolumeMax(soundId, volume)
        end
    end
end

-- ============================================================
-- AudioLib.SetPosition(soundId, coords)
-- ============================================================
function AudioLib.SetPosition(soundId, coords)
    if Config.AudioLibrary == "mxsurround" then
        -- mx-surround auto-follows attached entity; no manual update needed
    else
        if xs():soundExists(soundId) then
            xs():Position(soundId, coords)
        end
    end
end

-- ============================================================
-- AudioLib.SetDistance(soundId, distance)
-- ============================================================
function AudioLib.SetDistance(soundId, distance)
    if Config.AudioLibrary == "mxsurround" then
        pcall(function() mx():SetMaxDistance(soundId, distance) end)
    else
        if xs():soundExists(soundId) then
            xs():Distance(soundId, distance)
        end
    end
end

-- ============================================================
-- AudioLib.Exists / IsPlaying
-- ============================================================
function AudioLib.Exists(soundId)
    if Config.AudioLibrary == "mxsurround" then
        -- mx-surround has no existence check; assume true if we put it there
        return true
    else
        return xs():soundExists(soundId)
    end
end

function AudioLib.IsPlaying(soundId)
    if Config.AudioLibrary == "mxsurround" then
        return true
    else
        return xs():isPlaying(soundId)
    end
end

-- ============================================================
-- AudioLib.OnEnd(soundId, callback)
-- Fires callback when the track finishes naturally.
-- mx-surround has no equivalent — callback never fires there.
-- ============================================================
function AudioLib.OnEnd(soundId, callback)
    if Config.AudioLibrary ~= "mxsurround" then
        xs():onPlayEnd(soundId, callback)
    end
end

-- ============================================================
-- AudioLib.Streamer(enable)  — xSound-only streamer mode
-- ============================================================
function AudioLib.Streamer(enable)
    if Config.AudioLibrary ~= "mxsurround" then
        xs():Streamer(enable)
    end
end

-- ============================================================
-- AudioLib.FadeOut(soundId, ms)
-- AudioLib.FadeIn(soundId, ms, volume)
--
-- These are implemented as local Citizen threads rather than
-- delegating to xsound's fadeOut/fadeIn exports.
--
-- Why: xsound's exports use Citizen.Wait() inside their loops.
-- When a cross-resource export call yields via Citizen.Wait,
-- FiveM's scheduler rethrows any coroutine error at the call
-- boundary — making it impossible to catch with pcall in the
-- calling resource. If the sound is destroyed mid-fade (e.g.
-- by a concurrent client-music-destroy event or xsound's DUI
-- crash-recovery loop), xsound crashes with:
--   info.lua:61: attempt to index a nil value (field '?')
-- By owning the fade loop here and guarding each step with
-- soundExists(), we stay safe regardless of xsound's state.
-- ============================================================

local FADE_STEPS = 20  -- number of volume steps per fade

function AudioLib.FadeOut(soundId, ms)
    if Config.AudioLibrary ~= "mxsurround" then
        CreateThread(function()
            if not xs():soundExists(soundId) then return end
            local startVol = xs():soundExists(soundId) and xs():getVolume(soundId) or 0
            if startVol <= 0 then return end
            local stepWait = math.max(1, math.floor(ms / FADE_STEPS))
            local stepVol  = startVol / FADE_STEPS
            for _ = 1, FADE_STEPS do
                Wait(stepWait)
                if not xs():soundExists(soundId) then return end
                startVol = startVol - stepVol
                if startVol < 0 then startVol = 0 end
                local ok = pcall(function()
                    xs():setVolumeMax(soundId, startVol)
                    xs():setVolume(soundId, startVol)
                end)
                if not ok or startVol <= 0 then return end
            end
        end)
    end
end

function AudioLib.FadeIn(soundId, ms, volume)
    if Config.AudioLibrary ~= "mxsurround" then
        local targetVol = volume or 0.5
        CreateThread(function()
            if not xs():soundExists(soundId) then return end
            local stepWait = math.max(1, math.floor(ms / FADE_STEPS))
            local stepVol  = targetVol / FADE_STEPS
            local curVol   = 0
            for _ = 1, FADE_STEPS do
                Wait(stepWait)
                if not xs():soundExists(soundId) then return end
                curVol = curVol + stepVol
                if curVol > targetVol then curVol = targetVol end
                local ok = pcall(function()
                    xs():setVolumeMax(soundId, curVol)
                    xs():setVolume(soundId, curVol)
                end)
                if not ok then return end
            end
        end)
    end
end
