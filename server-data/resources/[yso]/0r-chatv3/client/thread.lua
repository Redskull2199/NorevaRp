local Config = require "config.config"

function RPTextsDUIThread()
    if RPTextThread then return end
    RPTextThread = true

    CreateThread(function()
        while #RPTexts >= 1 do
            for key, text in ipairs(RPTexts) do
                local _onScreen = false
                local playerPed = cache.ped
                local targetPed = GetPlayerPed(GetPlayerFromServerId(text.source))
                local playerPedCoords = GetEntityCoords(playerPed)
                local targetPedCoords = GetEntityCoords(targetPed)

                local distance = #(playerPedCoords - targetPedCoords)

                if distance < 25 then
                    local onScreen, screenX, screenY = GetHudScreenPositionFromWorldPosition(
                        targetPedCoords.x + 0.0,
                        targetPedCoords.y + 0.0,
                        targetPedCoords.z + 1.0
                    )

                    if CheckRPIsDiff(text.source, text.message, string.lower(text.category), screenX * 100, screenY * 100) then
                        _onScreen = true
                        SendVueMessage('SHOW_3D_TEXT', {
                            source = text.source,
                            player = text.fullname,
                            screenX = screenX * 100,
                            screenY = screenY * 100,
                            message = text.message,
                            category = text.category,
                            isDice = text.isDice,
                            isRPS = text.isRPS,
                            hand = text.hand or false,
                        })
                        RPTexts[key].oldScreenX = screenX * 100
                        RPTexts[key].oldScreenY = screenY * 100
                        RPTexts[key].oldText = text.message
                        RPTexts[key].oldType = text.category
                    end
                else
                    if not _onScreen then
                        SendVueMessage("REMOVE_3D_TEXT", {
                            source = RPText.source,
                        })
                    end
                end
            end
            Wait(1)
        end
        RPTextThread = false
    end)
end

function RPTexts3DThread()
    if RPText3DThread then return end
    RPText3DThread = true

    CreateThread(function()
        while #RPTexts >= 1 do
            for key, text in ipairs(RPTexts) do
                local playerPed = cache.ped
                local targetPed = GetPlayerPed(GetPlayerFromServerId(text.source))
                local playerPedCoords = GetEntityCoords(playerPed)
                local targetPedCoords = GetEntityCoords(targetPed)

                local distance = #(playerPedCoords - targetPedCoords)

                if distance < 25 then
                    local color = Config.DefaultSettings.drawtextColors[text.category] or {255, 255, 255, 255}
                    DrawText3D(
                        targetPedCoords.x,
                        targetPedCoords.y,
                        targetPedCoords.z,
                        text.message,
                        color
                    )
                end
            end
            Wait(1)
        end
        RPText3DThread = false
    end)
end

function FWritingEffect()
    if WritingEffect then return end
    WritingEffect = true
    CreateThread(function()
        while next(WritingPlayers) ~= nil do
            local sleep = 500
            local playerCoords = GetEntityCoords(cache.ped)
            for source, _ in pairs(WritingPlayers) do
                source = tonumber(source)
                local WriterId = GetPlayerFromServerId(source)
                if WriterId ~= -1 then
                    local WriterPed = GetPlayerPed(WriterId)
                    local WriterCoords = GetEntityCoords(WriterPed)
                    if #(playerCoords - WriterCoords) <= 6.0 then
                        sleep = 1
                        DrawDots(vec3(WriterCoords.x, WriterCoords.y, WriterCoords.z + 1.0), Dots)
                    end
                end
            end
            Wait(sleep)
        end
        WritingEffect = false
    end)
end


CreateThread(function()
    while true do
        Wait(1000)
        Dots = Dots .. " ."
        if string.len(Dots) > 6 then
            Dots = ""
        end
    end
end)