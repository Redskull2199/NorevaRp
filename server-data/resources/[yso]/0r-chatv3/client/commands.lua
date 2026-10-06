local Config = require "config.config"

RegisterCommand(Config.Commands['me'].name, function(source, args, rawCommand)
    local text = ""
    for _, v in ipairs(args) do
        text = text .. " " .. v
    end

    if text:len() == 0 then
        return
    end

    local haveMask = CheckMask()

    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = "me",
        message = text,
        isImage = false,
        mask = haveMask,
    })
end, false)

RegisterCommand(Config.Commands['do'].name, function(source, args, rawCommand)
    local text = ""
    for _, v in ipairs(args) do
        text = text .. " " .. v
    end

    if text:len() == 0 then
        return
    end

    local haveMask = CheckMask()

    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = "do",
        message = text,
        isImage = false,
        mask = haveMask,
    })
end, false)

-- RegisterCommand(Config.Commands['ooc'].name, function(source, args, rawCommand)
--     local text = ""
--     for _, v in ipairs(args) do
--         text = text .. " " .. v
--     end

--     if text:len() == 0 then
--         return
--     end

--     local haveMask = CheckMask()

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "ooc",
--         message = text,
--         isImage = false,
--         mask = haveMask,
--     })
-- end, false)

-- RegisterCommand(Config.Commands['pm'].name, function(source, args, rawCommand)
--     if #args < 2 then
--         return
--     end

--     local text = ""
--     for i = 2, #args do
--         text = text .. " " .. args[i]
--     end

--     if text:len() == 0 then
--         return
--     end

--     local haveMask = CheckMask()

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "pm",
--         message = text,
--         isImage = false,
--         mask = haveMask,
--         targetPlayer = tonumber(args[1]),
--     })
-- end, false)

RegisterCommand(Config.Commands['admin'].name, function(source, args, rawCommand)
    local text = ""
    for _, v in ipairs(args) do
        text = text .. " " .. v
    end

    if text:len() == 0 then
        return
    end

    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = "admin",
        message = text,
        isImage = false,
        mask = false,
    })
end, false)

RegisterCommand(Config.Commands['announce'].name, function(source, args, rawCommand)
    local text = ""
    for _, v in ipairs(args) do
        text = text .. " " .. v
    end

    if text:len() == 0 then
        return
    end

    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = "server",
        message = text,
        isImage = false,
        mask = false,
    })
end, false)

RegisterCommand(Config.Commands['dice'].name, function(source, args, rawCommand)
    lib.requestAnimDict("anim@mp_player_intcelebrationmale@wank")
    lib.playAnim(cache.ped, "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    Citizen.Wait(1500)
    ClearPedTasks(cache.ped)

    local roll = math.random(1, 12)

    local haveMask = CheckMask()

    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = "dice",
        message = "You rolled a " .. roll,
        isImage = false,
        mask = haveMask,
    })
end, false)

-- RegisterCommand(Config.Commands['rps'].name, function(source, args, rawCommand)
--     lib.requestAnimDict("anim@mp_player_intcelebrationmale@wank")
--     lib.playAnim(cache.ped, "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
--     Citizen.Wait(1500)
--     ClearPedTasks(cache.ped)

--     local hands = {"rock", "paper", "scissors"}
--     local hand = hands[math.random(1, #hands)]

--     local haveMask = CheckMask()

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "rps",
--         message = "You played " .. hand,
--         isImage = false,
--         mask = haveMask,
--         hand = hand,
--     })
-- end, false)

-- RegisterCommand(Config.Commands['img'].name, function(source, args, rawCommand)
--     if not Config.ImageSettings.status then
--         return
--     end

--     if #args < 1 then
--         return
--     end

--     local imageUrl = args[1]
--     if not imageUrl or imageUrl:len() == 0 then
--         return
--     end

--     local haveMask = CheckMask()

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "img",
--         message = imageUrl,
--         isImage = true,
--         mask = haveMask,
--     })
-- end, false)

-- RegisterCommand(Config.Commands['playsong'].name, function(source, args, rawCommand)
--     if not Config.MusicSettings.status then
--         return
--     end

--     if #args < 1 then
--         return
--     end

--     local songUrl = args[1]
--     if not songUrl or songUrl:len() == 0 then
--         return
--     end

--     SendVueMessage("PLAY_SONG", {
--         url = songUrl,
--     })
-- end, false)

-- RegisterCommand(Config.Commands['police'].name, function(source, args, rawCommand)
--     local text = ""
--     for _, v in ipairs(args) do
--         text = text .. " " .. v
--     end

--     if text:len() == 0 then
--         return
--     end

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "police",
--         message = text,
--         isImage = false,
--         mask = false,
--     })
-- end, false)

-- RegisterCommand(Config.Commands['ambulance'].name, function(source, args, rawCommand)
--     local text = ""
--     for _, v in ipairs(args) do
--         text = text .. " " .. v
--     end

--     if text:len() == 0 then
--         return
--     end

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "ambulance",
--         message = text,
--         isImage = false,
--         mask = false,
--     })
-- end, false)

