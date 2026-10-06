local QBCore = exports["qb-core"]:GetCoreObject()
local notifTimeout = false
local inZone = false
local sendData = nil
local currentWeapon = {
    name = "weapon_g17",
    hash = 0,
    ammo = 0
}
local killFeed = {}

CreateThread(function()
    -- Ped oluştur
    RequestModel(Config.Ped.Model)
    while not HasModelLoaded(Config.Ped.Model) do
        Wait(50)
    end

    local createPed = CreatePed(0, Config.Ped.Model, Config.Ped.Coords.x, Config.Ped.Coords.y, Config.Ped.Coords.z, Config.Ped.Coords.h or 0.0, false, true)
    FreezeEntityPosition(createPed, true)
    SetBlockingOfNonTemporaryEvents(createPed, true)
    SetEntityInvincible(createPed, true)

    -- E tuşu ile etkileşim loop
    local notifTimeout = false
    CreateThread(function()
        while true do
            local sleep = 1000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local dist = #(coords - vector3(Config.Ped.Coords.x, Config.Ped.Coords.y, Config.Ped.Coords.z))

            if dist < 2.0 then
                sleep = 0
                -- 3D yazı
                DrawText3D(Config.Ped.Coords.x, Config.Ped.Coords.y, Config.Ped.Coords.z + 2.0, "~g~[E]~w~ Warzone")

                if IsControlJustPressed(0, 38) then -- 38 = E
                    QBCore.Functions.TriggerCallback("wex-warzone:server:checkActivated", function(activated)
                        if activated then
                            OpenZonesMenu()
                        else
                            if not notifTimeout then
                                QBCore.Functions.Notify("Warzone şuanda kapalı!", "error")
                                notifTimeout = true
                                SetTimeout(1000, function() notifTimeout = false end)
                            end
                        end
                    end)
                end
            end
            Wait(sleep)
        end
    end)
end)

-- 3D Yazı Fonksiyonu
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end


