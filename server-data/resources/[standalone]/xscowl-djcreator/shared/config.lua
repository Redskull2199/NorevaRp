Config = {}

Config.InteractionDistance = 10.0
Config.MaxAudioDistance = 80.0

-- Karaoke Microphone / Megaphone Settings (pma-voice)
Config.EnableMegaphone = true -- Karaoke modu aktifken sesinizin daha uzağa gitmesini sağlar (Megafon özelliği)
Config.MegaphoneRange = 50.0 -- Karaoke mikrofonu aktifken pma-voice üzerinden sesinizin gideceği maksimum mesafe

-- Options: 'qb', 'esx', 'vms', 'custom'
Config.NotifyType = 'qb'
Config.TextUIType = 'qb'

-- Locale Setup
Config.Locale = 'tr' -- 'en' veya 'tr'

Config.Locales = {
    ['tr'] = {
        search_title = "Şarkı Ara",
        search_placeholder = "Şarkı adı veya sanatçı...",
        play = "OYNAT",
        pause = "DURAKLAT",
        resume = "DEVAM ET",
        stop = "DURDUR",
        confetti = "KONFETİ PATLAT",
        history_title = "Şarkı Geçmişi",
        volume = "SES",
        bass = "BASS",
        treble = "TİZ",
        echo = "YANKI",
        range = "MENZİL"
    },
    ['en'] = {
        search_title = "Search Song",
        search_placeholder = "Song name or artist...",
        play = "PLAY",
        pause = "PAUSE",
        resume = "RESUME",
        stop = "STOP",
        confetti = "POP CONFETTI",
        history_title = "Song History",
        volume = "VOL",
        bass = "BASS",
        treble = "TREB",
        echo = "ECHO",
        range = "RANGE"
    }
}

-- ============================================
-- YOUTUBE API ANAHTARI NASIL ALINIR? (HOW TO GET YOUTUBE API KEY?)
-- ============================================
-- 1. Google Cloud Console'a gidin: https://console.cloud.google.com/
-- 2. Yeni bir proje oluşturun (Create Project).
-- 3. Sol menüden "APIs & Services" > "Library" kısmına girin.
-- 4. Arama kısmına "YouTube Data API v3" yazın ve tıklayıp "Enable" (Etkinleştir) butonuna basın.
-- 5. Sol menüden "Credentials" (Kimlik Bilgileri) bölümüne geçin.
-- 6. Üstten "Create Credentials" > "API key" seçerek anahtarınızı oluşturun.
-- 7. Oluşan anahtarı aşağıdaki tırnak işaretleri arasına yapıştırın.
-- Not: Boş bırakırsanız ücretsiz alternatifleri dener fakat yüksek stabilite için API key önerilir.
-- ============================================
Config.YouTubeAPIKey = ""

-- DJ Booth Features (You can disable specific features for your customers)
Config.Features = {
    -- Faders (Sliders)
    volume     = true,
    bass       = true,
    treble     = true,
    echo       = true,
    lowpass    = true,
    tempo      = true,
    pan        = true,
    flanger    = true,
    delay      = true,
    reverb     = true,
    tremolo    = true,
    phaser     = true,
    bitcrusher = true,
    distance   = true,
    
    -- Buttons
    eightd     = true,
    karaoke    = true,
    confetti   = true
}

Config.AdminGroups = {
    ['admin'] = true,
    ['superadmin'] = true
}

-- You can add custom framework checks here if needed.
-- We are using standard QBCore or ESX through ox_lib or direct getters if needed,
-- But typically ox_lib has ways to get groups, or we can check QBCore/ESX directly.
-- For jobs, we'll need to know what framework is being used. If it's ESX: ESX.GetPlayerData().job.name
-- If QBCore: QBCore.Functions.GetPlayerData().job.name

local PlayerJob = "unknown"
local PlayerName = "DJ XSCOWL"

if not IsDuplicityVersion() then
    CreateThread(function()
        if GetResourceState('qb-core') == 'started' then
            local QBCore = exports['qb-core']:GetCoreObject()
            
            RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
                PlayerJob = JobInfo.name
            end)
            
            RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
                local pd = QBCore.Functions.GetPlayerData()
                if pd and pd.job then PlayerJob = pd.job.name end
                if pd and pd.charinfo then PlayerName = pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname end
            end)
            
            Wait(1000)
            local pd = QBCore.Functions.GetPlayerData()
            if pd and pd.job then PlayerJob = pd.job.name end
            if pd and pd.charinfo then PlayerName = pd.charinfo.firstname .. ' ' .. pd.charinfo.lastname end

        elseif GetResourceState('es_extended') == 'started' then
            local ESX = exports['es_extended']:getSharedObject()
            
            RegisterNetEvent('esx:setJob', function(job)
                PlayerJob = job.name
            end)
            
            RegisterNetEvent('esx:playerLoaded', function(xPlayer)
                PlayerJob = xPlayer.job.name
                if xPlayer.firstName then PlayerName = xPlayer.firstName .. ' ' .. xPlayer.lastName end
            end)
            
            Wait(1000)
            local pd = ESX.GetPlayerData()
            if pd and pd.job then PlayerJob = pd.job.name end
            if pd and pd.firstName then PlayerName = pd.firstName .. ' ' .. pd.lastName end
        end
    end)
end

Config.GetPlayerJob = function()
    return PlayerJob
end

Config.GetPlayerName = function()
    return PlayerName
end

-- ============================================
-- CUSTOM NOTIFICATION & TEXTUI FUNCTIONS
-- ============================================
-- These are only used if Config.NotifyType or Config.TextUIType is set to 'custom'
Config.CustomNotify = function(title, message, type, duration)
    -- type is usually 'success', 'error', 'info'
    -- Example for okokNotify:
    -- exports['okokNotify']:Alert(title, message, duration or 5000, type)
    print("NOTIFY: ["..type.."] " .. title .. " - " .. message)
end

Config.CustomShowTextUI = function(text)
    -- Example for ox_lib:
    -- lib.showTextUI(text)
    print("TEXTUI: " .. text)
end

Config.CustomHideTextUI = function()
    -- Example for ox_lib:
    -- lib.hideTextUI()
    print("TEXTUI HIDE")
end


