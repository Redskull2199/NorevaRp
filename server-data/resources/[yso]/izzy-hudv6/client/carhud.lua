local L0_1, L1_1, L2_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L0_2 = current
  L0_2.inVehicle = true
  L0_2 = SendReactMessage
  L1_2 = "setVehicleDisplay"
  L2_2 = true
  L0_2(L1_2, L2_2)
  L0_2 = izzy
  L0_2 = L0_2.callback
  L1_2 = "izzy-hudv6:server:getSoundByPlate"
  L2_2 = GetVehicleNumberPlateText
  L3_2 = GetVehiclePedIsIn
  L4_2 = PlayerPedId
  L4_2 = L4_2()
  L5_2 = false
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L3_2(L4_2, L5_2)
  L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  L0_2 = L0_2(L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  if L0_2 then
    L1_2 = current
    L1_2.sound = L0_2
    L1_2 = L0_2.volume
    volume = L1_2
    L1_2 = L0_2.isPlaying
    if L1_2 then
      L1_2 = exports
      L1_2 = L1_2.xsound
      L2_2 = L1_2
      L1_2 = L1_2.PlayUrl
      L3_2 = L0_2.plate
      L4_2 = L0_2.url
      L5_2 = L0_2.volume
      L5_2 = L5_2 / 100
      L6_2 = false
      L1_2(L2_2, L3_2, L4_2, L5_2, L6_2)
      L1_2 = Wait
      L2_2 = 1000
      L1_2(L2_2)
      L1_2 = exports
      L1_2 = L1_2.xsound
      L2_2 = L1_2
      L1_2 = L1_2.setTimeStamp
      L3_2 = L0_2.plate
      L4_2 = L0_2.timeStamp
      L1_2(L2_2, L3_2, L4_2)
    else
      L1_2 = Wait
      L2_2 = 1000
      L1_2(L2_2)
    end
    L1_2 = SendReactMessage
    L2_2 = "setRadio"
    L3_2 = L0_2
    L1_2(L2_2, L3_2)
  end
  repeat
    L1_2 = Wait
    L2_2 = cfg
    L2_2 = L2_2.speedoInterval
    L1_2(L2_2)
    if not current.initialized or not current.inVehicle then break end
    L1_2 = PlayerPedId
    L1_2 = L1_2()
    L2_2 = GetVehiclePedIsIn
    L3_2 = L1_2
    L4_2 = false
    L2_2 = L2_2(L3_2, L4_2)
    if 0 ~= L2_2 then
      L3_2 = mathceil
      L4_2 = GetEntitySpeed
      L5_2 = L2_2
      L4_2 = L4_2(L5_2)
      L5_2 = current
      L5_2 = L5_2.settings
      L5_2 = L5_2.speedType
      if "kmh" == L5_2 then
        L5_2 = 3.6
        if L5_2 then
          goto lbl_79
        end
      end
      L5_2 = 2.236936
      ::lbl_79::
      L4_2 = L4_2 * L5_2
      L3_2 = L3_2(L4_2)
      L4_2 = mathround
      L5_2 = getFuel
      L6_2 = L2_2
      L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L5_2(L6_2)
      L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
      L5_2 = GetVehicleClass
      L6_2 = L2_2
      L5_2 = L5_2(L6_2)
      if 0 ~= L2_2 then
        L6_2 = getGear
        L7_2 = L2_2
        L6_2 = L6_2(L7_2)
        if L6_2 then
          goto lbl_98
        end
      end
      L6_2 = 0
      ::lbl_98::
      L7_2 = SendReactMessage
      L8_2 = "setVehicleData"
      L9_2 = {}
      if 14 == L5_2 then
        L10_2 = "boat"
        if L10_2 then
          goto lbl_115
        end
      end
      if 15 == L5_2 or 16 == L5_2 then
        L10_2 = "heli"
        if L10_2 then
          goto lbl_115
        end
      end
      L10_2 = nil
      ::lbl_115::
      L9_2.speedoType = L10_2
      L9_2.speed = L3_2
      L9_2.fuel = L4_2
      L10_2 = GetVehicleCurrentRpm
      L11_2 = L2_2
      L10_2 = L10_2(L11_2)
      L10_2 = L10_2 * 12
      L9_2.rpm = L10_2
      if 0 == L6_2 then
        L10_2 = "R"
        if L10_2 then
          goto lbl_136
        end
      end
      if 1 == L6_2 then
        L10_2 = "N"
        if L10_2 then
          goto lbl_136
        end
      end
      L10_2 = L6_2 - 1
      ::lbl_136::
      L9_2.previousGear = L10_2
      if 0 == L6_2 then
        L10_2 = "N"
        if L10_2 then
          goto lbl_143
        end
      end
      L10_2 = L6_2
      ::lbl_143::
      L9_2.currentGear = L10_2
      L10_2 = L6_2 + 1
      L11_2 = GetVehicleHighGear
      L12_2 = L2_2
      L11_2 = L11_2(L12_2)
      if L10_2 <= L11_2 then
        L10_2 = L6_2 + 1
        if L10_2 then
          goto lbl_168
        end
      end
      L10_2 = L6_2 + 1
      L11_2 = GetVehicleHighGear
      L12_2 = L2_2
      L11_2 = L11_2(L12_2)
      if L10_2 == L11_2 then
        L10_2 = GetVehicleHighGear
        L11_2 = L2_2
        L10_2 = L10_2(L11_2)
        if L10_2 then
          goto lbl_168
        end
      end
      L10_2 = ""
      ::lbl_168::
      L9_2.nextGear = L10_2
      L9_2.traction = "FWD"
      L10_2 = calculateTime
      L10_2 = L10_2()
      L9_2.time = L10_2
      L10_2 = GetIsVehicleEngineRunning
      L11_2 = L2_2
      L10_2 = L10_2(L11_2)
      L9_2.engineRunning = L10_2
      L10_2 = {}
      L11_2 = GetVehicleDashboardLights
      L11_2 = L11_2()
      if 128 ~= L11_2 then
        L11_2 = GetVehicleDashboardLights
        L11_2 = L11_2()
        if 256 ~= L11_2 then
          goto lbl_190
        end
      end
      L11_2 = 1
      ::lbl_190::
      if not L11_2 then
        L11_2 = GetVehicleDashboardLights
        L11_2 = L11_2()
        if 384 == L11_2 then
          L11_2 = 2
          if L11_2 then
            goto lbl_198
          end
        end
        L11_2 = 0
      end
      ::lbl_198::
      L10_2.headlights = L11_2
      L11_2 = getSeatbelt
      L12_2 = L2_2
      L11_2 = L11_2(L12_2)
      L10_2.seatbelt = L11_2
      L11_2 = tonumber
      L12_2 = mathfloor
      L13_2 = GetVehicleEngineHealth
      L14_2 = L2_2
      L13_2 = L13_2(L14_2)
      L13_2 = L13_2 / 10
      L12_2, L13_2, L14_2 = L12_2(L13_2)
      L11_2 = L11_2(L12_2, L13_2, L14_2)
      L10_2.engine = L11_2
      L9_2.lights = L10_2
      L7_2(L8_2, L9_2)
    end
    L3_2 = current
    L3_2 = L3_2.settings
    L3_2 = L3_2.cinematic
    if not L3_2 then
      L3_2 = DisplayRadar
      L4_2 = 1
      L3_2(L4_2)
    end
    L3_2 = current
    L3_2 = L3_2.inVehicle
  until not L3_2
  L1_2 = current
  L1_2 = L1_2.settings
  L1_2 = L1_2.alwaysShowMap
  if not L1_2 then
    L1_2 = DisplayRadar
    L2_2 = 0
    L1_2(L2_2)
  end
  L1_2 = current
  L1_2 = L1_2.sound
  if L1_2 then
    L1_2 = GetResourceState
    L2_2 = "xsound"
    L1_2 = L1_2(L2_2)
    if "started" == L1_2 then
      L1_2 = exports
      L1_2 = L1_2.xsound
      L2_2 = L1_2
      L1_2 = L1_2.soundExists
      L3_2 = current
      L3_2 = L3_2.sound
      L3_2 = L3_2.plate
      L1_2 = L1_2(L2_2, L3_2)
      if L1_2 then
        L1_2 = current
        L1_2 = L1_2.sound
        L1_2 = L1_2.musicId
        if L1_2 then
          L1_2 = current
          L1_2 = L1_2.sound
          L2_2 = exports
          L2_2 = L2_2.xsound
          L3_2 = L2_2
          L2_2 = L2_2.getTimeStamp
          L4_2 = current
          L4_2 = L4_2.sound
          L4_2 = L4_2.plate
          L2_2 = L2_2(L3_2, L4_2)
          L1_2.timeStamp = L2_2
          L1_2 = current
          L1_2 = L1_2.sound
          L2_2 = volume
          L1_2.volume = L2_2
          L1_2 = TriggerServerEvent
          L2_2 = "izzy-hudv6:server:updateSound"
          L3_2 = current
          L3_2 = L3_2.sound
          L4_2 = true
          L1_2(L2_2, L3_2, L4_2)
        end
        L1_2 = exports
        L1_2 = L1_2.xsound
        L2_2 = L1_2
        L1_2 = L1_2.Destroy
        L3_2 = current
        L3_2 = L3_2.sound
        L3_2 = L3_2.plate
        L1_2(L2_2, L3_2)
      end
      L1_2 = SendReactMessage
      L2_2 = "setRadio"
      L3_2 = nil
      L1_2(L2_2, L3_2)
      L1_2 = current
      L1_2.sound = nil
    end
  end
end
enteredVehicle = L0_1
function L0_1()
  local L0_2, L1_2, L2_2
  L0_2 = current
  L0_2.inVehicle = false
  L0_2 = SendReactMessage
  L1_2 = "setVehicleDisplay"
  L2_2 = false
  L0_2(L1_2, L2_2)
  L0_2 = current
  L0_2 = L0_2.settings
  L0_2 = L0_2.alwaysShowMap
  if not L0_2 then
    L0_2 = DisplayRadar
    L1_2 = 0
    L0_2(L1_2)
  end
end
leftVehicle = L0_1
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2, L2_2, L3_2
  while true do
    L0_2 = current
    L0_2 = L0_2.initialized
    if L0_2 then
      L0_2 = PlayerPedId
      L0_2 = L0_2()
      L1_2 = IsPedInAnyVehicle
      L2_2 = L0_2
      L3_2 = false
      L1_2 = L1_2(L2_2, L3_2)
      L2_2 = current
      L2_2 = L2_2.inVehicle
      if not L2_2 and L1_2 then
        L2_2 = TriggerEvent
        L3_2 = "izzy-hudv6:enteredVehicle"
        L2_2(L3_2)
        L2_2 = CreateThread
        L3_2 = enteredVehicle
        L2_2(L3_2)
      else
        L2_2 = current
        L2_2 = L2_2.inVehicle
        if not L2_2 or L1_2 then
          L2_2 = IsPlayerDead
          L3_2 = PlayerId
          L3_2 = L3_2()
          L2_2 = L2_2(L3_2)
          if not L2_2 then
            goto lbl_38
          end
        end
        L2_2 = leftVehicle
        L2_2()
      end
    end
    ::lbl_38::
    L0_2 = Wait
    L1_2 = 1000
    L0_2(L1_2)
  end
end
L0_1(L1_1)
L0_1 = cfg
L0_1 = L0_1.useMusicPlayer
if L0_1 then
  L0_1 = RegisterCommand
  L1_1 = cfg
  L1_1 = L1_1.musicCommand
  function L2_1()
    local L0_2, L1_2, L2_2
    L0_2 = current
    L0_2 = L0_2.inVehicle
    if L0_2 then
      L0_2 = SendReactMessage
      L1_2 = "setMusicDisplay"
      L2_2 = true
      L0_2(L1_2, L2_2)
      L0_2 = SetNuiFocus
      L1_2 = true
      L2_2 = true
      L0_2(L1_2, L2_2)
    end
  end
  L0_1(L1_1, L2_1)
end
