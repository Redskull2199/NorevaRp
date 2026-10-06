Citizen.CreateThread(function()
	while true do 
        Citizen.Wait(0)
        local ply = cache.ped
        SetPedSuffersCriticalHits(ply, false)

        -- Silah kontrolü için cache.weapon kullanımı
        local weapon = cache.weapon -- Silahı cache'den al
        if weapon then
            if IsPedArmed(ply, 6) then
                DisableControlAction(1, 140, true)
                DisableControlAction(1, 141, true)
                DisableControlAction(1, 142, true)
            elseif IsPedArmed(ply, 1) then
                N_0x4757f00bc6323cfe(GetHashKey("WEAPON_FLASHLIGHT"), 0.1)   
            else
                N_0x4757f00bc6323cfe(GetHashKey("WEAPON_UNARMED"), 0.35)
            end
            
            -- Silahın ateş edilip edilmediğini kontrol et
            if IsPedShooting(ply) then      
                local wep = weapon -- Cache'den alınan silah
                local _, cAmmo = GetAmmoInClip(ply, wep)

                local GamePlayCam = GetFollowPedCamViewMode()
                local Vehicled = IsPedInAnyVehicle(ply, false)
                local MovementSpeed = math.ceil(GetEntitySpeed(ply))

                if MovementSpeed > 69 then
                    MovementSpeed = 69
                end
                Citizen.Wait(50)

                if wep ~= 126349499 then
                    local group = GetWeapontypeGroup(wep)
                    local p = GetGameplayCamRelativePitch()
                    local cameraDistance = #(GetGameplayCamCoord() - GetEntityCoords(ply))

                    local recoil = math.random(100, 140 + MovementSpeed) / 100
                    local rifle = false

                    if group == 970310034 then
                        rifle = true
                    end

                    if cameraDistance < 5.3 then
                        cameraDistance = 1.5
                    else
                        if cameraDistance < 8.0 then
                            cameraDistance = 4.0
                        else
                            cameraDistance = 7.0
                        end
                    end

                    if Vehicled then
                        recoil = recoil + (recoil * cameraDistance)
                    else
                        recoil = recoil * 0.8
                    end

                    if GamePlayCam == 4 then
                        recoil = recoil * 0.7
                        if rifle then
                            recoil = recoil * 0.1
                        end
                    end

                    if rifle then
                        recoil = recoil * 0.7
                    end

                    local rightleft = math.random(4)
                    local h = GetGameplayCamRelativeHeading()
                    local hf = math.random(10, 40 + MovementSpeed) / 100

                    -- Silah kullanma yeteneği kontrolleri
                    local skillLevels = {}
                    for i = 0, 13, 6 do
                        exports["gamz-skillsystem"]:CheckSkill("Silah Kullanma Yeteneği", i, function(hasSkill)
                            skillLevels[i] = hasSkill
                        end)
                    end

                    if Vehicled then
                        hf = hf * 2.0
                    end

                    if rightleft == 1 then
                        SetGameplayCamRelativeHeading(h + hf)
                    elseif rightleft == 2 then
                        SetGameplayCamRelativeHeading(h - hf)
                    end 

                    for i = 13, 0, -1 do
                        if skillLevels[i] then
                            recoil = recoil / (2.3 - (i * 0.1))
                        end
                    end

                    local set = p + recoil
                    SetGameplayCamRelativePitch(set, 0.8)   
                    print(recoil)
                    exports["gamz-skillsystem"]:UpdateSkill("Silah Kullanma Yeteneği", 0.003) --0.003
                end
            end
        end
	end
end)
