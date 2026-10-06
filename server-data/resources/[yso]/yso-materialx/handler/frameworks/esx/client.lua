local M = {}

local ESX = nil

CreateThread(function()
    while not ESX do
        local ok, obj = pcall(function()
            return exports["es_extended"]:getSharedObject()
        end)

        if ok and obj then
            ESX = obj
            break
        end

        Wait(100)
    end
end)

function M.TriggerCallback(name, cb, ...)
    local args = { ... }

    if not ESX then
        CreateThread(function()
            while not ESX do Wait(50) end
            ESX.TriggerServerCallback(name, cb, table.unpack(args))
        end)
        return
    end

    ESX.TriggerServerCallback(name, cb, table.unpack(args))
end

function M.GetPlayerData()
    if not ESX then return nil end

    local data = ESX.GetPlayerData()
    if not data then return nil end
    
    local normalized = {}

    normalized.money = {
        cash = data.money or 0,
        bank = 0
    }

    if data.accounts then
        for _, acc in ipairs(data.accounts) do
            if acc.name == "bank" then
                normalized.money.bank = acc.money or 0
            elseif acc.name == "money" then
                normalized.money.cash = acc.money or normalized.money.cash
            end
        end
    end

    normalized.charinfo = {
        firstname = data.firstName or data.firstname or "Unknown",
        lastname = data.lastName or data.lastname or ""
    }

    normalized.job = data.job

    return normalized
end


function M.GetCharName()
    return GetPlayerName(PlayerId())
end

function M.OnPlayerLoaded(cb)
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded', function(...)
        cb(...)
    end)

    CreateThread(function()
        while not ESX do Wait(100) end
        local pdata = ESX.GetPlayerData()

        if pdata and (pdata.identifier or pdata.job) then
            cb()
        end
    end)
end

function M.OnPlayerUnload(cb)
    RegisterNetEvent('esx:onPlayerLogout')
    AddEventHandler('esx:onPlayerLogout', function(...)
        cb(...)
    end)
end

function M.SetVehicleProperties(vehicle, props)
    if ESX and ESX.Game and ESX.Game.SetVehicleProperties then
        ESX.Game.SetVehicleProperties(vehicle, props)
    end
end

function M.Notify(msg, type)
    ESX.ShowNotification(msg)
end

function M.GetVehicleProperties(vehicle)
    if ESX and ESX.Game and ESX.Game.GetVehicleProperties then
        return ESX.Game.GetVehicleProperties(vehicle)
    end
    return nil
end


return M
