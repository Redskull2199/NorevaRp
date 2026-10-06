local fwObj
if cfg?.framework then
    framework = cfg.framework:lower()
else
    local esx = GetResourceState('es_extended'):find('start')
    local qbcore = GetResourceState('qb-core'):find('start')
    if esx then
        framework = 'esx'
    elseif qbcore then
        framework = 'qb'
    end
end

CreateThread(function()
    local c = 0
    while not fwObj and c < 1000 do
        c = c + 1
        if framework == 'esx' then
            pcall(function() fwObj = exports['es_extended']:getSharedObject() end)
            if not fwObj then
                TriggerEvent('esx:getSharedObject', function(obj) fwObj = obj end)
            end
            if fwObj then
                ESX = fwObj
                break
            end
        elseif framework == 'qb' or framework == 'qbcore' then
            pcall(function() fwObj = exports['qb-core']:GetCoreObject() end)
            if not fwObj then
                pcall(function() fwObj = exports['qb-core']:GetSharedObject() end)
            end
            if not fwObj then
                TriggerEvent('QBCore:GetObject', function(obj) fwObj = obj end)
            end
            if fwObj then
                QBCore = fwObj
                break
            end
        end
        Wait(0)
    end
end)

if not IsDuplicityVersion() then --client
    izzy.notification = function(type, str, length)
        if ESX then
            ESX.ShowNotification(str, type, length)
        elseif QBCore then
            QBCore.Functions.Notify(str, type, length)
        else
            SetNotificationTextEntry('STRING')
            AddTextComponentSubstringPlayerName(str)
            DrawNotification(0, 1)
        end
    end

else                             --server

    local manifestFile = LoadResourceFile(GetCurrentResourceName(), 'fxmanifest.lua')
    local loadSqlFuncs = manifestFile:find('/lib/MySQL.lua') and true or false
    if loadSqlFuncs then
        izzy.sql = {}
        izzy.sql.async = {}
        izzy.sql.sync = {}
        if GetResourceState('oxmysql') == 'started' then
            CreateThread(function()
                while not MySQL do
                    Wait(1)
                end

                izzy.sql.sync.query = MySQL.query.await
                izzy.sql.sync.insert = MySQL.insert.await
                izzy.sql.sync.update = MySQL.update.await
                -- izzy.sql.sync.single = MySQL.single.await
                izzy.sql.sync.scalar = MySQL.scalar.await

                izzy.sql.async.query = MySQL.query
                izzy.sql.async.insert = MySQL.insert
                izzy.sql.async.update = MySQL.update
                -- izzy.sql.async.single = MySQL.single
                izzy.sql.async.scalar = MySQL.scalar
            end)
        elseif GetResourceState('mysql-async') == 'started' then
            CreateThread(function()
                while not MySQL do
                    Wait(1)
                end
                MySQL.ready(function()
                    izzy.sql.sync.query = MySQL.Sync.fetchAll
                    izzy.sql.sync.insert = MySQL.Sync.insert
                    izzy.sql.sync.update = MySQL.Sync.execute
                    -- izzy.sql.sync.single = MySQL.Sync.single
                    izzy.sql.sync.scalar = MySQL.Sync.fetchScalar

                    izzy.sql.async.query = MySQL.Async.fetchAll
                    izzy.sql.async.insert = MySQL.Async.insert
                    izzy.sql.async.update = MySQL.Async.execute
                    -- izzy.sql.async.single = MySQL.Async.single
                    izzy.sql.async.scalar = MySQL.Async.fetchScalar
                end)
            end)
        end
    end
end
