-- Variables
QBCore = exports['qb-core']:GetCoreObject()

PlayerData = {}
PlayerJob = {}

local function RefreshPlayerData()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = PlayerData.job or { name = 'unemployed', type = 'none', onduty = false, grade = { level = 0 } }
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    RefreshPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    RefreshPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    PlayerJob = job
    PlayerData.job = job
end)

RegisterNetEvent('QBCore:Client:OnDutyUpdate', function(state)
    if PlayerJob then PlayerJob.onduty = state end
    if PlayerData.job then PlayerData.job.onduty = state end
end)

RegisterNetEvent('QBCore:Client:OnUnload', function()
    PlayerData = {}
    PlayerJob = {}
end)
