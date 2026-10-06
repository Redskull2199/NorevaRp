-- Client Player Module

Bridge = Bridge or {}
Bridge.PlayerData = {}

-- Helper: Ensure framework is ready
local function EnsureFrameworkReady()
    if Bridge.EnsureReady then
        Bridge.EnsureReady()
    elseif not Bridge.Ready then
        while not Bridge.Framework do
            Wait(100)
        end
    end
end

-- Get local player data
function Bridge.GetPlayerData()
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        if not Bridge.PlayerData or not Bridge.PlayerData.identifier then
            Bridge.PlayerData = Bridge.FrameworkObject.GetPlayerData()
        end
        return Bridge.PlayerData
    elseif Bridge.Framework == 'qbcore' then
        if not Bridge.PlayerData or not Bridge.PlayerData.citizenid then
            Bridge.PlayerData = Bridge.FrameworkObject.Functions.GetPlayerData()
        end
        return Bridge.PlayerData
    elseif Bridge.Framework == 'qbox' then
        if not Bridge.PlayerData or not Bridge.PlayerData.citizenid then
            Bridge.PlayerData = Bridge.FrameworkExport:GetPlayerData()
        end
        return Bridge.PlayerData
    elseif Bridge.Framework == 'standalone' then
        return {
            name = GetPlayerName(PlayerId()),
            identifier = nil
        }
    end
    return {}
end

-- Get player job
function Bridge.GetJob()
    EnsureFrameworkReady()
    local playerData = Bridge.GetPlayerData()

    if Bridge.Framework == 'esx' then
        return playerData.job or {}
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return playerData.job or {}
    elseif Bridge.Framework == 'standalone' then
        return {
            name = 'unemployed',
            label = 'Unemployed'
        }
    end
    return {}
end

-- Check if player has a specific job
function Bridge.HasJob(jobName, minGrade)
    EnsureFrameworkReady()
    minGrade = minGrade or 0
    local job = Bridge.GetJob()

    if not job or not job.name then return false end

    local grade = 0
    if Bridge.Framework == 'esx' then
        grade = job.grade or 0
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        grade = job.grade and job.grade.level or 0
    end

    return job.name == jobName and grade >= minGrade
end

-- Get player identifier
function Bridge.GetIdentifier()
    EnsureFrameworkReady()
    local playerData = Bridge.GetPlayerData()

    if Bridge.Framework == 'esx' then
        return playerData.identifier
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        return playerData.citizenid
    end
    return nil
end

-- Get player name
function Bridge.GetName()
    EnsureFrameworkReady()
    local playerData = Bridge.GetPlayerData()

    if Bridge.Framework == 'esx' then
        return playerData.name or GetPlayerName(PlayerId())
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        if playerData.charinfo then
            return playerData.charinfo.firstname .. ' ' .. playerData.charinfo.lastname
        end
    end
    return GetPlayerName(PlayerId())
end

-- Get player money
function Bridge.GetMoney(accountType)
    EnsureFrameworkReady()
    accountType = accountType or 'bank'
    local playerData = Bridge.GetPlayerData()

    if Bridge.Framework == 'esx' then
        if playerData.accounts then
            for _, account in ipairs(playerData.accounts) do
                if account.name == accountType then
                    return account.money
                end
            end
        end
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        if playerData.money then
            return playerData.money[accountType] or 0
        end
    end
    return 0
end

-- Check if player is dead
function Bridge.IsDead()
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        return Bridge.PlayerData.dead or false
    elseif Bridge.Framework == 'qbcore' then
        local player = Bridge.FrameworkObject.Functions.GetPlayerData()
        return player.metadata and player.metadata.isdead or false
    elseif Bridge.Framework == 'qbox' then
        local player = Bridge.FrameworkExport:GetPlayerData()
        return player.metadata and player.metadata.isdead or false
    end
    return false
end

-- Get player coordinates
function Bridge.GetCoords()
    return GetEntityCoords(PlayerPedId())
end

-- Get player heading
function Bridge.GetHeading()
    return GetEntityHeading(PlayerPedId())
end
