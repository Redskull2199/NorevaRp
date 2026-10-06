function Callback(name, payload)
    if Config.Framework == "esx" or Config.Framework == "oldesx" then
        local data = nil
        if frameworkObject then
            frameworkObject.TriggerServerCallback(name, function(returndata)
                data = returndata
            end, payload)
            while data == nil do
                Citizen.Wait(0)
            end
        end
        return data
    else
        local data = nil
        if frameworkObject then
            frameworkObject.Functions.TriggerCallback(name, function(returndata)
                data = returndata
            end, payload)
            while data == nil do
                Citizen.Wait(0)
            end
        end
        return data
    end
end

-------------------------- Plate Shit --------------------------
local NumberCharset = {}
local Charset = {}
 
for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

function GeneratePlate()
	math.randomseed(GetGameTimer())
 
	local GeneratedPlate = string.upper(GetRandomLetter(3) .. (true and ' ' or '') .. GetRandomNumber(3))

	local isTaken = CheckPlateStatus(GeneratedPlate)
	if isTaken then 
		return GeneratePlate()
	end
	return GeneratedPlate
end

function CheckPlateStatus(plate)
	local p = promise.new()
    local data = Callback('real-vehicleshop:CheckPlateStatus', plate)
    p:resolve(data)
	return Citizen.Await(p)
end

function GetRandomNumber(length)
	Wait(0)
	return length > 0 and GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)] or ''
end

function GetRandomLetter(length)
	Wait(0)
	return length > 0 and GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)] or ''
end
-------------------------- Plate Shit End --------------------------

------------------------------ Start ------------------------------
Blips = {}

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
    Wait(1300)
    TriggerServerEvent('real-vehicleshop:RequestData')
    ClearBlips()
    CreateBlips()
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    Wait(1300)
    TriggerServerEvent('real-vehicleshop:RequestData')
    ClearBlips()
    CreateBlips()
end)

AddEventHandler('onResourceStart', function(resourceName) -- Silinecek
    if resourceName == GetCurrentResourceName() then
        TriggerServerEvent('real-vehicleshop:RequestData')
    end
end)

RegisterNetEvent('real-vehicleshop:Update', function(table)
    Config.Vehicleshops = table
    Wait(1000)
    ClearBlips()
    CreateBlips()
end)

function ClearBlips()
    for k, v in pairs(Blips) do
        RemoveBlip(v)
    end
end

function CreateBlips()
    for k, v in pairs(Config.Vehicleshops) do
        if v.BlipSettings.Enable then
            blip = AddBlipForCoord(v.ShopOpenCoords)
            SetBlipSprite(blip, v.BlipSettings.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, v.BlipSettings.Scale)
            SetBlipColour(blip, v.BlipSettings.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.CompanyName)
            EndTextCommandSetBlipName(blip)
            table.insert(Blips, blip)
        end
    end
end