FrameworkHandler = FrameworkHandler or {}

local currentFramework = nil
local adapter = nil
local handlerReady = false

local pendingCallbacks = {}
local pendingCommands = {}
local pendingTriggers = {}
local pendingPlayerLoaded = {}
local pendingPlayerUnload = {}

local function isStarted(res)
    return GetResourceState(res) == "started"
end

local function detectFramework()
    if isStarted("qbx_core") then
        return "qbox"
    end

    if isStarted("qb-core") then
        return "qb"
    end

    if isStarted("es_extended") then
        return "esx"
    end

    return nil
end

local function loadAdapter(framework)
    local side = IsDuplicityVersion() and "server" or "client"
    local path = ("handler/frameworks/%s/%s.lua"):format(framework, side)

    local chunk = LoadResourceFile(GetCurrentResourceName(), path)
    if not chunk then
        print("^1[FrameworkHandler]^0 Failed to load: " .. path)
        return nil
    end

    local fn, err = load(chunk, path)
    if not fn then
        print("^1[FrameworkHandler]^0 Lua error: " .. err)
        return nil
    end

    return fn()
end

CreateThread(function()
    currentFramework = detectFramework()

    if not currentFramework then
        print("^1[FrameworkHandler]^0 No supported framework found.")
        return
    end

    adapter = loadAdapter(currentFramework)

    if not adapter then
        print("^1[FrameworkHandler]^0 Adapter load failed.")
        return
    end

    handlerReady = true

    if adapter.RegisterCallback then
        for _, data in ipairs(pendingCallbacks) do
            adapter.RegisterCallback(data.name, data.cb)
        end
    end

    if adapter.RegisterCommand then
        for _, data in ipairs(pendingCommands) do
            adapter.RegisterCommand(data.name, data.desc, data.args, data.cb, data.perm)
        end
    end

    if adapter.TriggerCallback then
        for _, data in ipairs(pendingTriggers) do
            adapter.TriggerCallback(data.name, data.cb, table.unpack(data.args))
        end
    end

    if adapter.OnPlayerLoaded then
        for _, cb in ipairs(pendingPlayerLoaded) do
            adapter.OnPlayerLoaded(cb)
        end
    end
    
    if adapter.OnPlayerUnload then
        for _, cb in ipairs(pendingPlayerUnload) do
            adapter.OnPlayerUnload(cb)
        end
    end
    
    pendingPlayerLoaded = {}
    pendingPlayerUnload = {}
    pendingCallbacks = {}
    pendingCommands = {}
    pendingTriggers = {}

    print(("^2[FrameworkHandler]^0 Loaded: %s (%s)"):format(
        currentFramework,
        IsDuplicityVersion() and "server" or "client"
    ))
end)

local function getAdapter()
    return adapter
end

function FrameworkHandler.TriggerCallback(name, cb, ...)
    local a = getAdapter()

    if not handlerReady or not a then
        table.insert(pendingTriggers, {
            name = name,
            cb = cb,
            args = { ... }
        })
        return
    end

    if not a.TriggerCallback then return end
    return a.TriggerCallback(name, cb, ...)
end

function FrameworkHandler.RegisterCallback(name, cb)
    local a = getAdapter()

    if not handlerReady or not a then
        table.insert(pendingCallbacks, { name = name, cb = cb })
        return
    end

    if not a.RegisterCallback then return end
    return a.RegisterCallback(name, cb)
end

function FrameworkHandler.RegisterCommand(name, desc, args, cb, perm)
    local a = getAdapter()

    if not handlerReady or not a then
        table.insert(pendingCommands, {
            name = name,
            desc = desc,
            args = args,
            cb = cb,
            perm = perm
        })
        return
    end

    if not a.RegisterCommand then return end
    return a.RegisterCommand(name, desc, args, cb, perm)
end

function FrameworkHandler.OnPlayerLoaded(cb)
    local a = getAdapter()

    if not handlerReady or not a then
        table.insert(pendingPlayerLoaded, cb)
        return
    end

    if not a.OnPlayerLoaded then return end
    a.OnPlayerLoaded(cb)
end

function FrameworkHandler.OnPlayerUnload(cb)
    local a = getAdapter()

    if not handlerReady or not a then
        table.insert(pendingPlayerUnload, cb)
        return
    end

    if not a.OnPlayerUnload then return end
    a.OnPlayerUnload(cb)
end


function FrameworkHandler.GetPlayerData()
    local a = getAdapter()
    return a and a.GetPlayerData and a.GetPlayerData()
end

function FrameworkHandler.GetCharName()
    local a = getAdapter()
    return a and a.GetCharName and a.GetCharName() or "Unknown"
end

function FrameworkHandler.GetPlayer(source)
    local a = getAdapter()
    return a and a.GetPlayer and a.GetPlayer(source)
end

function FrameworkHandler.GetMetaData(source, key)
    local a = getAdapter()
    return a and a.GetMetaData and a.GetMetaData(source, key)
end

function FrameworkHandler.SetMetaData(source, key, value)
    local a = getAdapter()
    return a and a.SetMetaData and a.SetMetaData(source, key, value)
end

