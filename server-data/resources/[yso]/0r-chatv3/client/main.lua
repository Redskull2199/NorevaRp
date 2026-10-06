local Config = require "config.config"

NuiLoaded = false
ConfigLoaded = false
WritingEffect = false
WritingPlayers = {}
ActiveSong = {}
RPTexts = {}
RPTextThread = false
ThreadType = 'dui'
Dots = ""


local function GetWebLocales()
    local path = 'locales/' .. Config.Locale .. '.json'
    local file = LoadResourceFile(GetCurrentResourceName(), path)

    if not file then
        file = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
        print(('Locale file "%s" not found, falling back to default "en".'):format(Config.Locale))
        return {}
    end

    if not file or file == '' then
        error('Locale file is empty or not found')
        return {}
    end

    local success, content = pcall(json.decode, file)

	if not success then
        error(('Failed to decode JSON from locale file: %s'):format(content))
        return {}
    end

    if not content['Web'] then
        error('Missing "Web" section in locale file')
        return {}
    end

    return content['Web']
end

--- CheckNui()
--- @return nil
--- @description This function checks if the NUI is loaded. It waits until the NUI is loaded before proceeding with the rest of the code.
local function CheckNui()
    while not NuiLoaded do
        Wait(100)
    end
end

--- NuiMessage()
--- @param action string - The action to perform in the NUI.
--- @param payload table - The data to send to the NUI.
--- @return nil
--- @description This function sends a message to the NUI with the specified action and payload. It checks if the NUI is loaded before sending the message.
function SendVueMessage(action, payload)
    CheckNui()
    SendNUIMessage({
        action = action,
        payload = payload
    })
end

--- FetchNui()
--- @return nil
--- @description This function checks if the NUI is loaded. It sends a message to the NUI to check its status and waits until it is loaded.
local function FetchNui()
    while not NuiLoaded do
        if NetworkIsSessionStarted() then
            SendNUIMessage({
                action = "CHECK_NUI",
            })
        end
        Wait(2000)
    end

    SendVueMessage("SET_CONFIG", {
        Themes = Config.Themes,
        ThemeColors = Config.ThemeColors,
        MessageColors = Config.MessageColors,
        Categories = Config.Categories,
        QuickCommands = Config.QuickCommands,
        AllowedURLs = Config.ImageSettings.allowedURLs,
        EmojiMenu = Config.EmojiMenu,
        Emojis = Config.Emojis,
        Locales = GetWebLocales(),
        HideAllNames = Config.HideAllNames,
        UsingCommandsWithoutSlashes = Config.UsingCommandsWithoutSlashes,
        KeyPressedSounds = Config.KeyPressedSounds,
    })
end

--- DrawDots()
--- @param coords vector3 - The coordinates where the dots should be drawn.
--- @param text string - The text to display at the specified coordinates.
--- @return nil
--- @description This function draws text at the specified coordinates in the game world. It calculates the scale based on the
function DrawDots(coords, text)
    local defaultScale = 0.65
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = 200 / (GetGameplayCamFov() * dist)
    -- Format the text
    SetTextColour(255, 255, 255, 255)
    SetTextFont(0)
    SetTextScale(0.0, defaultScale * scale)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)
    -- Diplay the text
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

--- DrawText3D()
--- @param x number - The X coordinate of the text.
--- @param y number - The Y coordinate of the text.
--- @param z number - The Z coordinate of the text.
--- @param text string - The text to display.
--- @param color table - The color of the text, in the format {r, g, b, a}.
--- @return nil
--- @description This function draws 3D text at the specified coordinates in the game world.
function DrawText3D(x, y, z, text, color)
    local camCoords = GetGameplayCamCoord()
    local dist = #(vector3(x, y, z) - camCoords)

    -- Experimental math to scale the text down
    local scale = 200 / (GetGameplayCamFov() * dist)

    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextScale(0.0, 0.5 * scale)
    SetTextFont(4)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)

    -- Diplay the text
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

