local npcs = {}
local isUiOpen = false

local function LoadModel(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end
    return hash
end

print("discord.gg/nevastore")

local function OpenBankUI()
    if isUiOpen then return end
    
    Bridge.TriggerCallback('neva-banking:server:getBankingData', function(data)
        if data then
            SetNuiFocus(true, true)
            SetTimecycleModifier('hud_def_blur')
            SendNUIMessage({
                action = 'openBank',
                data = data,
                locales = Locales[Config.Locale] or {}
            })
            isUiOpen = true
        end
    end)
end

local function OpenAtmUI()
    if isUiOpen then return end

    Bridge.TriggerCallback('neva-banking:server:hasPin', function(hasPin)
        if not hasPin then
            Bridge.Notify(_U('no_pin'), 'error')
            return
        end

        SetNuiFocus(true, true)
        SetTimecycleModifier('hud_def_blur')
        SendNUIMessage({
            action = 'openAtmLogin',
            locales = Locales[Config.Locale] or {}
        })
        isUiOpen = true
    end)
end

local function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local function SpawnBankNPC(bank)
    local blip = AddBlipForCoord(bank.coords.x, bank.coords.y, bank.coords.z)
    SetBlipSprite(blip, Config.Blip.Sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.Scale)
    SetBlipColour(blip, Config.Blip.Color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blip.Label)
    EndTextCommandSetBlipName(blip)

    local hash = LoadModel(bank.npcModel)
    local ped = CreatePed(4, hash, bank.coords.x, bank.coords.y, bank.coords.z - 1.0, bank.coords.w, false, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    table.insert(npcs, ped)
end

CreateThread(function()
    for _, bank in ipairs(Config.BankLocations) do
        SpawnBankNPC(bank)
    end

    Bridge.TriggerCallback('neva-banking:server:getDynamicLocations', function(dynLocations)
        if dynLocations then
            for _, bank in ipairs(dynLocations) do
                table.insert(Config.BankLocations, bank)
                SpawnBankNPC(bank)
            end
        end
    end)

    if Config.UseTarget then
        if Config.TargetSystem == 'qb-target' then
            exports['qb-target']:AddTargetModel(Config.ATMProps, {
                options = {
                    {
                        type = "client",
                        action = function()
                            OpenAtmUI()
                        end,
                        icon = "fas fa-credit-card",
                        label = _U('open_atm'),
                    }
                },
                distance = 1.5,
            })
        elseif Config.TargetSystem == 'ox_target' then
            exports.ox_target:addModel(Config.ATMProps, {
                {
                    name = 'atm_prop',
                    icon = 'fas fa-credit-card',
                    label = _U('open_atm'),
                    onSelect = function()
                        OpenAtmUI()
                    end,
                    distance = 1.5
                }
            })
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local pos = GetEntityCoords(PlayerPedId())

        for _, bank in ipairs(Config.BankLocations) do
            local dist = #(pos - vector3(bank.coords.x, bank.coords.y, bank.coords.z))
            if dist < 5.0 then
                sleep = 0
                DrawText3D(bank.coords.x, bank.coords.y, bank.coords.z + 1.0, _U('open_bank'))
                
                if dist < 2.0 and IsControlJustPressed(0, 38) then 
                    OpenBankUI()
                end
            end
        end

        Wait(sleep)
    end
end)

if not Config.UseTarget then
    CreateThread(function()
        while true do
            local sleep = 1000
            local pos = GetEntityCoords(PlayerPedId())
            local found = false

            for _, propHash in ipairs(Config.ATMProps) do
                local obj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 2.0, propHash, false, false, false)
                if DoesEntityExist(obj) then
                    sleep = 0
                    found = true
                    local objPos = GetEntityCoords(obj)
                    DrawText3D(objPos.x, objPos.y, objPos.z + 1.2, _U('open_atm'))

                    if IsControlJustPressed(0, 38) then 
                        OpenAtmUI()
                    end
                    break
                end
            end

            Wait(sleep)
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, ped in ipairs(npcs) do
        DeleteEntity(ped)
    end
    ClearTimecycleModifier()
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    ClearTimecycleModifier()
    isUiOpen = false
    cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
    Bridge.TriggerCallback('neva-banking:server:doDeposit', function(response)
        cb(response)
    end, data.amount)
end)

RegisterNUICallback('withdraw', function(data, cb)
    Bridge.TriggerCallback('neva-banking:server:doWithdraw', function(response)
        cb(response)
    end, data.amount)
end)

RegisterNUICallback('transfer', function(data, cb)
    Bridge.TriggerCallback('neva-banking:server:doTransfer', function(response)
        cb(response)
    end, data.target, data.amount)
end)

RegisterNUICallback('createCard', function(data, cb)
    Bridge.TriggerCallback('neva-banking:server:createCard', function(response)
        cb(response)
    end, data.card_name, data.pin)
end)

RegisterNUICallback('resetPin', function(data, cb)
    Bridge.TriggerCallback('neva-banking:server:resetPin', function(response)
        cb(response)
    end, data.current_pin, data.new_pin)
end)

RegisterNUICallback('loginAtm', function(data, cb)
    Bridge.TriggerCallback('neva-banking:server:checkPin', function(response)
        if not response.success then
            Bridge.Notify(_U('wrong_pin'), 'error')
        end
        cb(response)
    end, data.pin)
end)

RegisterNetEvent('neva-banking:client:openAdminMenu', function()
    local input = lib.inputDialog('Create Bank NPC', {
        {type = 'checkbox', label = 'Use Current Coordinates?', checked = true},
        {type = 'input', label = 'Or Custom Vector4', description = 'e.g. 149.2, -1040.6, 29.3, 340.0', required = false},
    })

    if not input then return end

    local useCurrentCoords = input[1]
    local customCoords = input[2]
    local coordsStr = ""

    if useCurrentCoords then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        coordsStr = string.format("%.2f, %.2f, %.2f, %.2f", pos.x, pos.y, pos.z, heading)
    else
        if not customCoords or customCoords == "" then
            Bridge.Notify('You must provide custom coordinates if you uncheck "Use Current Coordinates"', 'error')
            return
        end
        coordsStr = customCoords
    end

    TriggerServerEvent('neva-banking:server:addBankLocation', coordsStr)
end)

RegisterNetEvent('neva-banking:client:syncBankLocation', function(newLocation)
    table.insert(Config.BankLocations, newLocation)
    SpawnBankNPC(newLocation)
end)
