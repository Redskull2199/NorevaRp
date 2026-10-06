local M = {}

local ESX = nil
local pendingCallbacks = {}
local pendingCommands = {}

local function initESX()
    if ESX then return true end

    local ok, obj = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)

    if ok and obj then
        ESX = obj
        print("^2[ESX ADAPTER]^0 ESX ready")

        for _, data in ipairs(pendingCallbacks) do
            ESX.RegisterServerCallback(data.name, data.cb)
        end

        for _, data in ipairs(pendingCommands) do
            ESX.RegisterCommand(
                data.name,
                data.perm or "user",
                function(xPlayer, args2)
                    data.cb(xPlayer.source, args2)
                end,
                true,
                { help = data.desc }
            )
        end

        pendingCallbacks = {}
        pendingCommands = {}

        return true
    end

    return false
end

CreateThread(function()
    while not initESX() do
        Wait(100)
    end
end)

function M.GetPlayer(src)
    return ESX and ESX.GetPlayerFromId(src)
end

function M.GetMetaData(src, key)
    local p = M.GetPlayer(src)
    if not p then return nil end

    local val = p.getMeta(key)
    if val == 1 then return true end
    if val == 0 then return false end
    return val
end

function M.SetMetaData(src, key, value)
    local p = M.GetPlayer(src)
    if not p then
        return
    end

    if type(value) == "boolean" then
        value = value and 1 or 0
    elseif type(value) ~= "number" and type(value) ~= "string" and type(value) ~= "table" then
        value = tostring(value)
    end

    p.setMeta(key, value)
end

function M.AddMoney(src, account, amount)
    if amount <= 0 then return end
    local p = M.GetPlayer(src)
    if account == "cash" then
        account = "money"
    end
    if p then
        p.addAccountMoney(account, amount)
    end
end

function M.RemoveMoney(src, account, amount)
    if amount <= 0 then return end
    local p = M.GetPlayer(src)
    if account == "cash" then
        account = "money"
    end
    if p then
        p.removeAccountMoney(account, amount)
    end
end

function M.GetMoney(src, account)
    local p = M.GetPlayer(src)
    if not p then return 0 end

    if account == "cash" then
        account = "money"
    end

    local acc = p.getAccount(account)
    return acc and acc.money or 0
end


function M.GetJob(src)
    local p = M.GetPlayer(src)
    return p and p.job
end

function M.GetGang(src)
    return nil
end

function M.Notify(src, msg, type)
    TriggerClientEvent('esx:showNotification', src, msg)
end


function M.RegisterCommand(name, desc, args, cb, perm)
    RegisterCommand(name, function(source, rawArgs, raw)
        if perm and perm ~= "user" then
            local xPlayer = ESX.GetPlayerFromId(source)
            if not xPlayer then return end

            local group = xPlayer.getGroup()
            if group ~= perm then
                TriggerClientEvent('esx:showNotification', source, "No Access.")
                return
            end
        end

        cb(source, rawArgs)
    end, false)
end


function M.RegisterCallback(name, cb)
    if not ESX then
        table.insert(pendingCallbacks, { name = name, cb = cb })
        return
    end
    ESX.RegisterServerCallback(name, cb)
end

function M.GetIdentifier(src, idType)
    return GetPlayerIdentifierByType(src, idType)
end

function M.GetCharId(src)
    local p = M.GetPlayer(src)
    return p and p.identifier
end

function M.GetPlayerByCharId(identifier)
    for _, player in pairs(ESX.GetExtendedPlayers()) do
        if player.identifier == identifier then
            return player
        end
    end
end

function M.HasPermission(src, perm)
    if not perm then return false end
    if type(perm) == "boolean" then return perm end

    local xPlayer = M.GetPlayer(src)
    if not xPlayer then return false end

    local group = xPlayer.getGroup and xPlayer.getGroup() or "user"

    if type(perm) == "table" then
        for _, p in ipairs(perm) do
            if group == p then return true end
        end
        return false
    end

    return group == perm
end

function M.RegisterUsableItem(item, cb)
    ESX.RegisterUsableItem(item, function(source, itemData)
        cb(source, itemData)
    end)
end

function M.GetCharInfo(src)
    local xPlayer = M.GetPlayer(src)
    if not xPlayer then return nil end

    local name = xPlayer.getName() or "Unknown"
    local sex = xPlayer.get('sex')
    local dob = xPlayer.get('dateofbirth')

    return {
        firstname = name,
        lastname = "",
        fullname = name,
        gender = sex == "m" and "Male" or "Female",
        birthdate = dob or "Unknown",
        nationality = "Unknown"
    }
end

