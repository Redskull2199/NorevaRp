RegisterNetEvent("arackontrl")
AddEventHandler("arackontrl", function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        return
    end

    TriggerServerEvent("banatmapunch")
end)
