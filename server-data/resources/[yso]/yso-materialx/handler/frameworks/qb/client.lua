local M = {}
local QBCore = nil

CreateThread(function()
    while not QBCore do
        local ok, core = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)

        if ok and core then
            QBCore = core
            break
        end

        Wait(100)
    end
end)

function M.TriggerCallback(name, cb, ...)
    local args = { ... }

    CreateThread(function()
        while not QBCore do Wait(50) end

        QBCore.Functions.TriggerCallback(name, function(result)
            cb(result)
        end, table.unpack(args))
    end)
end


function M.GetPlayerData()
    if not QBCore then return nil end
    return QBCore.Functions.GetPlayerData()
end

function M.GetCharName()
    if not QBCore then return "Unknown" end

    local data = QBCore.Functions.GetPlayerData()
    if not data or not data.charinfo then return "Unknown" end

    return ("%s %s"):format(
        data.charinfo.firstname or "",
        data.charinfo.lastname or ""
    )
end

function M.OnPlayerLoaded(cb)
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
    AddEventHandler('QBCore:Client:OnPlayerLoaded', cb)

    CreateThread(function()
        while not QBCore do Wait(100) end

        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.isLoggedIn then
            cb()
        end
    end)
end

function M.OnPlayerUnload(cb)
    RegisterNetEvent('QBCore:Client:OnPlayerUnload')
    AddEventHandler('QBCore:Client:OnPlayerUnload', cb)
end

function M.GetVehicleProperties(vehicle)
    return QBCore.Functions.GetVehicleProperties(vehicle)
end

function M.SetVehicleProperties(vehicle, props)
    QBCore.Functions.SetVehicleProperties(vehicle, props)
end

function M.Notify(msg, type)
    QBCore.Functions.Notify(msg, type or "primary")
end

return M
