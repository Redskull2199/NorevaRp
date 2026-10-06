local M = {}

local QBCore = exports['qb-core']:GetCoreObject()

function M.GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

function M.GetMetaData(src, key)
    local p = M.GetPlayer(src)
    return p and p.PlayerData.metadata[key]
end

function M.SetMetaData(src, key, value)
    local p = M.GetPlayer(src)
    if p then
        p.Functions.SetMetaData(key, value)
    end
end

function M.AddMoney(src, account, amount)
    if amount <= 0 then return end
    local p = M.GetPlayer(src)
    if p then
        p.Functions.AddMoney(account, amount)
    end
end

function M.RemoveMoney(src, account, amount)
    if amount <= 0 then return end
    local p = M.GetPlayer(src)
    if p then
        p.Functions.RemoveMoney(account, amount)
    end
end

function M.GetMoney(src, account)
    local p = M.GetPlayer(src)
    if not p then return 0 end

    local money = p.PlayerData.money
    return money and money[account] or 0
end

function M.GetJob(src)
    local p = M.GetPlayer(src)
    return p and p.PlayerData.job
end

function M.GetGang(src)
    local p = M.GetPlayer(src)
    return p and p.PlayerData.gang
end

function M.Notify(src, msg, type)
    TriggerClientEvent('QBCore:Notify', src, msg, type or "primary")
end

function M.RegisterCommand(name, desc, args, cb, perm)
    if type(cb) == "boolean" and type(perm) == "function" then
        cb, perm = perm, cb
    end

    if type(cb) ~= "function" then
        print(("^1[QB ADAPTER]^0 RegisterCommand cb is not function for: %s"):format(name))
        return
    end

    if perm == true then
        perm = "user"
    elseif perm == false then
        perm = nil 
    elseif perm == nil then
        perm = nil
    end

    QBCore.Commands.Add(name, desc, args, false, cb, perm)
end

function M.RegisterCallback(name, cb)
    QBCore.Functions.CreateCallback(name, function(source, qbCb, ...)
        local p = promise.new()

        cb(source, function(data)
            p:resolve(data)
        end, ...)

        qbCb(Citizen.Await(p))
    end)
end


function M.GetIdentifier(src, idType)
    return GetPlayerIdentifierByType(src, idType)
end

function M.GetCharId(src)
    local p = M.GetPlayer(src)
    return p and p.PlayerData and p.PlayerData.citizenid
end

function M.GetPlayerByCharId(cid)
    return QBCore.Functions.GetPlayerByCitizenId(cid)
end

function M.HasPermission(src, perm)
    if not perm then return false end
    if type(perm) == "boolean" then return perm end
    return QBCore.Functions.HasPermission(src, perm) == true
end

function M.RegisterUsableItem(item, cb)
    QBCore.Functions.CreateUseableItem(item, function(source, itemData)
        cb(source, itemData)
    end)
end

function M.GetCharInfo(src)
    local p = M.GetPlayer(src)
    if not p or not p.PlayerData or not p.PlayerData.charinfo then return nil end

    local c = p.PlayerData.charinfo

    return {
        firstname = c.firstname or "Unknown",
        lastname = c.lastname or "",
        fullname = (c.firstname or "Unknown") .. " " .. (c.lastname or ""),
        gender = c.gender == 0 and "Male" or "Female",
        birthdate = c.birthdate or "Unknown",
        nationality = c.nationality or "Unknown"
    }
end

function M.HasItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    return QBCore.Functions.HasItem(source, item, amount)
end

