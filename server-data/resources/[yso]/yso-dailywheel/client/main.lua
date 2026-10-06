if AK4Y.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif AK4Y.Framework == "oldqb" then 
    QBCore = nil
end

CreateThread(function()
    if AK4Y.Framework == "oldqb" then 
        while QBCore == nil do
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Citizen.Wait(200)
        end
	elseif AK4Y.Framework == "qb" then
		while QBCore == nil do
            Citizen.Wait(200)
        end
    end
    Wait(1000)	
	PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	PlayerData = QBCore.Functions.GetPlayerData()
    if AK4Y.SpawnOpenMenu then
        TriggerEvent('wex-dailywheel:openMenu')
    end
end)


local openMenuSpamProtect = 0
RegisterNetEvent('wex-dailywheel:openMenu')
AddEventHandler('wex-dailywheel:openMenu', function()
    if openMenuSpamProtect < GetGameTimer() then 
        openMenuSpamProtect = GetGameTimer() + 1500
        QBCore.Functions.TriggerCallback("wex-dailywheel:getPlayerDetails", function(result)
            local firstname = PlayerData.charinfo.firstname
            local lastname = PlayerData.charinfo.lastname
            local timeX = result.ostime
            local expireTimeX = result.nextRoll
            local freeRoll = true
            local remainingTime = disp_time(expireTimeX - timeX)
            if expireTimeX - timeX > 0 then 
                freeRoll = false
            end
            apiKey = result.apiKey
            if result.steamid then
                steamID = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. apiKey .. "&steamids=" .. result.steamid
            else
                steamID = 'null'
            end
            SetNuiFocus(true,true)                                                                                                           
            SendNUIMessage({
                type = 'openMenu',
                items = AK4Y.WheelItems,
                tebexLink = AK4Y.TebexPageLink,
                myFirstName = firstname,
                myLastName = lastname,
                freeRoll = freeRoll,
                remaining = remainingTime,
                myCoinAmount = result.coinAmount,
                profilePhoto = steamID,
                spinCost = AK4Y.SpinCost,
                translate = AK4Y.Translate,
                
            })	
        end)
    end
end)

if AK4Y.CommandUse then 
    RegisterCommand(AK4Y.OpenCommandMenu, function()
        if openMenuSpamProtect < GetGameTimer() then 
            openMenuSpamProtect = GetGameTimer() + 1500
            QBCore.Functions.TriggerCallback("wex-dailywheel:getPlayerDetails", function(result)
                local firstname = PlayerData.charinfo.firstname
                local lastname = PlayerData.charinfo.lastname
                local timeX = result.ostime
                local expireTimeX = result.nextRoll
                local freeRoll = true
                local remainingTime = disp_time(expireTimeX - timeX)
                if expireTimeX - timeX > 0 then 
                    freeRoll = false
                end


                apiKey = result.apiKey
                if result.steamid then
                    steamID = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=" .. apiKey .. "&steamids=" .. result.steamid
                else
                    steamID = 'null'
                end
                SetNuiFocus(true,true)
                SendNUIMessage({
                    type = 'openMenu',
                    items = AK4Y.WheelItems,
                    tebexLink = AK4Y.TebexPageLink,
                    myFirstName = firstname,
                    myLastName = lastname,
                    freeRoll = freeRoll,
                    remaining = remainingTime,
                    myCoinAmount = result.coinAmount,
                    profilePhoto = steamID,
                    spinCost = AK4Y.SpinCost,
                    translate = AK4Y.Translate,
                    
                })	
            end)
        end
    end)
end

RegisterNUICallback('closeMenu', function(data, cb)
	SetNuiFocus(false, false)
end)



RegisterNUICallback('spinWheel', function(data, cb)
    QBCore.Functions.TriggerCallback("wex-dailywheel:spinWheel", function(result)
        if result ~= nil then 
            local coinAmount = result.coinAmount ~= nil and result.coinAmount or 0
            local nextRoll = result.nextRoll ~= nil and result.nextRoll or 0
            local ostime = result.osTime ~= nil and result.osTime or 0
            local selectedItem = result.selectedItem ~= nil and result.selectedItem or "water"
            local remainingTime = disp_time((nextRoll - 1) - ostime)
            local resID = result.resId ~= nil and result.resId or nil

            local callback = {
                selectedItem = selectedItem,
                serverSide = remainingTime,
                coinAmount = coinAmount,
            }


            if selectedItem.giveItemType == "vehicle" then 

                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(ped)
                local vehItemNameHash = GetHashKey(selectedItem.itemName)
                if not IsModelInCdimage(vehItemNameHash) then return end RequestModel(vehItemNameHash)  while not HasModelLoaded(vehItemNameHash) do Wait(0) end
                local vehicle = CreateVehicle(vehItemNameHash, playerCoords.x, playerCoords.y, playerCoords.z - 200.0, 1.0, false, false)
                FreezeEntityPosition(vehicle, true)
                local vehProp = QBCore.Functions.GetVehicleProperties(vehicle)
                TriggerServerEvent('wex-dailywheel:giveItem', resID, vehProp)
                Citizen.Wait(200)
                DeleteVehicle(vehicle)
                DeleteEntity(vehicle)
            else
                TriggerServerEvent('wex-dailywheel:giveItem', resID)
            end

            cb(callback)
        else
            cb(false)
        end

    end, data.spinType, selectedItem)
end)

local sendInputSpamProtect = 0
RegisterNUICallback('sendInput', function(data, cb)
	if sendInputSpamProtect <= GetGameTimer() then
		sendInputSpamProtect = GetGameTimer() + 2000 
		QBCore.Functions.TriggerCallback("wex-dailywheel:sendInput", function(result)
			if result then 	
				cb(tonumber(result))
			else
				cb(false)
			end
		end, data)
    else
        cb(false)
	end
end)

function disp_time(time)
    local days = math.floor(time/86400)
    local remaining = time % 86400
    local hours = math.floor(remaining/3600)
    remaining = remaining % 3600
    local minutes = math.floor(remaining/60)
    remaining = remaining % 60
    local seconds = remaining
    if (hours < 10) then
        hours = "0" .. tostring(hours)
    end
    if (minutes < 10) then
        minutes = "0" .. tostring(minutes)
    end
    if (seconds < 10) then
        seconds = "0" .. tostring(seconds)
    end
    if days > 0 then 
        answer = tostring(days)..'d '..hours..'h '..minutes..'m'
    else
        if tonumber(hours) > 0 then 
            answer = hours..'h '..minutes..'m'
        else
            answer = minutes..'m'
        end
    end
    return answer
end