function M.HasItem(source, item, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    local invItem = xPlayer.getInventoryItem(item)
    return invItem and invItem.count >= amount
end


function M.GetGarageVehicles(source, garageType, vehType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end

    local owner = xPlayer.identifier
    local stored = garageType == 'garage' and 1 or 0

    local result = MySQL.query.await(
        'SELECT * FROM owned_vehicles WHERE owner = ? AND stored = ? AND type = ?',
        { owner, stored, vehType }
    )

    local vehicles = {}

    for _, v in ipairs(result or {}) do
        local props = json.decode(v.vehicle or '{}')

        table.insert(vehicles, {
            model = props.model,
            plate = v.plate,
            mods = props,
            fuel = props.fuelLevel or 100,
            engine = props.engineHealth or 1000,
            body = props.bodyHealth or 1000,
            type = v.type,
            state = v.stored
        })
    end

    return vehicles
end


function M.TakeOutVehicle(source, plate, garageType)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local owner = xPlayer.identifier

    local result = MySQL.query.await(
        'SELECT * FROM owned_vehicles WHERE plate = ? AND owner = ?',
        { plate, owner }
    )

    if not result or not result[1] then
        return { error = "access" }
    end

    local veh = result[1]

    if garageType == 'garage' and veh.stored ~= 1 then
        return { error = "blocked" }
    end

    if garageType == 'impound' and veh.stored ~= 0 then
        return { error = "blocked" }
    end

    if garageType == 'impound' then
        local price = Config.ImpoundPrice or 1000
        if xPlayer.getAccount('bank').money < price then
            return { error = "money", price = price }
        end
        xPlayer.removeAccountMoney('bank', price)
    end

    MySQL.update.await('UPDATE owned_vehicles SET stored = 0 WHERE plate = ?', { plate })

    local props = json.decode(veh.vehicle or '{}')

    return {
        vehicle = {
            model = props.model,
            plate = plate,
            mods = props,
            fuel = props.fuelLevel or 100,
            engine = props.engineHealth or 1000,
            body = props.bodyHealth or 1000,
            type = veh.type
        },
        message = garageType == 'impound' and Config.GetLocale('impound_paid_success') or nil
    }
end


function M.SaveVehicle(source, plate, props, netId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    plate = plate:match("^%s*(.-)%s*$")

    local result = MySQL.query.await(
        'SELECT 1 FROM owned_vehicles WHERE plate = ? AND owner = ?',
        { plate, xPlayer.identifier }
    )

    if not result or not result[1] then return false end

    MySQL.update.await(
        'UPDATE owned_vehicles SET vehicle = ?, stored = 1 WHERE plate = ?',
        {
            json.encode(props),
            plate
        }
    )

    return true
end


function M.SaveVehicleForce(plate, props)
    plate = plate:match("^%s*(.-)%s*$")

    MySQL.update(
        'UPDATE owned_vehicles SET vehicle = ? WHERE plate = ?',
        {
            json.encode(props),
            plate
        }
    )
end

function M.RegisterVehicle(source, props, model, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    exports.oxmysql:execute([[
        INSERT INTO owned_vehicles
        (owner, plate, vehicle, type, stored)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        xPlayer.identifier,
        props.plate,
        json.encode(props),
        type or "car",
        1
    })

    return true
end

function M.AddItem(source, itemName, itemCount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if itemName:lower():find("^weapon_") then
        xPlayer.addWeapon(itemName, 250)
        return true
    end

    if xPlayer.canCarryItem(itemName, itemCount) then
        xPlayer.addInventoryItem(itemName, itemCount)
        return true
    else
        TriggerClientEvent('esx:showNotification', source, "Inventory is full.")
        return false
    end
end

function M.RemoveItem(source, itemName, itemCount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    if itemName:lower():find("^weapon_") then
        xPlayer.removeWeapon(itemName)
        return true
    end

    xPlayer.removeInventoryItem(itemName, itemCount)
    return true
end

function M.ClearInventory(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    for _, item in pairs(xPlayer.getInventory()) do
        if item.count and item.count > 0 then
            xPlayer.removeInventoryItem(item.name, item.count)
        end
    end

    local loadout = xPlayer.getLoadout()
    for _, weapon in pairs(loadout) do
        if weapon.name then
            xPlayer.removeWeapon(weapon.name)
        end
    end

    return true
end


function M.GetCurrentWeapon(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local weapon = xPlayer.getLoadout and xPlayer.getLoadout()[1]
    if weapon then
        return {
            name = weapon.name,
            slot = 1
        }
    end

    return nil
end

function M.SetWeaponDurability(source, slot, durability)
    return true
end

function M.GetInventoryItems(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return {} end

    local items = {}

    for slot, item in pairs(xPlayer.getInventory()) do
        if item.count and item.count > 0 then
            table.insert(items, {
                name = item.name,
                count = item.count,
                slot = slot
            })
        end
    end

    return items
end


return M
