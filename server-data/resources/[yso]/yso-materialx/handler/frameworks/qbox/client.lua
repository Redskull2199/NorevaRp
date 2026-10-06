local M = {}
local qbxReady = false

CreateThread(function()
    while true do
        if exports.qbx_core and lib and lib.callback then
            qbxReady = true
            break
        end
        Wait(100)
    end
end)

function M.TriggerCallback(name, cb, ...)
    local args = { ... }

    CreateThread(function()
        while not qbxReady do Wait(50) end

        local result = lib.callback.await(name, false, table.unpack(args))
        cb(result)
    end)
end


function M.GetPlayerData()
    if not qbxReady then return nil end
    return exports.qbx_core:GetPlayerData()
end

function M.GetCharName()
    local data = M.GetPlayerData()
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
        while not qbxReady do Wait(100) end

        if LocalPlayer and LocalPlayer.state and LocalPlayer.state.isLoggedIn then
            cb()
        end
    end)
end

function M.OnPlayerUnload(cb)
    RegisterNetEvent('QBCore:Client:OnPlayerUnload')
    AddEventHandler('QBCore:Client:OnPlayerUnload', cb)
end

function M.SetVehicleProperties(vehicle, props)
    if lib and lib.setVehicleProperties then
        lib.setVehicleProperties(vehicle, props)
    end
end

function M.GetVehicleProperties(vehicle)
    if lib and lib.getVehicleProperties then
        return lib.getVehicleProperties(vehicle)
    end

    return nil
end

function M.Notify(msg, type)
    if lib then
        lib.notify({
            description = msg,
            type = type or "inform"
        })
    end
end

return M
