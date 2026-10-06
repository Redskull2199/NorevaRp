if not Framework.QBCore() then return end

local QBCore = exports["qb-core"]:GetCoreObject()

function Framework.GetPlayerID(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        return Player.PlayerData.citizenid
    end
end

function Framework.HasMoney(src, type, money)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.money[type] >= money
end

function Framework.RemoveMoney(src, type, money)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.Functions.RemoveMoney(type, money)
end

function Framework.GetJob(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.job
end

function Framework.GetGang(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.gang
end

function Framework.SaveAppearance(appearance, citizenID)
    Database.PlayerSkins.UpdateActiveField(citizenID, 0)
    Database.PlayerSkins.DeleteByModel(citizenID, appearance.model)
    Database.PlayerSkins.Add(citizenID, appearance.model, json.encode(appearance), 1)
end

function Framework.GetAppearance(citizenID, model)
    local result = Database.PlayerSkins.GetByCitizenID(citizenID, model)
    if result then
        return json.decode(result)
    end
end

-- NOREVA AWAITED APPEARANCE: acknowledges this save, not a previous active skin.
exports('norevaSaveAppearance', function(src, appearance, guard)
    local citizenID = Framework.GetPlayerID(src)
    if not citizenID or (guard and not guard()) then return false end
    Framework.SaveAppearance(appearance, citizenID)
    return not guard or guard()
end)
