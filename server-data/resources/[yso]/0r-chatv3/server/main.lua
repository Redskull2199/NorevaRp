-- 0R Chat V3 - Sunucu tarafi (eksik server/ dosyasi yeniden yazildi)
-- Eventler ve payload formati client/main.lua + client/default.lua ile uyumludur.

local Config = require 'config.config'

local QBCore = nil
local qbState = GetResourceState('qb-core')
if qbState == 'started' or qbState == 'starting' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local function GetCharName(src)
    if QBCore then
        local ok, player = pcall(function() return QBCore.Functions.GetPlayer(src) end)
        if ok and player then
            local c = player.PlayerData.charinfo or {}
            local full = ((c.firstname or '') .. ' ' .. (c.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
            if full ~= '' then return full end
        end
    end
    return GetPlayerName(src) or ('Oyuncu ' .. tostring(src))
end

local function GetPlayerJob(src)
    if QBCore then
        local ok, player = pcall(function() return QBCore.Functions.GetPlayer(src) end)
        if ok and player then
            local job = player.PlayerData.job or {}
            return job.name or 'unemployed', job.label or 'Isiz'
        end
    end
    return 'unemployed', 'Isiz'
end

local function GetPlayerGang(src)
    if QBCore then
        local ok, player = pcall(function() return QBCore.Functions.GetPlayer(src) end)
        if ok and player then
            local gang = player.PlayerData.gang or {}
            return gang.name or 'none'
        end
    end
    return 'none'
end

local function IsAdmin(src)
    return IsPlayerAceAllowed(src, 'command') or IsPlayerAceAllowed(src, 'group.admin')
end

local VALID_CATEGORIES = {
    all = true, kamu = true, me = true, ['do'] = true, admin = true, server = true,
    dice = true, rps = true, report = true, reportreply = true, custom = true,
    pm = true, ooc = true, img = true, police = true, ambulance = true,
    ballas = true, vagos = true, tweet = true, yellowpages = true, charinfo = true,
}

local lastMessageAt = {}
local lastWritingAt = {}
local MESSAGE_COOLDOWN = 500
local WRITING_COOLDOWN = 400
local MAX_LENGTH = 500

local function SendDiscordLog(webhook, payload, color)
    if not Webhooks or not Webhooks.enabled or not webhook or webhook == '' then return end
    local embed = {
        {
            title = '[0R Chat] ' .. (payload.category or 'kamu'),
            description = ('**%s** (%s): %s'):format(payload.fullname, payload.category or 'kamu', payload.message or ''),
            color = color or 3447003,
            footer = { text = '0r-chatv3' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        }
    }
    PerformHttpRequest(webhook, function() end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end

RegisterNetEvent('0r-chatv3:server:sendMessage', function(data)
    local src = source
    if type(data) ~= 'table' then return end

    local category = type(data.category) == 'string' and data.category or 'kamu'
    if not VALID_CATEGORIES[category] then category = 'kamu' end

    local message = type(data.message) == 'string' and data.message or ''
    message = message:sub(1, MAX_LENGTH)

    local isImage = data.isImage == true
    if message == '' and not isImage and category ~= 'charinfo' then return end

    local now = GetGameTimer()
    if lastMessageAt[src] and (now - lastMessageAt[src]) < MESSAGE_COOLDOWN then return end
    lastMessageAt[src] = now

    local jobName, jobLabel = GetPlayerJob(src)
    local gangName = GetPlayerGang(src)

    local payload = {
        source = src,
        fullname = GetCharName(src),
        category = category,
        message = message,
        isImage = isImage,
        mask = data.mask == true,
        hand = data.hand,
        targetPlayer = data.targetPlayer,
        job = jobName,
        jobLabel = jobLabel,
        gang = gangName,
        time = now,
    }

    -- Hedefe ozel mesajlar (pm / reportreply)
    if (category == 'pm' or category == 'reportreply') and type(data.targetPlayer) == 'number' then
        local target = data.targetPlayer
        TriggerClientEvent('0r-chatv3:client:sendMessage', target, payload)
        if IsAdmin(src) and target ~= src then
            TriggerClientEvent('0r-chatv3:client:sendMessage', src, payload)
        end
        SendDiscordLog(Webhooks.report, payload, 15158332)
        return
    end

    -- Admin mesaji: sadece adminlere
    if category == 'admin' then
        for _, player in ipairs(GetPlayers()) do
            local id = tonumber(player)
            if IsAdmin(id) then
                TriggerClientEvent('0r-chatv3:client:sendMessage', id, payload)
            end
        end
        SendDiscordLog(Webhooks.report, payload, 15158332)
        return
    end

    -- Report: sadece adminlere
    if category == 'report' then
        for _, player in ipairs(GetPlayers()) do
            local id = tonumber(player)
            if IsAdmin(id) then
                TriggerClientEvent('0r-chatv3:client:sendMessage', id, payload)
            end
        end
        -- raporlayici da kendi mesajini gorur
        TriggerClientEvent('0r-chatv3:client:sendMessage', src, payload)
        SendDiscordLog(Webhooks.report, payload, 15158332)
        return
    end

    -- Duyuru
    if category == 'server' then
        TriggerClientEvent('0r-chatv3:client:sendMessage', -1, payload)
        SendDiscordLog(Webhooks.announce ~= '' and Webhooks.announce or Webhooks.main, payload, 16776960)
        return
    end

    -- Is sohbeti (config JobChat status aciksa)
    local jobCfg = Config.JobChat and Config.JobChat[category]
    if jobCfg and jobCfg.status then
        for _, player in ipairs(GetPlayers()) do
            local id = tonumber(player)
            local pJob = GetPlayerJob(id)
            if pJob == jobCfg.job then
                TriggerClientEvent('0r-chatv3:client:sendMessage', id, payload)
            end
        end
        return
    end

    -- Gang sohbeti (config GangChat status aciksa)
    local gangCfg = Config.GangChat and Config.GangChat[category]
    if gangCfg and gangCfg.status then
        for _, player in ipairs(GetPlayers()) do
            local id = tonumber(player)
            if GetPlayerGang(id) == gangCfg.gang then
                TriggerClientEvent('0r-chatv3:client:sendMessage', id, payload)
            end
        end
        return
    end

    -- Genel mesaj
    TriggerClientEvent('0r-chatv3:client:sendMessage', -1, payload)

    if category == 'me' or category == 'do' then
        SendDiscordLog(Webhooks.main, payload, 16744448)
    elseif category ~= 'kamu' then
        SendDiscordLog(Webhooks.main, payload, 3447003)
    end
end)

RegisterNetEvent('0r-chatv3:server:writingText', function(state)
    local src = source
    local now = GetGameTimer()
    if lastWritingAt[src] and (now - lastWritingAt[src]) < WRITING_COOLDOWN then return end
    lastWritingAt[src] = now
    TriggerClientEvent('0r-chatv3:client:writingText', -1, src, state == true)
end)

-- Oyuncu yuklendiginde client'in NUI config bekleyen event'ini tetikle
if QBCore then
    AddEventHandler('QBCore:Server:OnPlayerLoaded', function(player)
        local src = player and player.PlayerData and player.PlayerData.source
        if src then
            TriggerClientEvent('0r-chatv3:client:onPlayerLoaded', src)
        end
    end)
end

AddEventHandler('playerDropped', function()
    local src = source
    lastMessageAt[src] = nil
    lastWritingAt[src] = nil
end)
