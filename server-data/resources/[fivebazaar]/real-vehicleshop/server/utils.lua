function RegisterCallback(name, cbFunc, data)
    while not frameworkObject do
        Citizen.Wait(0)
    end
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        frameworkObject.RegisterServerCallback(name, function(source, cb, data)
            cbFunc(source, cb, data)
        end)
    else
        frameworkObject.Functions.CreateCallback(name, function(source, cb, data)
            cbFunc(source, cb, data)
        end)
    end
end

function ExecuteSql(query, parameters)
    local IsBusy = true
    local result = nil
    if Config.MySQL == "oxmysql" then
        if parameters then
            exports.oxmysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        end

    elseif Config.MySQL == "ghmattimysql" then
        if parameters then
            exports.ghmattimysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.ghmattimysql:execute(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.MySQL == "mysql-async" then
        if parameters then
            MySQL.Async.fetchAll(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.Async.fetchAll(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

function GetPlayerMoneyOnline(source, type)
    if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        local Player = frameworkObject.Functions.GetPlayer(tonumber(source))
        if type == 'bank' then
            return tonumber(Player.PlayerData.money.bank)
        elseif type == 'cash' then
            return tonumber(Player.PlayerData.money.cash)
        end
    elseif Config.Framework == 'newesx' or Config.Framework == 'oldesx' then
        local Player = frameworkObject.GetPlayerFromId(tonumber(source))
        if type == 'bank' then
            return tonumber(Player.getAccount('bank').money)
        elseif type == 'cash' then
            return tonumber(Player.getMoney())
        end
    end
end

function RemoveAddBankMoneyOnline(type, amount, id)
    if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        local Player = frameworkObject.Functions.GetPlayer(id)
        if type == 'add' then
            Player.Functions.AddMoney('bank', tonumber(amount))
        elseif type == 'remove' then
            Player.Functions.RemoveMoney('bank', tonumber(amount))
        end
    else
        local Player = frameworkObject.GetPlayerFromId(id)
        if type == 'add' then
            Player.addAccountMoney('bank', tonumber(amount))
        elseif type == 'remove' then
            Player.removeAccountMoney('bank', tonumber(amount))
        end
    end
end

function RemoveAddCash(type, amount, id)
    if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        local Player = frameworkObject.Functions.GetPlayer(tonumber(id))
        if Player then
            if type == 'add' then
                Player.Functions.AddMoney('cash', tonumber(amount))
            elseif type == 'remove' then
                Player.Functions.RemoveMoney('cash', tonumber(amount))
            end
        end
    else
        local Player = frameworkObject.GetPlayerFromId(tonumber(id))
        if Player then
            if type == 'add' then
                Player.addMoney(tonumber(amount))
            elseif type == 'remove' then
                Player.RemoveMoney(tonumber(amount))
            end
        end
    end
end

function AddBankMoneyOffline(identifier, payment)
    if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        local result = ExecuteSql("SELECT money FROM players WHERE citizenid = '"..identifier.."'")
        local targetMoney = json.decode(result[1].money)
        targetMoney.bank = targetMoney.bank + payment
        ExecuteSql("UPDATE players SET money = '"..json.encode(targetMoney).."' WHERE citizenid = '"..identifier.."'")
    else
        local result = ExecuteSql("SELECT accounts FROM users WHERE identifier = '"..identifier.."'")
        local targetMoney = json.decode(result[1].accounts)
        targetMoney.bank = targetMoney.bank + payment
        ExecuteSql("UPDATE users SET accounts = '"..json.encode(targetMoney).."' WHERE identifier = '"..identifier.."'")
    end
end

function GetOfflinePlayerLicenseQBCore(identifier)
    local result = ExecuteSql("SELECT `license` FROM `players` WHERE `citizenid` = '"..identifier.."'")
    if #result > 0 then
        local license = result[1].license
        return license
    end
end

function GetName(source)
    if Config.Framework == "esx" or Config.Framework == "oldesx" then
        local Player = frameworkObject.GetPlayerFromId(tonumber(source))
        if Player then
            return Player.getName()
        else
            return "0"
        end
    else
        local Player = frameworkObject.Functions.GetPlayer(tonumber(source))
        if Player then
            return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        else
            return "0"
        end
    end
end

function GetOfflinePlayerName(identifier)
    if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        local result = ExecuteSql("SELECT charinfo FROM players WHERE citizenid = '"..identifier.."'")
        local charinfo = json.decode(result[1].charinfo)
        return charinfo.firstname .. ' ' .. charinfo.lastname
    else
        local result = ExecuteSql("SELECT firstname, lastname FROM users WHERE identifier = '"..identifier.."'")
        local firstname = result[1].firstname
        local lastname = result[1].lastname
        return firstname .. ' ' .. lastname
    end
end

function GetIdentifier(source)
    if Config.Framework == "esx" or Config.Framework == "oldesx" then
        local xPlayer = frameworkObject.GetPlayerFromId(tonumber(source))
        if xPlayer then
            return xPlayer.getIdentifier()
        else
            return "0"
        end
    else
        local Player = frameworkObject.Functions.GetPlayer(tonumber(source))
        if Player then
            return Player.PlayerData.citizenid
        else
            return "0"
        end
    end
end

------------------------------ Start ------------------------------
function StartScript()
    for k, v in pairs(Config.Vehicleshops) do
        local result = ExecuteSql("SELECT * FROM `real_vehicleshop` WHERE id = '"..k.."'")
        local Information = {
            Owner = "",
            Name = v.CompanyName,
            Money = v.CompanyMoney,
            Rating = 0,
            Discount = 0,
        }
        if next(result) == nil and #result == 0 then
            ExecuteSql("INSERT INTO `real_vehicleshop` (id, information, vehicles, categories, feedbacks, complaints, preorders, employees, soldvehicles, transactions, perms) VALUES (@id, @information, @vehicles, @categories, @feedbacks, @complaints, @preorders, @employees, @soldvehicles, @transactions, @perms)", {
                ['@id'] = k,
                ['@information'] = json.encode(Information),
                ['@vehicles'] = json.encode(Config.BeginningVehicles[v.Type]),
                ['@categories'] = json.encode(Config.Categories[v.Type]),
                ['@feedbacks'] = json.encode(v.Feedbacks),
                ['@complaints'] = json.encode(v.Complaints),
                ['@preorders'] = json.encode(v.Preorders),
                ['@employees'] = json.encode(v.Employees),
                ['@soldvehicles'] = json.encode(v.SoldVehicles),
                ['@transactions'] = json.encode(v.Transactions),
                ['@perms'] = json.encode(Config.DefaultPerms)
            })
        end
        LoadData()
    end
end

function RequestNewData()
    local source = source
    LoadData()
    TriggerClientEvent('real-vehicleshop:Update', source, Config.Vehicleshops)
end

RegisterNetEvent('real-vehicleshop:RequestData', RequestNewData)

function LoadData()
    local result = ExecuteSql("SELECT * FROM `real_vehicleshop`")
    for k, v in ipairs(result) do
        local information = json.decode(v.information)
        Config.Vehicleshops[k].Owner = information.Owner
        Config.Vehicleshops[k].CompanyName = information.Name
        Config.Vehicleshops[k].CompanyMoney = information.Money
        Config.Vehicleshops[k].Rating = information.Rating
        Config.Vehicleshops[k].Discount = information.Discount
        Config.Vehicleshops[k].Vehicles = json.decode(v.vehicles)
        Config.Vehicleshops[k].Categories = json.decode(v.categories)
        Config.Vehicleshops[k].Feedbacks = json.decode(v.feedbacks)
        Config.Vehicleshops[k].Complaints = json.decode(v.complaints)
        Config.Vehicleshops[k].Preorders = json.decode(v.preorders)
        Config.Vehicleshops[k].Employees = json.decode(v.employees)
        Config.Vehicleshops[k].SoldVehicles = json.decode(v.soldvehicles)
        Config.Vehicleshops[k].Transactions = json.decode(v.transactions)
        Config.Vehicleshops[k].Perms = json.decode(v.perms)
    end
end

Citizen.CreateThread(StartScript)