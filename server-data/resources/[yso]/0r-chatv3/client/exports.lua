exports('addMessage', function(message)
    while not ConfigLoaded do
        Wait(0)
    end

    TriggerServerEvent('0r-chatv3:server:sendMessage', {
        category = 'custom',
        message = message,
        isImage = false,
        mask = false,
    })
end)