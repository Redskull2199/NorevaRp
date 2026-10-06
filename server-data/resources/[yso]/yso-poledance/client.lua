local currentNumber = 0

FishyDEV = false

CreateThread(function()
    while true do
        sleep = 1000
        if Config['PoleDance']['Enabled'] then
            for k, v in pairs(Config['PoleDance']['Locations']) do
                if #(GetEntityCoords(PlayerPedId()) - v['Position']) <= 1.0 then
                    sleep = 5
                    ShowFloatingHelpNotification("[~p~E~w~] Dans", v["Position"], 1.0)
                    if IsControlJustReleased(0, 51) and not FishyDEV then
                        FishyDEV = true
                        LoadDict('mini@strip_club@pole_dance@pole_dance' .. v['Number'])
                        local scene = NetworkCreateSynchronisedScene(v['Position'], vector3(0.0, 0.0, 0.0), 2, false, true, 1065353216, 0, 1.3)
                        NetworkAddPedToSynchronisedScene(PlayerPedId(), scene, 'mini@strip_club@pole_dance@pole_dance' .. v['Number'], 'pd_dance_0' .. v['Number'], 1.5, -4.0, 1, 1, 1148846080, 0)
                        NetworkStartSynchronisedScene(scene)
                        currentNumber = v["Number"]
                    elseif IsControlJustReleased(0, 51) and FishyDEV then
                        FishyDEV = false
                        ClearPedTasksImmediately(PlayerPedId())
                    elseif IsControlJustReleased(0, 73) and FishyDEV then
                        FishyDEV = false
                        ClearPedTasksImmediately(PlayerPedId())
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function ShowFloatingHelpNotification(msg, coords,r)
    AddTextEntry('FloatingHelpNotification'..'_'..r, msg)
    SetFloatingHelpTextWorldPosition(1, coords.x,coords.y,coords.z + 0.2)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('FloatingHelpNotification'..'_'..r)
    EndTextCommandDisplayHelp(2, false, false, -1)
end

LoadDict = function(Dict)
    while not HasAnimDictLoaded(Dict) do 
        Wait(0)
        RequestAnimDict(Dict)
    end
end