function M.GetGarageVehicles(source, garageType, vehType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end

    local cid = Player.PlayerData.citizenid
    local state = garageType == 'garage' and 1 or 0

    local result = MySQL.query.await(
        'SELECT * FROM player_vehicles WHERE citizenid = ? AND state = ? AND type = ?',
        { cid, state, vehType }
    )

    local vehicles = {}

    for _, v in ipairs(result or {}) do
        table.insert(vehicles, {
            model = v.vehicle,
            plate = v.plate,
            mods = json.decode(v.mods or '{}'),
            fuel = v.fuel or 100,
            engine = v.engine or 1000,
            body = v.body or 1000,
            type = v.type,
            state = v.state
        })
    end

    return vehicles
end

function M.TakeOutVehicle(source, plate, garageType)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return nil end

    local cid = Player.PlayerData.citizenid
    local result = MySQL.query.await(
        'SELECT * FROM player_vehicles WHERE plate = ? AND citizenid = ?',
        { plate, cid }
    )

    if not result or not result[1] then
        return { error = "access" }
    end

    local veh = result[1]

    if garageType == 'garage' and veh.state ~= 1 then
        return { error = "blocked" }
    end

    if garageType == 'impound' and veh.state ~= 0 then
        return { error = "blocked" }
    end

    if garageType == 'impound' then
        local price = Config.ImpoundPrice or 1000
        if not Player.Functions.RemoveMoney('bank', price) then
            return { error = "money", price = price }
        end
    end

    MySQL.update.await('UPDATE player_vehicles SET state = 0 WHERE plate = ?', { plate })

    return {
        vehicle = {
            model = veh.vehicle,
            plate = veh.plate,
            mods = json.decode(veh.mods or '{}'),
            fuel = veh.fuel,
            engine = veh.engine,
            body = veh.body,
            type = veh.type
        },
        message = garageType == 'impound' and Config.GetLocale('impound_paid_success') or nil
    }
end

function M.SaveVehicle(source, plate, props, netId)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    local cid = Player.PlayerData.citizenid
    plate = plate:match("^%s*(.-)%s*$")

    local result = MySQL.query.await(
        'SELECT 1 FROM player_vehicles WHERE plate = ? AND citizenid = ?',
        { plate, cid }
    )

    if not result or not result[1] then return false end

    MySQL.update.await(
        'UPDATE player_vehicles SET mods = ?, fuel = ?, engine = ?, body = ?, state = 1 WHERE plate = ?',
        {
            json.encode(props),
            props.fuelLevel or 100,
            props.engineHealth or 1000,
            props.bodyHealth or 1000,
            plate
        }
    )

    return true
end

function M.SaveVehicleForce(plate, props)
    plate = plate:match("^%s*(.-)%s*$")

    MySQL.update(
        'UPDATE player_vehicles SET mods = ?, fuel = ?, engine = ?, body = ? WHERE plate = ?',
        {
            json.encode(props),
            props.fuelLevel or 100,
            props.engineHealth or 1000,
            props.bodyHealth or 1000,
            plate
        }
    )
end

function M.RegisterVehicle(source, props, model, type)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    exports.oxmysql:execute([[
        INSERT INTO player_vehicles
        (license, citizenid, vehicle, hash, mods, plate, garage, state, type)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        Player.PlayerData.license,
        Player.PlayerData.citizenid,
        model,
        GetHashKey(model),
        json.encode(props),
        props.plate,
        '',
        0,
        type
    })

    return true
end

function M.AddItem(source, itemName, itemCount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    Player.Functions.AddItem(itemName, itemCount)
end

function M.RemoveItem(source, itemName, itemCount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    Player.Functions.RemoveItem(itemName, itemCount)
end

function M.ClearInventory(source)
    local Player = M.GetPlayer(source)
    if not Player then return false end
    if GetResourceState("qb-inventory") == "started" then
        exports["qb-inventory"]:ClearInventory(source)
    else
        print("[QB][INVENTORY CLEAR] Inventory not found please check this file: handler/frameworks/qb/server.lua")
    end
end

function M.GetCurrentWeapon(source)
    return nil
end

function M.SetWeaponDurability(source, slot, durability)
    return true
end

function M.GetInventoryItems(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return {} end

    local items = {}

    for slot, item in pairs(Player.PlayerData.items or {}) do
        if item and item.amount and item.amount > 0 then
            table.insert(items, {
                name = item.name,
                count = item.amount,
                slot = slot
            })
        end
    end

    return items
end


return M
