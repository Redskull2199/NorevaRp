RegisterNetEvent('chat:show', function()
    if not ConfigLoaded then return end

    SetNuiFocus(true, true)
    SendVueMessage('SHOW_CHAT', {})
    TriggerServerEvent('0r-chatv3:server:writingText', true)
end)


RegisterNetEvent("chat:addSuggestion")
AddEventHandler("chat:addSuggestion", function(commandName, commandDescription, commandParams)
    local suggestion = {
        name = string.gsub(commandName, "/", ""),
        help = commandDescription,
        params = commandParams
    }

    SendVueMessage("ADD_SUGGESTION", suggestion)
end)

RegisterNetEvent("chat:addSuggestions")
AddEventHandler("chat:addSuggestions", function(suggestions)
    for k, v in ipairs(suggestions) do
        local suggestion = {
            name = string.gsub(v.name, "/", ""),
            help = v.help,
            params = v.params
        }

        SendVueMessage("ADD_SUGGESTION", suggestion)
    end
end)

RegisterNetEvent('chat:removeSuggestion')
AddEventHandler('chat:removeSuggestion', function(commandName)
    SendVueMessage("REMOVE_SUGGESTION", commandName)
end)

RegisterNetEvent('chat:clear')
AddEventHandler('chat:clear', function()
    SendVueMessage("CLEAR_CHAT", {})
end)

RegisterNetEvent('__cfx_internal:serverPrint')
AddEventHandler('__cfx_internal:serverPrint', function(msg)
    print(msg)
end)

ChatTemplates = {}

local function FormatTemplate(template, args)
    local formatted = template
    for i, arg in ipairs(args) do
        formatted = string.gsub(formatted, "{" .. (i - 1) .. "}", tostring(arg))
    end
    return formatted
end

RegisterNetEvent('chat:addTemplate')
AddEventHandler('chat:addTemplate', function(templateId, templateString)
    ChatTemplates[templateId] = templateString
    SendVueMessage("ADD_TEMPLATE", {
        id = templateId,
        template = templateString
    })
end)

RegisterNetEvent('chat:addMessage')
AddEventHandler('chat:addMessage', function(data)
    if not data then return end

    -- Eğer message yoksa ama args varsa, args'ı birleştirerek mesaj oluştur
    local message = data.message
    if not message and data.args and #data.args > 0 then
        message = table.concat(data.args, " ")
    end

    -- Color parametresini RGB formatına çevir
    local color = nil
    if data.color and type(data.color) == "table" and #data.color >= 3 then
        color = string.format("rgb(%d, %d, %d)", data.color[1], data.color[2], data.color[3])
    end

    local messageData = {
        message = message or "",
        category = data.category or "custom",
        fullname = data.fullname or "",
        isImage = data.isImage or false,
        multiline = data.multiline or false,
        templateId = data.templateId,
        templateArgs = data.args or {},
        color = color
    }

    if data.templateId and ChatTemplates[data.templateId] then
        local template = ChatTemplates[data.templateId]
        messageData.message = FormatTemplate(template, data.args or {})
        messageData.isTemplate = true
        messageData.templateId = nil
        messageData.templateArgs = nil
    end
    SendVueMessage("SEND_MESSAGE", messageData)
end)

-- Exports
exports('addMessage', function(data)
    if type(data) == "string" then
        data = { message = data }
    end

    TriggerEvent('chat:addMessage', data)
end)

exports('addSuggestion', function(commandName, commandDescription, commandParams)
    TriggerEvent('chat:addSuggestion', commandName, commandDescription, commandParams)
end)