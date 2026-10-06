-- Bridge System for FiveM
-- Automatically detects ESX, QBCore, Qbox or Standalone

Bridge = {}
Bridge.Framework = nil
Bridge.FrameworkObject = nil
Bridge.FrameworkExport = nil
Bridge.Ready = false
Bridge.UserTable = nil -- Set automatically based on framework (users for ESX, players for QBCore/Qbox)
Bridge.IdentifierColumn = nil -- Set automatically (identifier for ESX, citizenid for QBCore/Qbox)
Bridge.VehiclesTable = nil -- Set automatically (owned_vehicles for ESX, player_vehicles for QBCore/Qbox)
Bridge.VehiclesOwnerColumn = nil -- Set automatically (owner for ESX, citizenid for QBCore/Qbox)

-- Queue for callbacks waiting for framework initialization
local readyCallbacks = {}

-- Framework Detection
local function DetectFramework()

    -- ESX Detection
    if GetResourceState('es_extended') == 'started' then
        local success, err = pcall(function()
            ESX = exports['es_extended']:getSharedObject()
            Bridge.FrameworkObject = ESX
            Bridge.FrameworkExport = exports.es_extended
        end)
        if success and Bridge.FrameworkObject then
            Bridge.Framework = 'esx'
            Bridge.UserTable = 'users'
            Bridge.IdentifierColumn = 'identifier'
            Bridge.VehiclesTable = 'owned_vehicles'
            Bridge.VehiclesOwnerColumn = 'owner'
            print('^2[Bridge]^7 ESX Framework detected')
            return true
        end
    end

    if GetResourceState('qb-core') == 'started' then
        local success, err = pcall(function()
            QBCore = exports['qb-core']:GetCoreObject()
            Bridge.FrameworkObject = QBCore
            Bridge.FrameworkExport = exports['qb-core']
        end)
        if success and Bridge.FrameworkObject then
            Bridge.Framework = 'qbcore'
            Bridge.UserTable = 'players'
            Bridge.IdentifierColumn = 'citizenid'
            Bridge.VehiclesTable = 'player_vehicles'
            Bridge.VehiclesOwnerColumn = 'citizenid'
            print('^2[Bridge]^7 QBCore / QBOX Framework detected')
            return true
        end
    end

    -- Standalone (no framework)
    Bridge.Framework = 'standalone'
    Bridge.UserTable = 'users'
    Bridge.IdentifierColumn = 'identifier'
    Bridge.VehiclesTable = 'owned_vehicles'
    Bridge.VehiclesOwnerColumn = 'owner'
    print('^3[Bridge]^7 No framework detected - Standalone mode')
    print('^1[Bridge WARNING]^7 You are running in standalone mode!')
    print('^1[Bridge WARNING]^7 Please configure your database tables in bridge/main.lua:')
    print('^1[Bridge WARNING]^7   - Bridge.UserTable (default: "users")')
    print('^1[Bridge WARNING]^7   - Bridge.IdentifierColumn (default: "identifier")')
    print('^1[Bridge WARNING]^7   - Bridge.VehiclesTable (default: "owned_vehicles")')
    print('^1[Bridge WARNING]^7   - Bridge.VehiclesOwnerColumn (default: "owner")')
    print('^1[Bridge WARNING]^7 Remove this warning once you have configured your tables.')
    return true
end

-- Initialization
CreateThread(function()
    while not DetectFramework() do
        Wait(500)
    end

    -- Framework detected - set Ready flag
    Bridge.Ready = true

    -- Execute all waiting callbacks
    for i = 1, #readyCallbacks do
        local success, err = pcall(readyCallbacks[i])
        if not success then
            print('^1[Bridge]^7 Error executing ready callback: ' .. tostring(err))
        end
    end

    -- Clear the callback queue
    readyCallbacks = {}

    print('^2[Bridge]^7 Successfully initialized!')
end)

-- Utility function to check framework
function Bridge.IsFramework(framework)
    return Bridge.Framework == framework
end

function Bridge.GetFramework()
    return Bridge.Framework
end

function Bridge.GetFrameworkObject()
    return Bridge.FrameworkObject
end

-- Wait for framework initialization (async)
function Bridge.Await(callback)
    if Bridge.Ready then
        -- Framework already initialized - execute callback immediately
        callback()
    else
        -- Add callback to queue
        table.insert(readyCallbacks, callback)
    end
end

-- Synchronous wait (for simple access)
function Bridge.WaitForReady()
    while not Bridge.Ready do
        Wait(100)
    end
end
