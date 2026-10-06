PulseV = PulseV or {}
PulseV.Teleport = {}
local function failure(code, message) return {code=code,message=message} end
local function finite(value) return type(value)=='number' and value==value and math.abs(value)<math.huge end

function PulseV.Teleport.new(natives, config)
    config = config or PulseV.Config
    local active
    local teleport = {}
    local function finish(operation, ok, err, rollback)
        if operation.finished then return end
        operation.finished = true
        if active == operation then active = nil end
        if rollback and operation.moved then
            pcall(natives.SetEntityCoordsNoOffset, operation.ped, operation.origin.x, operation.origin.y, operation.origin.z, false, false, false)
            pcall(natives.SetEntityHeading, operation.ped, operation.heading)
        end
        pcall(natives.FreezeEntityPosition, operation.ped, false)
        pcall(natives.DoScreenFadeIn, 150)
        operation.done(ok, err)
    end
    function teleport:cleanup(reason)
        if active then finish(active, false, failure('cancelled', reason or 'Işınlanma iptal edildi.'), true) end
    end
    function teleport:start(target, done)
        if active then done(false, failure('busy','Işınlanma zaten sürüyor.')); return false end
        if type(target)~='table' or not finite(target.x) or not finite(target.y) or not finite(target.z)
            or math.abs(target.x)>20000 or math.abs(target.y)>20000 or target.z < -2000 or target.z > 4000 then
            done(false, failure('invalid_target','Geçersiz hedef.')); return false
        end
        local ped = natives.PlayerPedId()
        if not ped or ped == 0 or not natives.DoesEntityExist(ped) or natives.IsPedInAnyVehicle(ped, false) then
            done(false, failure('in_vehicle','Işınlanmak için araçtan inin.')); return false
        end
        local origin = natives.GetEntityCoords(ped)
        local operation = {ped=ped,origin={x=origin.x,y=origin.y,z=origin.z},heading=natives.GetEntityHeading(ped),done=done}
        active = operation
        natives.CreateThread(function()
            if operation.finished then return end
            local ok, err = pcall(function()
                natives.DoScreenFadeOut(150)
                natives.FreezeEntityPosition(ped, true)
                natives.RequestCollisionAtCoord(target.x, target.y, target.z)
                operation.moved = true
                natives.SetEntityCoordsNoOffset(ped, target.x, target.y, target.z, false, false, false)
                local start = natives.GetGameTimer()
                while not operation.finished do
                    if not natives.DoesEntityExist(ped) then error('ped_unavailable') end
                    if natives.HasCollisionLoadedAroundEntity(ped) then
                        finish(operation, true); return
                    end
                    if (natives.GetGameTimer()-start)%4294967296 >= (config.TeleportTimeout or 5000) then
                        finish(operation, false, failure('teleport_timeout','Hedef yüklenemedi; önceki konuma dönüldü.'), true)
                        return
                    end
                    natives.RequestCollisionAtCoord(target.x, target.y, target.z)
                    natives.Wait(50)
                end
            end)
            if not ok then finish(operation, false, failure('teleport_failed','Işınlanma tamamlanamadı.'), true) end
        end)
        return true
    end
    return teleport
end