--- CheckRPIsDiff()
--- @param source number - The source of the RP text.
--- @param text string - The text to check.
--- @param type string - The type of the RP text.
--- @param x number - The X coordinate of the RP text.
--- @param y number - The Y coordinate of the RP text.
--- @return boolean
--- @description This function checks if the RP text is different from the old text, type, and coordinates. It returns true if there is a difference, otherwise false.
function CheckRPIsDiff(source, text, type, x, y)
    for k, v in ipairs(RPTexts) do
        if v.source == source then
            if v.oldText ~= text or
                v.oldType ~= type or
                v.oldScreenX ~= x or
                v.oldScreenY ~= y
            then
                return true
            end
        end
    end
    return false
end

--- UpdateRPTexts()
--- @param source number - The source of the RP text.
--- @param data table - The data to update the RP text with.
--- @return nil
--- @description This function updates the RP text for a specific source. If the source already exists
function UpdateRPTexts(source, data)
    for k, v in ipairs(RPTexts) do
        if v.source == source then
            RPTexts[k] = data
            return
        end
    end
    table.insert(RPTexts, data)
end

--- CheckMask()
--- @return boolean
--- @description This function checks if the player has a mask equipped. It returns true if the
function CheckMask()
    if Config.AnonymousWithMask then
        local ped = cache.ped
        local pedModel = GetEntityModel(cache.ped)

        if not Config.MaskIndexs[pedModel] then
            return false
        end

        local currentMaskIndex = GetPedDrawableVariation(ped, 1)

        if Config.AnyMask then
            if currentMaskIndex > 0 then
                return true
            else
                return false
            end
        else
            if Config.MaskIndexs[pedModel][tostring(currentMaskIndex)] then
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

RegisterNetEvent('0r-chatv3:client:onPlayerLoaded', function ()
    Wait(1500)
    FetchNui()
end)

RegisterNetEvent('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1500)
        FetchNui()
    end
end)

RegisterKeyMapping("+chat", "Show chat", "KEYBOARD", Config.ShowChatKey or "T")
RegisterCommand("+chat", function()
    TriggerEvent("chat:show")
end, false)

RegisterNetEvent('0r-chatv3:client:sendMessage', function(data)
    if data then
        if data.isImage then
            SendVueMessage('SEND_MESSAGE', data)
        else
            SendVueMessage('SEND_MESSAGE', data)

            if (data.category == 'do' or data.category == 'me' or data.category == 'ooc' or data.category == 'dice' or data.category == 'rps') then
                if ThreadType == 'dui' then
                    UpdateRPTexts(data.source, data)
                    RPTextsDUIThread()
                    Wait(5000)
                    for k, v in ipairs(RPTexts) do
                        if v.source == data.source and v.category == data.category and v.message == data.message then
                            table.remove(RPTexts, k)
                            SendVueMessage("REMOVE_3D_TEXT", {
                                source = v.source,
                            })
                            break
                        end
                    end
                else
                    UpdateRPTexts(data.source, data)
                    RPTexts3DThread()
                    Wait(5000)
                    for k, v in ipairs(RPTexts) do
                        if v.source == data.source and v.category == data.category and v.message == data.message then
                            table.remove(RPTexts, k)
                            break
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('0r-chatv3:client:writingText', function(source, isWriting)
    if isWriting then
        WritingPlayers[tostring(source)] = true
        if not WritingEffect then
            FWritingEffect()
        end
    else
        WritingPlayers[tostring(source)] = nil
    end
end)

RegisterNetEvent('0r-chatv3:client:selfCommandSuggestion', function(command, help, params)
    TriggerEvent('chat:addSuggestion', command, help, params)

    SendVueMessage("ADD_CHAT_COMMAND_SUGGESTION", {
        command = string.gsub(command, "/", ""),
        description = help,
        params = params or {}
    })
end)