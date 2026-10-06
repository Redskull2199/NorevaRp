local isMuted = false
local muteReason = ""

RegisterNetEvent("wex-mute:setMute", function(state, expire, reason)
    isMuted = state
    muteReason = reason or ""

    if state then
        print("[MUTE] You are muted: " .. muteReason)
    else
        print("[MUTE] You are unmuted")
    end
end)

-- SAFE VOICE BLOCK (EN STABİL YÖNTEM)
CreateThread(function()
    while true do
        Wait(0)

        if isMuted then
            -- mic + konuşmayı bloklar
            DisableControlAction(0, 249, true) -- push to talk
            DisableControlAction(0, 244, true)

            -- voice sistemine “konuşmuyor” sinyali
            SetPlayerTalkingOverride(PlayerId(), false)
        end
    end
end)

-- küçük UI feedback (opsiyonel)
CreateThread(function()
    while true do
        Wait(1000)

        if isMuted then
            -- basit notify
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName("~r~MUTELİSİN: " .. muteReason)
            EndTextCommandThefeedPostTicker(false, false)
        end
    end
end)