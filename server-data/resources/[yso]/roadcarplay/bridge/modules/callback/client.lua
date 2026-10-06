-- Client Callback Module

Bridge = Bridge or {}
Bridge.Callback = {}

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

-- Trigger a server callback
function Bridge.TriggerCallback(name, callback, ...)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        ESX.TriggerServerCallback(name, callback, ...)
    elseif Bridge.Framework == 'qbcore' then
        QBCore.Functions.TriggerCallback(name, callback, ...)
    elseif Bridge.Framework == 'qbox' then
        lib.callback(name, false, callback, ...)
    elseif Bridge.Framework == 'standalone' then
        -- Standalone Callback System
        local requestId = 'callback_' .. math.random(100000, 999999) .. '_' .. GetGameTimer()
        local eventName = 'bridge:callback:response:' .. requestId
        local eventHandler = nil

        RegisterNetEvent(eventName)
        eventHandler = AddEventHandler(eventName, function(...)
            callback(...)
            -- Cleanup event handler after use
            if eventHandler then
                RemoveEventHandler(eventHandler)
            end
        end)

        TriggerServerEvent('bridge:callback:' .. name, requestId, ...)
    end
end