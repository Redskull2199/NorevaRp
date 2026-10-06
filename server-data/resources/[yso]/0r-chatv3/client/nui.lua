local Config = require "config.config"

RegisterNUICallback('NUI_READY', function(data, cb)
    NuiLoaded = true
    print('NUI Loaded!')
    cb('ok')
end)

RegisterNUICallback('CONFIG_READY', function(data, cb)
    ConfigLoaded = true
    cb('ok')
end)

RegisterNUICallback('CLOSE_UI', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('0r-chatv3:server:writingText', false)
    cb('ok')
end)

RegisterNUICallback('SEND_MESSAGE', function(data, cb)
    if ConfigLoaded and data and type(data.message) == 'string' and data.message ~= '' then
        TriggerServerEvent('0r-chatv3:server:sendMessage', {
            category = 'kamu',
            message = data.message,
            isImage = false,
            mask = CheckMask(),
        })
    end
    cb('ok')
end)

RegisterNUICallback("EXECUTE_COMMAND", function(command, cb)
    if not ConfigLoaded then return end

    Wait(200)
    ExecuteCommand(command)
    cb('ok')
end)

RegisterNUICallback("TOGGLE_DICE", function(data, cb)
    ExecuteCommand('dice')
    cb('ok')
end)

RegisterNUICallback("TOGGLE_RPS", function(data, cb)
    ExecuteCommand('rps')
    cb('ok')
end)

RegisterNUICallback("TOGGLE_THREAD", function(data, cb)
    ThreadType = data.type
    cb('ok')
end)

RegisterNUICallback("SONG_PLAYING", function(data, cb)
    ActiveSong = {
        title = data.title or "Unknown Title",
        url = data.url or "",
        isPlaying = true,
        volume = Config.MusicSettings.defaultVolume,
    }

    if not ActiveSong.url or ActiveSong.url == "" then
        print("No song URL provided.")
        cb('ok')
        return
    end

    if GetResourceState("xsound") == "started" then
        exports.xsound:PlayUrl("0r-chatv3-song-" .. cache.serverId, ActiveSong.url, ActiveSong.volume, false)

        SendVueMessage("SONG_DATA", {
            title = ActiveSong.title,
            url = ActiveSong.url,
            isPlaying = true,
            volume = ActiveSong.volume,
        })
    else
        print("xsound resource is not started. Please start it to play music.")
    end
    cb('ok')
end)

RegisterNUICallback("TOGGLE_PLAYING", function(data, cb)
    if ActiveSong and ActiveSong.url then
        if GetResourceState('xsound') == 'started' then
            local xsound = exports.xsound

            if xsound:soundExists("0r-chatv3-song-" .. cache.serverId) then
                if not xsound:isPaused("0r-chatv3-song-" .. cache.serverId) then
                    xsound:Pause("0r-chatv3-song-" .. cache.serverId)
                    local newData = xsound:getInfo("0r-chatv3-song-" .. cache.serverId)

                    SendVueMessage("SONG_DATA", {
                        title = ActiveSong.title,
                        url = ActiveSong.url,
                        isPlaying = false,
                        volume = newData.volume,
                    })
                else
                    xsound:Resume("0r-chatv3-song-" .. cache.serverId)
                    local newData = xsound:getInfo("0r-chatv3-song-" .. cache.serverId)

                    SendVueMessage("SONG_DATA", {
                        title = ActiveSong.title,
                        url = ActiveSong.url,
                        isPlaying = true,
                        volume = newData.volume,
                    })
                end
            end
        else
            print("xsound resource is not started.")
        end
    else
        print("No active song to play or stop.")
    end
    cb('ok')
end)

RegisterNUICallback("STOP_MUSIC", function(data, cb)
    if ActiveSong and ActiveSong.url then
        if GetResourceState('xsound') == 'started' then
            local xsound = exports.xsound

            if xsound:soundExists("0r-chatv3-song-" .. cache.serverId) then
                xsound:Destroy("0r-chatv3-song-" .. cache.serverId)
                ActiveSong.isPlaying = {}
            end
        else
            print("xsound resource is not started.")
        end
    else
        print("No active song to play or stop.")
    end

    cb('ok')
end)

RegisterNUICallback("UPDATE_VOLUME", function(data, cb)
    if ActiveSong and ActiveSong.url then
        if GetResourceState('xsound') == 'started' then
            local xsound = exports.xsound

            if xsound:soundExists("0r-chatv3-song-" .. cache.serverId) then
                local volume = data.volume and tonumber(data.volume) / 100 or Config.MusicSettings.defaultVolume
                xsound:setVolume("0r-chatv3-song-" .. cache.serverId, volume)
            end
        else
            print("xsound resource is not started.")
        end
    else
        print("No active song to play or stop.")
    end

    cb('ok')
end)
