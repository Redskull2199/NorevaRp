local inZone        = {}
local lastEnterTime = {}
local currentJob    = "unemployed"

local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    currentJob = QBCore.Functions.GetPlayerData().job.name
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    currentJob = job.name
end)

local function JobAllowed(zone)
    if not zone.allowedJobs then return true end
    for _, j in ipairs(zone.allowedJobs) do
        if j == currentJob then return true end
    end
    return false
end

local function ZInRange(zone, pz)
    if zone.minZ and pz < zone.minZ then return false end
    if zone.maxZ and pz > zone.maxZ then return false end
    return true
end

local function SendNotif(zone, isEnter)
    local text = isEnter and zone.enter or zone.exit
    local def  = Config.Default
    SendNUIMessage({
        action      = "showNotification",
        subtitle    = text.subtitle,
        title       = text.title,
        displayTime = zone.displayTime or def.displayTime,
        animation   = zone.animation   or def.animation,
        position    = zone.position    or def.position,
        color       = text.color or zone.color or def.color,
    })
end

CreateThread(function()
    for i, zone in ipairs(Config.Zones) do
        inZone[i]        = false
        lastEnterTime[i] = 0

        if zone.blip and zone.blip.enabled then
            local blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blip, zone.blip.sprite or 1)
            SetBlipColour(blip, zone.blip.color  or 3)
            SetBlipScale(blip,  zone.blip.scale  or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.blip.label or zone.name or "Bölge")
            EndTextCommandSetBlipName(blip)
        end
    end
end)

CreateThread(function()
    while true do
        local ped     = PlayerPedId()
        local coords  = GetEntityCoords(ped)
        local px, py, pz = coords.x, coords.y, coords.z
        local minDist = math.huge

        for i, zone in ipairs(Config.Zones) do
            if zone.enabled then
                local dx   = px - zone.coords.x
                local dy   = py - zone.coords.y
                local dz   = pz - zone.coords.z
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

                if dist < minDist then minDist = dist end

                local inside = dist <= zone.radius and ZInRange(zone, pz) and JobAllowed(zone)
                local now    = GetGameTimer()

                if inside then
                    if not inZone[i] then
                        local cd = zone.cooldown or Config.Default.cooldown
                        if (now - lastEnterTime[i]) >= cd then
                            inZone[i]        = true
                            lastEnterTime[i] = now
                            SendNotif(zone, true)
                        end
                    end
                else
                    if inZone[i] then
                        inZone[i] = false
                        SendNotif(zone, false)
                    end
                end
            end
        end

        local sleep
        if     minDist < 80  then sleep = Config.CheckInterval
        elseif minDist < 250 then sleep = Config.CheckInterval * 2
        else                      sleep = Config.CheckInterval * 4
        end

        Wait(sleep)
    end
end)

if Config.Debug then
    CreateThread(function()
        while true do
            for i, zone in ipairs(Config.Zones) do
                if zone.enabled then
                    local r = inZone[i] and 0 or 255
                    local g = inZone[i] and 220 or 140
                    local cx, cy, cz = zone.coords.x, zone.coords.y, zone.coords.z
                    local rad = zone.radius
                    for s = 0, 31 do
                        local a1 = (s / 32)       * math.pi * 2
                        local a2 = ((s + 1) / 32) * math.pi * 2
                        DrawLine(
                            cx + math.cos(a1) * rad, cy + math.sin(a1) * rad, cz,
                            cx + math.cos(a2) * rad, cy + math.sin(a2) * rad, cz,
                            r, g, 0, 220
                        )
                    end
                end
            end
            Wait(0)
        end
    end)
end

RegisterNUICallback("ready", function(_, cb) cb("ok") end)
