local M = {}

function M.GetPlayer(src)
    return exports.qbx_core:GetPlayer(src)
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
    if lib then
        TriggerClientEvent('ox_lib:notify', src, {
            description = msg,
            type = type or "inform"
        })
    end
end

function M.RegisterCommand(name, desc, args, cb, perm)
    if lib then
        if type(cb) == "boolean" and type(perm) == "function" then
            cb, perm = perm, cb
        end

        if type(cb) ~= "function" then
            print("^1[QBOX ADAPTER]^0 RegisterCommand cb is not function for:", name)
            return
        end

        lib.addCommand(name, {
            help = desc,
            restricted = perm or false,
        }, function(source, args2)
            cb(source, args2)
        end)
    end
end


function M.RegisterCallback(name, cb)
    if not lib or not lib.callback then return end

    lib.callback.register(name, function(source, ...)
        local p = promise.new()

        cb(source, function(data)
            p:resolve(data)
        end, ...)

        return Citizen.Await(p)
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
    if exports.qbx_core and exports.qbx_core.GetPlayerByCitizenId then
        return exports.qbx_core:GetPlayerByCitizenId(cid)
    end
end

function M.HasPermission(src, perm)
    if not perm then return false end
    if type(perm) == "boolean" then return perm end

    if exports.qbx_core and exports.qbx_core.HasPermission then
        return exports.qbx_core:HasPermission(src, perm) == true
    end

    return IsPlayerAceAllowed(src, perm) == true
end

function M.RegisterUsableItem(item, cb)
    if exports.ox_inventory then
        exports.ox_inventory:RegisterUsableItem(item, function(source, itemData)
            cb(source, itemData)
        end)
    end
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
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false end
    return Player.Functions.GetItemByName(item).count >= amount
end

function M.GetGarageVehicles(source, garageType, vehType)
    local Player = M.GetPlayer(source)
    if not Player then return {} end

    local cid = Player.PlayerData and Player.PlayerData.citizenid or Player.citizenid
    if not cid then return {} end

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
    local Player = M.GetPlayer(source)
    if not Player then return nil end

    local cid = Player.PlayerData and Player.PlayerData.citizenid or Player.citizenid
    if not cid then return { error = "access" } end

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

        local money = 0

        if Player.Functions and Player.Functions.GetMoney then
            money = Player.Functions.GetMoney('bank')
        elseif Player.money and Player.money.bank then
            money = Player.money.bank
        end

        if money < price then
            return { error = "money", price = price }
        end

        if Player.Functions and Player.Functions.RemoveMoney then
            Player.Functions.RemoveMoney('bank', price)
        elseif exports.qbx_core then
            exports.qbx_core:RemoveMoney(source, 'bank', price)
        end
    end

    MySQL.update.await(
        'UPDATE player_vehicles SET state = 0 WHERE plate = ?',
        { plate }
    )

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
    local Player = M.GetPlayer(source)
    if not Player then return false end

    local cid = Player.PlayerData and Player.PlayerData.citizenid or Player.citizenid
    if not cid then return false end

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
    local Player = exports.qbx_core:GetPlayer(source)
    if not Player then return false end

    exports.oxmysql:execute([[
        INSERT INTO player_vehicles
        (citizenid, vehicle, hash, mods, plate, garage, state, type)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
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
    local Player = M.GetPlayer(source)
    if not Player then return false end
    Player.Functions.AddItem(itemName, itemCount)
end

function M.RemoveItem(source, itemName, itemCount)
    local Player = M.GetPlayer(source)
    if not Player then return false end
    Player.Functions.RemoveItem(itemName, itemCount)
end

function M.ClearInventory(source)
    local Player = M.GetPlayer(source)
    if not Player then return false end
    Player.Functions.ClearInventory(source)
end

function M.GetCurrentWeapon(source)
    return exports.ox_inventory:GetCurrentWeapon(source)
end

function M.SetWeaponDurability(source, slot, durability)
    return exports.ox_inventory:SetDurability(source, slot, durability)
end

function M.GetInventoryItems(source)
    local Player = exports.qbx_core:GetPlayer(source)
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
