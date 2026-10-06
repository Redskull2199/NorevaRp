local MODEL = 'KillerGodzilla'
local LABEL = 'KillerGodzilla'

Citizen.CreateThread(function()
    if not DoesTextLabelExist(MODEL) then
        AddTextEntry(MODEL, LABEL)
    end
end)
