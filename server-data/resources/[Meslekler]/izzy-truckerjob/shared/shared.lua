izzy = {}

if not IsDuplicityVersion() then

    function izzy.getStreetName(coords)
        local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local streetName = GetStreetNameFromHashKey(streetHash)
        local crossingName = GetStreetNameFromHashKey(crossingHash)
        
        if crossingName and crossingName ~= "" then
            return streetName .. " / " .. crossingName
        end
        return streetName
    end

    function izzy.getZoneName(coords)
        return GetNameOfZone(coords.x, coords.y, coords.z)
    end

    function izzy.getVehicleKeys(plate)
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
    end

    function izzy.getVehicleStats(model)
        local hash = type(model) == 'string' and joaat(model) or model
        local speed = GetVehicleModelEstimatedMaxSpeed(hash) or 0
        local speedKmh = math.floor(speed * 3.6)
        local speedPercent = math.min(100, math.floor((speedKmh / 180) * 100))
        local acceleration = GetVehicleModelAcceleration(hash) or 0
        local accelPercent = math.min(100, math.floor(acceleration * 100))
        return {
            speed = speedPercent,
            capacity = accelPercent
        }
    end

else

    function izzy.getPlayer(src)
        if QBCore then
            return QBCore.Functions.GetPlayer(src)
        elseif ESX then
            return ESX.GetPlayerFromId(src)
        end
        return nil
    end

    function izzy.removeMoney(src, amount, account)
        local player = izzy.getPlayer(src)
        if not player or not amount or amount == 0 then return false end
        account = account or 'cash'
        if framework == 'esx' then
            if account == 'bank' then player.removeAccountMoney('bank', amount) else player.removeMoney(amount) end
            return true
        elseif framework == 'qb' then
            player.Functions.RemoveMoney(account, amount)
            return true
        end
        return false
    end

    function izzy.addMoney(src, amount, account)
        local player = izzy.getPlayer(src)
        if not player or not amount or amount == 0 then return false end
        account = account or 'cash'
        if framework == 'esx' then
            if account == 'bank' then player.addAccountMoney('bank', amount) else player.addMoney(amount) end
            return true
        elseif framework == 'qb' then
            player.Functions.AddMoney(account, amount)
            return true
        end
        return false
    end

end