-- RegisterCommand('ballas', function(source, args, rawCommand)
--     local text = ""
--     for _, v in ipairs(args) do
--         text = text .. " " .. v
--     end

--     if text:len() == 0 then
--         return
--     end

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "ballas",
--         message = text,
--         isImage = false,
--         mask = false,
--     })
-- end, false)

-- RegisterCommand('vagos', function(source, args, rawCommand)
--     local text = ""
--     for _, v in ipairs(args) do
--         text = text .. " " .. v
--     end

--     if text:len() == 0 then
--         return
--     end

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "vagos",
--         message = text,
--         isImage = false,
--         mask = false,
--     })
-- end, false)

-- RegisterCommand('tweet', function(source, args, rawCommand)
--     local text = ""
--     for _, v in ipairs(args) do
--         text = text .. " " .. v
--     end

--     if text:len() == 0 then
--         return
--     end

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "tweet",
--         message = text,
--         isImage = false,
--         mask = false,
--     })
-- end, false)

-- RegisterCommand('yellowpage', function(source, args, rawCommand)
--     local text = ""
--     for _, v in ipairs(args) do
--         text = text .. " " .. v
--     end

--     if text:len() == 0 then
--         return
--     end

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "yellowpages",
--         message = text,
--         isImage = false,
--         mask = false,
--     })
-- end, false)

-- RegisterCommand('charinfo', function(source, args, rawCommand)
--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "charinfo",
--         isImage = false,
--         mask = false,
--     })
-- end, false)

-- local lastReportTime = 0
-- local REPORT_COOLDOWN = 30 * 1000 -- 30 saniye (ms)

-- RegisterCommand('report', function(source, args, rawCommand)
--     local currentTime = GetGameTimer()

--     if currentTime - lastReportTime < REPORT_COOLDOWN then
--         local remaining = math.ceil((REPORT_COOLDOWN - (currentTime - lastReportTime)) / 1000)

--         TriggerEvent('Agency:Notify:Send', {
--             title = 'REPORT',
--             text = 'Bu komutu tekrar kullanmak için '..remaining..' saniye beklemelisin.',
--             type = 'error',
--             duration = 5000
--         })
--         return
--     end

--     local text = table.concat(args, " ")
--     if text:len() == 0 then return end

--     lastReportTime = currentTime

--     TriggerServerEvent('0r-chatv3:server:sendMessage', {
--         category = "report",
--         message = text,
--         isImage = false,
--         mask = false,
--     })
-- end, false)

local lastReportTime = 0
local REPORT_COOLDOWN = 30 * 1000 -- 30 saniye

RegisterCommand('report', function(source, args, rawCommand)
    local currentTime = GetGameTimer()

    -- (Cooldown)
    if currentTime - lastReportTime < REPORT_COOLDOWN then
        local remaining = math.ceil((REPORT_COOLDOWN - (currentTime - lastReportTime)) / 1000)

        TriggerEvent('Agency:Notify:Send', {
            title = 'REPORT',
            text = 'Bu komutu tekrar kullanmak için '..remaining..' saniye beklemelisin.',
            type = 'error',
            duration = 5000
        })
        return
    end

    local text = table.concat(args, " ")
    if text:len() == 0 then return end

    lastReportTime = currentTime

    -- (server-side ekleniyor)
    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = "report",
        message = text,
        isImage = false,
        mask = false,
    })
end, false)




RegisterCommand('reportreply', function(source, args, rawCommand)
    if #args < 2 then
        return
    end

    local text = ""
    for i = 2, #args do
        text = text .. " " .. args[i]
    end

    if text:len() == 0 then
        return
    end

    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = "reportreply",
        message = text,
        isImage = false,
        mask = false,
        targetPlayer = tonumber(args[1]),
    })
end, false)

RegisterCommand(Config.Commands['clear'].name, function(source, args, rawCommand)
    SendVueMessage("CLEAR_CHAT", {})
end, false)

TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['me'].name, Config.Commands['me'].description, {{ name = "text" }})
TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['do'].name, Config.Commands['do'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['ooc'].name, Config.Commands['ooc'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['pm'].name, Config.Commands['pm'].description, {{ name = "playerId" },{ name = "text" }})
TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['admin'].name, Config.Commands['admin'].description, {{ name = "text" }})
TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['announce'].name, Config.Commands['announce'].description, {{ name = "text" }})
TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['dice'].name, Config.Commands['dice'].description, {})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['rps'].name, Config.Commands['rps'].description, {})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['img'].name, Config.Commands['img'].description, {{ name = "url" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['playsong'].name, Config.Commands['playsong'].description, {{ name = "url" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['police'].name, Config.Commands['police'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['ambulance'].name, Config.Commands['ambulance'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['ballas'].name, Config.Commands['ballas'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['vagos'].name, Config.Commands['vagos'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['tweet'].name, Config.Commands['tweet'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['yellowpage'].name, Config.Commands['yellowpage'].description, {{ name = "text" }})
-- TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['charinfo'].name, Config.Commands['charinfo'].description, {})
TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['report'].name, Config.Commands['report'].description, {{ name = "text" }})
TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['reportreply'].name, Config.Commands['reportreply'].description, {{ name = "playerId" },{ name = "text" }})
TriggerEvent('0r-chatv3:client:selfCommandSuggestion', Config.Commands['clear'].name, Config.Commands['clear'].description, {})