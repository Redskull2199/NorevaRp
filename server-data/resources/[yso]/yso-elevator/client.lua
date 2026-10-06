-- Variables
local config = require 'config'
local isUIOpen = false
local textUIShown = false

-- Functions
local function Teleport(pos)
    if not pos then return end
    
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end
    
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    NewLoadSceneStart(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z, 50.0, 0)
    
    local timeout = GetGameTimer() + 2000
    while not IsNewLoadSceneLoaded() and GetGameTimer() < timeout do
        Wait(0)
    end
    
    if IsPedOnFoot(cache.ped) then
        SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, false, false, false, false)
    else
        SetPedCoordsKeepVehicle(cache.ped, pos.x, pos.y, pos.z)
    end
    
    timeout = GetGameTimer() + 2000
    while not HasCollisionLoadedAroundEntity(cache.ped) and GetGameTimer() < timeout do
        Wait(0)
    end

    if IsPedOnFoot(cache.ped) then
        SetEntityCoords(cache.ped, pos.x, pos.y, pos.z, false, false, false, false)
    else
        SetPedCoordsKeepVehicle(cache.ped, pos.x, pos.y, pos.z)
    end
    
    NewLoadSceneStop()
    NetworkFadeInEntity(cache.ped, true)
    
    DoScreenFadeIn(500)
    while not IsScreenFadedIn() do
        Wait(0)
    end
end

local function OpenUI(currentFloor, floors)
    if isUIOpen then return end
    
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'SHOW_UI',
        current = currentFloor,
        floors = floors
    })
    
    if textUIShown then
        lib.hideTextUI()
        textUIShown = false
    end
end

local function CloseUI()
    if not isUIOpen then return end
    
    isUIOpen = false
    SetNuiFocus(false, false)
end

-- NUI Callbacks
RegisterNUICallback('CLOSE_UI', function(data, cb)
    CloseUI()
    cb('ok')
end)

RegisterNUICallback('TELEPORT', function(data, cb)
    if data.pos then
        Teleport(data.pos)
    end
    cb('ok')
end)

RegisterNUICallback('USE_ELEVATOR', function(data, cb)
    NetworkFadeOutEntity(cache.ped, true, false)
    DoScreenFadeOut(1000)
    cb('ok')
end)

-- Setup elevator points
local function SetupElevatorPoints()
    for elevatorName, elevatorData in pairs(config.elevators) do
        for _, floor in ipairs(elevatorData) do
            local point = lib.points.new({
                coords = floor.pos,
                distance = config.interact_dist,
                floorNumber = floor.number,
                elevatorFloors = elevatorData,
                elevatorName = elevatorName
            })
            
            function point:onEnter()
                if not isUIOpen then
                    lib.showTextUI(config.texts.open, {
                        position = "left-center",
                        icon = 'elevator'
                    })
                    textUIShown = true
                end
            end
            
            function point:onExit()
                if textUIShown then
                    lib.hideTextUI()
                    textUIShown = false
                end
            end
            
            function point:nearby()
                if self.currentDistance < config.interact_dist then
                    if IsControlJustReleased(0, config.key) and not isUIOpen then
                        OpenUI(self.floorNumber, self.elevatorFloors)
                    end
                end
            end
        end
    end
end

-- Initialize
CreateThread(function()
    SetupElevatorPoints()
end)

-- Handler
AddEventHandler('onResourceStop', function(resourceName)
    if cache.ped ~= resourceName then return end
    if textUIShown then lib.hideTextUI() end
    if isUIOpen then CloseUI() end
end)