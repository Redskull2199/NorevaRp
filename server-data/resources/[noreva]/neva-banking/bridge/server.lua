Bridge = {}
local Framework = Config.Framework

if Framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'esx' then
    ESX = exports["es_extended"]:getSharedObject()
elseif Framework == 'qbx' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Framework == 'vrp' then
    local Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
end

function Bridge.GetPlayer(source)
    if Framework == 'qb' or Framework == 'qbx' then
        return QBCore.Functions.GetPlayer(source)
    elseif Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    elseif Framework == 'vrp' then
        return vRP.getUserId({source})
    end
end

function Bridge.GetPlayerByIdentifier(identifier)
    if Framework == 'qb' or Framework == 'qbx' then
        return QBCore.Functions.GetPlayerByCitizenId(identifier)
    elseif Framework == 'esx' then
        return ESX.GetPlayerFromIdentifier(identifier)
    elseif Framework == 'vrp' then
        local src = vRP.getUserSource({tonumber(identifier)})
        return src
    end
end

function Bridge.GetIdentifier(source)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then return Player.PlayerData.citizenid end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then return Player.identifier end
    elseif Framework == 'vrp' then
        return tostring(vRP.getUserId({source}))
    end
    return nil
end

function Bridge.GetName(source)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then return Player.getName() end
    elseif Framework == 'vrp' then
        return "Citizen" 
    end
    return "Unknown"
end

function Bridge.GetBankMoney(source)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then return Player.PlayerData.money['bank'] end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then return Player.getAccount('bank').money end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then return vRP.getBankMoney({user_id}) end
    end
    return 0
end

function Bridge.GetCash(source)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then return Player.PlayerData.money['cash'] end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then return Player.getMoney() end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then return vRP.getMoney({user_id}) end
    end
    return 0
end

function Bridge.AddBankMoney(source, amount)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.AddMoney('bank', amount, 'bank-transaction') end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then Player.addAccountMoney('bank', amount) end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then 
            local current = vRP.getBankMoney({user_id})
            vRP.setBankMoney({user_id, current + amount}) 
        end
    end
end

function Bridge.RemoveBankMoney(source, amount)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.RemoveMoney('bank', amount, 'bank-transaction') end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then Player.removeAccountMoney('bank', amount) end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then 
            local current = vRP.getBankMoney({user_id})
            vRP.setBankMoney({user_id, current - amount}) 
        end
    end
end

function Bridge.AddCash(source, amount)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.AddMoney('cash', amount, 'bank-transaction') end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then Player.addMoney(amount) end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then vRP.giveMoney({user_id, amount}) end
    end
end

function Bridge.RemoveCash(source, amount)
    if Framework == 'qb' or Framework == 'qbx' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then Player.Functions.RemoveMoney('cash', amount, 'bank-transaction') end
    elseif Framework == 'esx' then
        local Player = ESX.GetPlayerFromId(source)
        if Player then Player.removeMoney(amount) end
    elseif Framework == 'vrp' then
        local user_id = vRP.getUserId({source})
        if user_id then vRP.tryPayment({user_id, amount}) end
    end
end

function Bridge.Notify(source, msg, type)
    if Framework == 'qb' or Framework == 'qbx' then
        TriggerClientEvent('QBCore:Notify', source, msg, type)
    elseif Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', source, msg)
    elseif Framework == 'vrp' then
        TriggerClientEvent("chatMessage", source, "[Bank]", {255, 0, 0}, msg)
    end
end

local serverCallbacks = {}

function Bridge.RegisterCallback(name, cb)
    serverCallbacks[name] = cb
end

RegisterNetEvent('neva-banking:server:triggerCallback', function(name, id, ...)
    local src = source
    if serverCallbacks[name] then
        serverCallbacks[name](src, function(...)
            TriggerClientEvent('neva-banking:client:callbackResponse', src, id, ...)
        end, ...)
    end
end)
