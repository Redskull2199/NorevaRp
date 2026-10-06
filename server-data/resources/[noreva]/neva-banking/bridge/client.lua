Bridge = {}
local Framework = Config.Framework

if Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Framework == 'qbx' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'vrp' then
    Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
end

function Bridge.Notify(msg, type)
    if Framework == 'qb' or Framework == 'qbx' then
        QBCore.Functions.Notify(msg, type)
    elseif Framework == 'esx' then
        ESX.ShowNotification(msg)
    elseif Framework == 'vrp' then
        TriggerEvent("chatMessage", "[Bank]", {255, 0, 0}, msg)
    end
end

function Bridge.GetPlayerData()
    if Framework == 'qb' or Framework == 'qbx' then
        return QBCore.Functions.GetPlayerData()
    elseif Framework == 'esx' then
        return ESX.GetPlayerData()
    elseif Framework == 'vrp' then
        return {}
    end
end
local callbacks = {}
local callbackId = 0

function Bridge.TriggerCallback(name, cb, ...)
    callbackId = callbackId + 1
    callbacks[callbackId] = cb
    TriggerServerEvent('neva-banking:server:triggerCallback', name, callbackId, ...)
end

RegisterNetEvent('neva-banking:client:callbackResponse', function(id, ...)
    if callbacks[id] then
        callbacks[id](...)
        callbacks[id] = nil
    end
end)

