CreateThread(function()
    RegisterCallback('real-vehicleshop:GetVehicleshopData', function(source, cb, k)
        local src = source
        local ProfilePicture = GetDiscordAvatar(src)
        local PlayerName = GetName(src)
        local PlayerBank = GetPlayerMoneyOnline(src, 'bank')
        local Execute = {
            Name = PlayerName,
            Money = PlayerBank,
            Pfp = ProfilePicture
        }
        cb(Execute)
    end)

    RegisterCallback('real-vehicleshop:RemoveMoneyForTestDrive', function(source, cb)
        local src = source
        local PlayerBank = GetPlayerMoneyOnline(src, 'bank')
        if PlayerBank >= Config.TestDrivePrice then
            RemoveAddBankMoneyOnline('remove', Config.TestDrivePrice, src)
            cb(true)
        else
            cb(false)
        end
    end)

    RegisterCallback('real-vehicleshop:CheckPlateStatus', function(source, cb, plate)
        if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            local result = ExecuteSql("SELECT `plate` FROM `player_vehicles` WHERE `plate` = '"..plate.."'")
            if #result > 0 then
                cb(true)
            else
                cb(false)
            end
        else
            local result = ExecuteSql("SELECT `plate` FROM `owned_vehicles` WHERE `plate` = '"..plate.."'")
            if #result > 0 then
                cb(true)
            else
                cb(false)
            end
        end
    end)

    RegisterCallback('real-vehicleshop:BuyPlayerVehicle', function(source, cb, data)
        local src = source
        local PlayerBank = GetPlayerMoneyOnline(src, 'bank')
        local identifier = GetIdentifier(src)
        local vehicleprice = tonumber(data.price)
        if PlayerBank >= vehicleprice then
            if Config.Vehicleshops[data.id].Owner == "" then
                RemoveAddBankMoneyOnline('remove', vehicleprice, src)
                if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
                    local Player = frameworkObject.Functions.GetPlayer(src)
                    ExecuteSql("INSERT INTO `player_vehicles` (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage, @state)", {
                        ['@license'] = Player.PlayerData.license,
                        ['@citizenid'] = identifier,
                        ['@vehicle'] = data.model,
                        ['@hash'] = GetHashKey(data.props.model),
                        ['@mods'] = json.encode(data.props),
                        ['@plate'] = data.plate,
                        ['@garage'] = Config.DefaultGarage,
                        ['@state'] = 0
                    })
                    cb(true)
                else
                    ExecuteSql("INSERT INTO `owned_vehicles` (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)", {
                        ['@owner'] = identifier,
                        ['@plate'] = data.plate,
                        ['@vehicle'] = json.encode(data.props),
                    })
                    cb(true)
                end
            else
                local result = ExecuteSql("SELECT `information`, `vehicles` FROM `real_vehicleshop` WHERE `id` = '"..data.id.."'")
                if #result > 0 then
                    local information = json.decode(result[1].information)
                    local vehicles = json.decode(result[1].vehicles)
                    local Check = false
                    for k, v in ipairs(vehicles) do
                        if v.name == data.model then
                            if v.stock > 0 then
                                v.stock = v.stock - 1
                                Check = true
                                break
                            end
                        end
                    end
                    if Check then
                        if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
                            local Player = frameworkObject.Functions.GetPlayer(src)
                            ExecuteSql("INSERT INTO `player_vehicles` (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (@license, @citizenid, @vehicle, @hash, @mods, @plate, @garage, @state)", {
                                ['@license'] = Player.PlayerData.license,
                                ['@citizenid'] = identifier,
                                ['@vehicle'] = data.model,
                                ['@hash'] = GetHashKey(data.props.model),
                                ['@mods'] = json.encode(data.props),
                                ['@plate'] = data.plate,
                                ['@garage'] = Config.DefaultGarage,
                                ['@state'] = 0
                            })
                            cb(true)
                            AddSoldVehicles(GetName(src), data.id, data.model, vehicleprice)
                            TriggerClientEvent('real-vehicleshop:ShowFeedbackScreen', src, data.id)
                        else
                            ExecuteSql("INSERT INTO `owned_vehicles` (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)", {
                                ['@owner'] = identifier,
                                ['@plate'] = data.plate,
                                ['@vehicle'] = json.encode(data.props),
                            })
                            cb(true)
                            AddSoldVehicles(GetName(src), data.id, data.model, vehicleprice)
                            TriggerClientEvent('real-vehicleshop:ShowFeedbackScreen', src, data.id)
                        end
                        RemoveAddBankMoneyOnline('remove', vehicleprice, src)
                        information.Money = information.Money + vehicleprice
                        Config.Vehicleshops[data.id].CompanyMoney = Config.Vehicleshops[data.id].CompanyMoney + vehicleprice
                        Config.Vehicleshops[data.id].Vehicles = vehicles
                        ExecuteSql("UPDATE `real_vehicleshop` SET `information` = '"..json.encode(information).."', `vehicles` = '"..json.encode(vehicles).."' WHERE `id` = '"..data.id.."'")
                        TriggerClientEvent('real-vehicleshop:Update', -1, Config.Vehicleshops)
                    end
                end
            end
        else
            cb(false)
        end
    end)
end)