CreateThread(function()
    while true do
        sleep = 100

        if inZone then
            sleep = 5
            local Killer, DeathCauseHash
            if IsControlJustPressed(0, 304) then
                exports["wex-warzone"]:openMenu({
                    {
                        header = Config.ServerName .. " Warzone Menu",
                        isMenuHeader = true
                    },
                    {
                        header = "Warzone Shop",
                        txt = "Shop with your points",
                        params = {
                            event = "wex-warzone:client:shop"
                        }
                    },
                    {
                        header = "Scoreboard",
                        txt = "Who is at the top in Warzone",
                        params = {
                            event = "wex-warzone:client:scoreboard"
                        }
                    },
                    {
                        header = "Left Warzone",
                        txt = "What, you're gonna run like a coward?",
                        params = {
                            event = "wex-warzone:client:sendRealWorld"
                        }
                    }
                })
            end

            if IsEntityDead(PlayerPedId()) then
                local PedKiller = GetPedSourceOfDeath(PlayerPedId())
                local _, wep = GetCurrentPedWeapon(PedKiller)
                DeathCauseHash = GetPedCauseOfDeath(PlayerPedId())
                if IsEntityAPed(PedKiller) and IsPedAPlayer(PedKiller) then
                    Killer = NetworkGetPlayerIndexFromPed(PedKiller)
                elseif IsEntityAVehicle(PedKiller) and IsEntityAPed(GetPedInVehicleSeat(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
                    Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
                end
                
                local _, wep = GetCurrentPedWeapon(PlayerPedId())
                currentWeapon = {
                    name = currentWeapon.name,
                    hash = wep,
                    ammo = GetAmmoInPedWeapon(PlayerPedId(), wep)
                }
                TriggerServerEvent("wex-warzone:server:setData", GetPlayerServerId(Killer), "kill")
                TriggerServerEvent("wex-warzone:server:setData", GetPlayerServerId(PlayerId()), "death")
                TriggerServerEvent("wex-warzone:server:addFeed", GetPlayerServerId(PlayerId()), GetPlayerServerId(Killer), "weapon_g17")
                local TargetPed = GetPlayerPed(GetPlayerServerId(Killer))
                SetEntityHealth(TargetPed, GetEntityMaxHealth(TargetPed))
                SetPedArmour(TargetPed, 100)
                SetPedCanRagdoll(PlayerPedId(), false)
                Wait(5000)
                local randomCoords = math.random(1, #Config.Zones)
                SetEntityCoords(PlayerPedId(), Config.Zones[randomCoords].x, Config.Zones[randomCoords].y, Config.Zones[randomCoords].z, false, false, false, true)
                TriggerEvent("hospital:client:Revive", GetPlayerServerId(PlayerId()))
                SetPedCanRagdoll(PlayerPedId(), true)
                RemoveAllPedWeapons(PlayerPedId(), true)
                GiveWeaponToPed(PlayerPedId(), currentWeapon.hash, currentWeapon.ammo, false, false)
                SetPedAmmo(PlayerPedId(), currentWeapon.hash, currentWeapon.ammo)
                SetCurrentPedWeapon(PlayerPedId(), currentWeapon.hash, true)
                MakePedReload(PlayerPedId())
                QBCore.Functions.TriggerCallback("wex-warzone:server:getData", function(data)
                    SendReactMessage("setDisplay", true)
                    SendReactMessage("setServerName", Config.ServerName)
                    SendReactMessage("setData", data)
                end)
                while IsEntityDead(PlayerPedId()) do
                    Wait(0)
                end
            end

            if #(GetEntityCoords(PlayerPedId()) - vector3(1126.08, -3025.78, 17.15)) > 200.0 then
                local randomCoords = math.random(1, #Config.Zones)
                SetEntityCoords(PlayerPedId(), Config.Zones[randomCoords].x, Config.Zones[randomCoords].y, Config.Zones[randomCoords].z, false, false, false, true)
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent("wex-warzone:client:giveWeapon", function(data)
    RemoveAllPedWeapons(PlayerPedId(), true)
    currentWeapon.name = data.name
    currentWeapon.hash = GetHashKey(data.name)
    currentWeapon.ammo = data.ammo
    GiveWeaponToPed(PlayerPedId(), GetHashKey(data.name), data.ammo, false, false)
    SetPedAmmo(PlayerPedId(), GetHashKey(data.name), data.ammo)
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey(data.name), true)
    MakePedReload(PlayerPedId())
end)

RegisterNetEvent("wex-warzone:client:sendBucket", function()
    local randomCoords = math.random(1, #Config.Zones)
    QBCore.Functions.TriggerCallback("wex-warzone:server:getData", function(data)
        TriggerServerEvent("wex-warzone:server:setBucket", 1)
        SendReactMessage("setDisplay", true)
        SendReactMessage("setServerName", Config.ServerName)
        SendReactMessage("setData", data)
        inZone = true
        if GetResourceState("ox_inventory") == "started" then
            exports.ox_inventory:closeInventory()
        end
        LocalPlayer.state:set('invBusy', true, true)
        SetEntityCoords(PlayerPedId(), Config.Zones[randomCoords].x, Config.Zones[randomCoords].y, Config.Zones[randomCoords].z, false, false, false, true)
        TriggerServerEvent("wex-warzone:server:manageItems", "save")
        Wait(500)
        RemoveAllPedWeapons(PlayerPedId(), true)
        local initialAmmo = 160
        for _, item in ipairs(Config.Items) do
            if item.name:lower() == "weapon_g17" then
                initialAmmo = item.ammo or 160
                break
            end
        end
        currentWeapon = {
            name = "weapon_g17",
            hash = GetHashKey("weapon_g17"),
            ammo = initialAmmo
        }
        GiveWeaponToPed(PlayerPedId(), currentWeapon.hash, currentWeapon.ammo, false, false)
        SetPedAmmo(PlayerPedId(), currentWeapon.hash, currentWeapon.ammo)
        SetCurrentPedWeapon(PlayerPedId(), currentWeapon.hash, true)
        MakePedReload(PlayerPedId())
        -- Silah koruma thread'i: ox_inventory silahi alirsa geri ver
        CreateThread(function()
            while inZone do
                Wait(500)
                if currentWeapon.hash ~= 0 and not IsEntityDead(PlayerPedId()) then
                    local _, activeWep = GetCurrentPedWeapon(PlayerPedId())
                    if activeWep ~= currentWeapon.hash then
                        if not HasPedGotWeapon(PlayerPedId(), currentWeapon.hash, false) then
                            GiveWeaponToPed(PlayerPedId(), currentWeapon.hash, currentWeapon.ammo, false, false)
                            SetPedAmmo(PlayerPedId(), currentWeapon.hash, currentWeapon.ammo)
                        end
                        SetCurrentPedWeapon(PlayerPedId(), currentWeapon.hash, true)
                    end
                end
            end
        end)
    end)
end)

RegisterNetEvent("wex-warzone:client:scoreboard", function()
    QBCore.Functions.TriggerCallback("wex-warzone:server:getPlayerData", function(data)
        local menu = {
            {
                header = Config.ServerName .. " Warzone Puan Tablosu",
                isMenuHeader = true
            },
        }
        local sortedData = getKeysSortedByValue(data, function(a, b)
            return tonumber(a.Warzone.points) > tonumber(b.Warzone.points) 
        end)
        for k, v in pairs(sortedData) do
            menu[#menu+1] = {
                header = data[tonumber(v)].pData.charinfo.firstname .. " ".. data[tonumber(v)].pData.charinfo.lastname,
                txt = "Puan: ".. data[tonumber(v)].Warzone.points .. " | Öldürme: ".. data[tonumber(v)].Warzone.kill .. " | Ölme: ".. data[tonumber(v)].Warzone.death
            }
        end
        exports["wex-warzone"]:openMenu(menu)
    end)
end)

RegisterNetEvent("wex-warzone:client:shop", function()
    local menu = {
        {
            header = Config.ServerName .. " Warzone Market",
            isMenuHeader = true
        },
    }

    for k, v in pairs(Config.Items) do
        if v.free and v.free == true then
            menu[#menu+1] = {header = v.header, txt = "Fiyat: ".. Config.FreeItemText, params = {
                isServer = true,
                event = "wex-warzone:server:addItem",
                args = v
            }}
        else
            menu[#menu+1] = {header = v.header, txt = "Fiyat: ".. v.points .. " puan", params = {
                isServer = true,
                event = "wex-warzone:server:addItem",
                args = v
            }}
        end
        exports["wex-warzone"]:openMenu(menu)
    end

end)

RegisterNetEvent("wex-warzone:client:sendRealWorld", function()
    RemoveAllPedWeapons(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), Config.Ped.Coords.x, Config.Ped.Coords.y, Config.Ped.Coords.z, false, false, false, true)
    TriggerServerEvent("wex-warzone:server:setBucket", 0)
    inZone = false
    LocalPlayer.state:set('invBusy', false, true)
    TriggerServerEvent("wex-warzone:server:manageItems", "give")
    ExecuteCommand("yenile")
end)

RegisterNetEvent("wex-warzone:client:updateNui", function(display)
    QBCore.Functions.TriggerCallback("wex-warzone:server:getData", function(data)
        SendReactMessage("setDisplay", display)
        SendReactMessage("setServerName", Config.ServerName)
        SendReactMessage("setData", data)
    end)
end)

function OpenZonesMenu()
    QBCore.Functions.TriggerCallback("wex-warzone:server:getData", function(data)
            exports["wex-warzone"]:openMenu({
            {
                header = "Wex Warzone", 
                isMenuHeader = true
            },
            {
                header = "Alana gir ".. (data.serverData.playerCount) .. " / ".. Config.MaxLobbyPlayer, 
                txt = "Alana gir ve çatışmanın zevkine var!",
                params = {
                    event = "wex-warzone:client:sendBucket"
                }
            },
        })
    end)
end

RegisterNetEvent("wex-warzone:client:addFeed", function(pSteam, tSteam, weapon)
    local id = #killFeed+1
    killFeed[id] = {
        id = id,
        Killed = pSteam,
        Weapon = weapon,
        Killer = tSteam,
        checked = true
    }
    
    SendReactMessage("setKillFeed", killFeed)
    Wait(2000)
    killFeed[id].checked = false
    SendReactMessage("setKillFeed", killFeed)
    Wait(1000)
    killFeed[id] = nil
end)

function SendReactMessage(action, data)
	SendNUIMessage({
        action = action,
		data = data
	})
end


function getKeysSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end
    
    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)
    
    return keys
end

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerServerEvent("wex-warzone:server:setBucket", 0)
        LocalPlayer.state:set('invBusy', false, true)
    end
end)

RegisterNUICallback("escapeNui", function()
    SetNuiFocus(false, false)
    SendReactMessage("setMenuDisplay", false)
end)

RegisterNUICallback("triggerMenuItem", function(data)
    PlaySoundFrontend(-1, 'Highlight_Cancel', 'DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    SetNuiFocus(false)
    SendReactMessage("setMenuDisplay", false)
    if data then
        if data.isServer then
            TriggerServerEvent(data.event, data.args)
        elseif data.isCommand then
            ExecuteCommand(data.event)
        elseif data.isQBCommand then
            TriggerServerEvent('QBCore:CallCommand', data.event, data.args)
        elseif data.isAction then
            data.event(data.args)
        else
            print(data.event)
            TriggerEvent(data.event, data.args)
        end
    end
end)

exports("inZone", function()
    return inZone
end)

exports("openMenu", function(data)
    SendReactMessage("setMenu", data)
    sendData = data
    SendReactMessage("setMenuDisplay", true)
    SetNuiFocus(true, true)
end)