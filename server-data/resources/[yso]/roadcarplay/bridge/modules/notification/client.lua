-- Client Notification Module

Bridge = Bridge or {}
Bridge.Notification = {}

-- Helper: Ensure framework is ready
local function EnsureFrameworkReady()
    if Bridge.EnsureReady then
        Bridge.EnsureReady()
    elseif not Bridge.Ready then
        while not Bridge.Framework do
            Wait(100)
        end
    end
end

-- Show notification to player
function Bridge.Notification.Show(text, type, duration)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        ESX.ShowNotification(text)
    elseif Bridge.Framework == 'qbcore' then
        QBCore.Functions.Notify(text, type or 'primary', duration or 5000)
    elseif Bridge.Framework == 'qbox' then
        exports.qbx_core:Notify(text, type or 'inform', duration or 5000)
    else
        -- Standalone fallback - simple notification
        SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(text)
        DrawNotification(false, true)
    end
end

-- Show advanced notification with title and message
function Bridge.Notification.ShowAdvanced(title, message, type, duration)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        ESX.ShowNotification(title .. ': ' .. message)
    elseif Bridge.Framework == 'qbcore' then
        QBCore.Functions.Notify(message, type or 'primary', duration or 5000)
    elseif Bridge.Framework == 'qbox' then
        exports.qbx_core:Notify({
            title = title,
            description = message,
            type = type or 'inform',
            duration = duration or 5000
        })
    else
        -- Standalone fallback
        SetNotificationTextEntry('STRING')
        AddTextComponentSubstringPlayerName(title .. ': ' .. message)
        DrawNotification(false, true)
    end
end

-- Show help notification (bottom left corner)
function Bridge.Notification.ShowHelp(message, duration)
    AddTextEntry('BridgeHelpNotification', message)
    BeginTextCommandDisplayHelp('BridgeHelpNotification')
    EndTextCommandDisplayHelp(0, false, true, duration or -1)
end