RegisterNetEvent('real-vehicleshop:TestDrive', function(started, netid)
    local src = source
    if started then
        local vehicle = NetworkGetEntityFromNetworkId(netid)
        SetPlayerRoutingBucket(src, src)
        SetEntityRoutingBucket(vehicle, src)
        SetRoutingBucketPopulationEnabled(src, false)
    else
        SetPlayerRoutingBucket(src, Config.BucketID)
        SetRoutingBucketPopulationEnabled(src, true)
    end
end)

RegisterNetEvent('real-vehicleshop:PreOrderVehicle', function(data, props)
    local src = source
    local result = ExecuteSql("SELECT `information`, `preorders` FROM `real_vehicleshop` WHERE `id` = '"..data.id.."'")
    local PlayerBank = GetPlayerMoneyOnline(src, 'bank')
    if #result > 0 then
        local vehicleprice = tonumber(data.price)
        if PlayerBank >= vehicleprice then
            local information = json.decode(result[1].information)
            local preorders = json.decode(result[1].preorders)
            RemoveAddBankMoneyOnline('remove', vehicleprice, src)
            table.insert(preorders, {
                identifier = GetIdentifier(src),
                requestor = GetName(src),
                vehiclehash = data.model,
                vehiclemodel = data.model,
                price = vehicleprice,
                props = props,
                plate = data.plate,
                expiretime = os.time() + (24 * 60 * 60)
            })
            information.Money = information.Money + vehicleprice
            Config.Vehicleshops[data.id].CompanyMoney = Config.Vehicleshops[data.id].CompanyMoney + vehicleprice
            Config.Vehicleshops[data.id].Preorders = preorders
            ExecuteSql("UPDATE `real_vehicleshop` SET `information` = '"..json.encode(information).."', `preorders` = '"..json.encode(preorders).."' WHERE `id` = '"..data.id.."'")
            TriggerClientEvent('real-vehicleshop:Update', -1, Config.Vehicleshops)
            TriggerClientEvent('real-vehicleshop:SendUINotify', src, 'success', Language('preorder_request_sent'), 3000)
        end
    end
end)

function CheckPreorderTime()
    local result = ExecuteSql("SELECT `id`, `information`, `preorders` FROM `real_vehicleshop`")
    if #result > 0 then
        for i = 1, #result do
            local shopId = result[i].id
            local preorders = json.decode(result[i].preorders)
            local information = json.decode(result[i].information)
            local Check = false
            if next(preorders) then
                for k, v in ipairs(preorders) do
                    if os.time() >= v.expiretime then
                        AddBankMoneyOffline(v.identifier, v.price)
                        SendMailToOfflinePlayer(v.identifier, Config.Vehicleshops[shopId].CompanyName, Language('preorder_rejected_subject'), Language('preorder_rejected_message'))
                        information.Money = information.Money - v.price
                        Config.Vehicleshops[shopId].CompanyMoney = Config.Vehicleshops[shopId].CompanyMoney - v.price
                        table.remove(preorders, k)
                        Check = true
                    end
                end
                if Check then
                    Config.Vehicleshops[shopId].Preorders = preorders
                    ExecuteSql("UPDATE `real_vehicleshop` SET `information` = '"..json.encode(information).."', `preorders` = '"..json.encode(preorders).."' WHERE `id` = '"..shopId.."'")
                    TriggerClientEvent('real-vehicleshop:Update', -1, Config.Vehicleshops)
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        CheckPreorderTime()
        Citizen.Wait(24 * 60 * 60 * 1000)
    end
end)