function FrameworkHandler.AddMoney(source, account, amount)
    local a = getAdapter()
    return a and a.AddMoney and a.AddMoney(source, account, amount)
end

function FrameworkHandler.RemoveMoney(source, account, amount)
    local a = getAdapter()
    return a and a.RemoveMoney and a.RemoveMoney(source, account, amount)
end

function FrameworkHandler.GetMoney(source, account)
    local a = getAdapter()
    return a and a.GetMoney and a.GetMoney(source, account)
end

function FrameworkHandler.GetJob(source)
    local a = getAdapter()
    return a and a.GetJob and a.GetJob(source)
end

function FrameworkHandler.GetGang(source)
    local a = getAdapter()
    return a and a.GetGang and a.GetGang(source)
end

function FrameworkHandler.Notify(source, msg, type)
    local a = getAdapter()
    return a and a.Notify and a.Notify(source, msg, type)
end

function FrameworkHandler.GetIdentifier(source, idType)
    local a = getAdapter()
    return a and a.GetIdentifier and a.GetIdentifier(source, idType)
end

function FrameworkHandler.GetCharId(source)
    local a = getAdapter()
    return a and a.GetCharId and a.GetCharId(source)
end

function FrameworkHandler.GetPlayerByCharId(charid)
    local a = getAdapter()
    return a and a.GetPlayerByCharId and a.GetPlayerByCharId(charid)
end

function FrameworkHandler.HasPermission(source, perm)
    local a = getAdapter()
    return a and a.HasPermission and a.HasPermission(source, perm) or false
end

function FrameworkHandler.HasPermission(source, perm)
    local a = getAdapter()
    return a and a.HasPermission and a.HasPermission(source, perm) or false
end

function FrameworkHandler.RegisterUsableItem(item, cb)
    local a = getAdapter()
    if a and a.RegisterUsableItem then
        return a.RegisterUsableItem(item, cb)
    end
end

function FrameworkHandler.GetCharInfo(source)
    local a = getAdapter()
    if a and a.GetCharInfo then
        return a.GetCharInfo(source)
    end
    return nil
end

function FrameworkHandler.HasItem(source, item, amount)
    amount = amount or 1
    local a = getAdapter()

    if not a or not a.HasItem then
        print('[FrameworkHandler] Adapter HasItem not implemented')
        return false
    end

    return a.HasItem(source, item, amount)
end

function FrameworkHandler.GetVehicleProperties(vehicle)
    local a = adapter
    if not a or not a.GetVehicleProperties then
        print("^1[FrameworkHandler]^0 GetVehicleProperties not implemented.")
        return nil
    end
    return a.GetVehicleProperties(vehicle)
end


function FrameworkHandler.SetVehicleProperties(vehicle, props)
    local a = adapter
    if not a or not a.SetVehicleProperties then
        print("^1[FrameworkHandler]^0 SetVehicleProperties not implemented.")
        return
    end
    return a.SetVehicleProperties(vehicle, props)
end

function FrameworkHandler.GetGarageVehicles(source, garageType, vehType)
    local a = adapter
    return a and a.GetGarageVehicles and a.GetGarageVehicles(source, garageType, vehType) or {}
end

function FrameworkHandler.TakeOutVehicle(source, plate, garageType)
    local a = adapter
    return a and a.TakeOutVehicle and a.TakeOutVehicle(source, plate, garageType)
end

function FrameworkHandler.SaveVehicle(source, plate, props, netId)
    local a = adapter
    return a and a.SaveVehicle and a.SaveVehicle(source, plate, props, netId)
end

function FrameworkHandler.SaveVehicleForce(plate, props)
    local a = adapter
    return a and a.SaveVehicleForce and a.SaveVehicleForce(plate, props)
end

function FrameworkHandler.RegisterVehicle(source, vehicleProps, model, type)
    local a = adapter
    if not a or not a.RegisterVehicle then
        print("^1[FrameworkHandler]^0 RegisterVehicle not implemented.")
        return false
    end

    return a.RegisterVehicle(source, vehicleProps, model, type)
end

function FrameworkHandler.AddItem(source, item, amount)
    local a = adapter
    return a and a.AddItem and a.AddItem(source, item, amount)
end

function FrameworkHandler.RemoveItem(source, item, amount)
    local a = adapter
    return a and a.RemoveItem and a.RemoveItem(source, item, amount)
end

function FrameworkHandler.GetItem(source, item)
    local a = adapter
    return a and a.GetItem and a.GetItem(source, item)
end

function FrameworkHandler.ClearInventory(source)
    local a = adapter
    return a and a.ClearInventory and a.ClearInventory(source)
end

function FrameworkHandler.GetCurrentWeapon(source)
    local a = adapter
    return a and a.GetCurrentWeapon and a.GetCurrentWeapon(source)
end

function FrameworkHandler.SetWeaponDurability(source, slot, durability)
    local a = adapter
    return a and a.SetWeaponDurability and a.SetWeaponDurability(source, slot, durability)
end

function FrameworkHandler.GetInventoryItems(source)
    local a = adapter
    return a and a.GetInventoryItems and a.GetInventoryItems(source) or {}
end
