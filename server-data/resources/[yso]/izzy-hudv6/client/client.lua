local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
L0_1 = math
L0_1 = L0_1.floor
L1_1 = math
L1_1 = L1_1.random
L2_1 = math
L2_1 = L2_1.ceil
L3_1 = math
L3_1 = L3_1.round
mathround = L3_1
mathceil = L2_1
mathrandom = L1_1
mathfloor = L0_1
L0_1 = {}
L0_1.initialized = false
L0_1.inVehicle = false
L0_1.stress = 0
L1_1 = {}
L0_1.settings = L1_1
L1_1 = {}
L0_1.sound = L1_1
current = L0_1
function L0_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = SendNUIMessage
  L3_2 = {}
  L3_2.action = A0_2
  L3_2.data = A1_2
  L2_2(L3_2)
end
SendReactMessage = L0_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  local citizenid = framework == 'qb' and plyData.citizenid
  local function isSessionActive()
    return framework ~= 'qb' or (citizenid and plyData.citizenid == citizenid and LocalPlayer.state.isLoggedIn)
  end
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
  if not isSessionActive() then return end
  L0_2 = izzy
  L0_2 = L0_2.debug
  L1_2 = "Langs initializing!"
  L0_2(L1_2)
  L0_2 = SendReactMessage
  L1_2 = "setLang"
  L2_2 = cfg
  L2_2 = L2_2.locales
  L3_2 = cfg
  L3_2 = L3_2.locale
  L2_2 = L2_2[L3_2]
  L0_2(L1_2, L2_2)
  L0_2 = izzy
  L0_2 = L0_2.debug
  L1_2 = "Langs initialized!"
  L0_2(L1_2)
  L0_2 = Wait
  L1_2 = 100
  L0_2(L1_2)
  if not isSessionActive() then return end
  L0_2 = izzy
  L0_2 = L0_2.debug
  L1_2 = "Server details and player settings initializing!"
  L0_2(L1_2)
  L0_2 = json
  L0_2 = L0_2.decode
  L1_2 = GetResourceKvpString
  L2_2 = "settings"
  L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L1_2(L2_2)
  L0_2 = L0_2(L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  L0_2 = not L0_2
  if not L0_2 then
    L1_2 = json
    L1_2 = L1_2.decode
    L2_2 = GetResourceKvpString
    L3_2 = "settings"
    L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L2_2(L3_2)
    L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
    if L1_2 then
      goto lbl_46
    end
  end
  L1_2 = cfg
  L1_2 = L1_2.defaultSettings
  ::lbl_46::
  if L0_2 then
    L2_2 = pairs
    L3_2 = cfg
    L3_2 = L3_2.status
    L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
    for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
      L8_2 = L1_2.statusColors
      L9_2 = L7_2.name
      L10_2 = cfg
      L10_2 = L10_2.colors
      L11_2 = L7_2.color
      L10_2 = L10_2[L11_2]
      if not L10_2 then
        L10_2 = cfg
        L10_2 = L10_2.colors
        L10_2 = L10_2.theme
      end
      L8_2[L9_2] = L10_2
    end
  end
  L2_2 = SendReactMessage
  L3_2 = "setData"
  L4_2 = {}
  L5_2 = cfg
  L5_2 = L5_2.showTopInfos
  L4_2.showTopInfos = L5_2
  L5_2 = cfg
  L5_2 = L5_2.showServerImage
  L4_2.showServerImage = L5_2
  L5_2 = cfg
  L5_2 = L5_2.serverName
  L4_2.serverName = L5_2
  L5_2 = cfg
  L5_2 = L5_2.serverDesc
  L4_2.serverDesc = L5_2
  L5_2 = cfg
  L5_2 = L5_2.useRealTime
  L4_2.useRealTime = L5_2
  L5_2 = cfg
  L5_2 = L5_2.useMinimapBorder
  L4_2.useMinimapBorder = L5_2
  L5_2 = cfg
  L5_2 = L5_2.showCompass
  L4_2.showCompass = L5_2
  L5_2 = cfg
  L5_2 = L5_2.showLocation
  L4_2.showLocation = L5_2
  L5_2 = cfg
  L5_2 = L5_2.notifyStyle
  L4_2.notifyStyle = L5_2
  L5_2 = cfg
  L5_2 = L5_2.notifyPosition
  L4_2.notifyPosition = L5_2
  L5_2 = cfg
  L5_2 = L5_2.currency
  L4_2.currency = L5_2
  L5_2 = cfg
  L5_2 = L5_2.colors
  L4_2.colors = L5_2
  L4_2.settings = L1_2
  L2_2(L3_2, L4_2)
  L2_2 = Wait
  L3_2 = 500
  L2_2(L3_2)
  if not isSessionActive() then return end
  L2_2 = current
  L2_2.settings = L1_2
  L2_2 = izzy
  L2_2 = L2_2.debug
  L3_2 = "Server details and player settings initialized!"
  L2_2(L3_2)
  L2_2 = Wait
  L3_2 = 100
  L2_2(L3_2)
  if not isSessionActive() then return end
  L2_2 = current
  L2_2.initialized = true
  L2_2 = SendReactMessage
  L3_2 = "setDisplay"
  L4_2 = current
  L4_2 = L4_2.initialized
  L2_2(L3_2, L4_2)
  L2_2 = Wait
  L3_2 = 100
  L2_2(L3_2)
  if not isSessionActive() then return end
  L2_2 = izzy
  L2_2 = L2_2.debug
  L3_2 = "Status initializing!"
  L2_2(L3_2)
  L2_2 = 1
  L3_2 = cfg
  L3_2 = L3_2.status
  L3_2 = #L3_2
  L4_2 = 1
  for L5_2 = L2_2, L3_2, L4_2 do
    L6_2 = cfg
    L6_2 = L6_2.status
    L6_2 = L6_2[L5_2]
    L7_2 = getStatus
    L8_2 = cfg
    L8_2 = L8_2.status
    L8_2 = L8_2[L5_2]
    L8_2 = L8_2.name
    L7_2 = L7_2(L8_2)
    L6_2.value = L7_2
  end
  L2_2 = SendReactMessage
  L3_2 = "setStatus"
  L4_2 = cfg
  L4_2 = L4_2.status
  L2_2(L3_2, L4_2)
  L2_2 = Wait
  L3_2 = 100
  L2_2(L3_2)
  if not isSessionActive() then return end
  L2_2 = izzy
  L2_2 = L2_2.debug
  L3_2 = "Top infos initializing!"
  L2_2(L3_2)
  L2_2 = 1
  L3_2 = cfg
  L3_2 = L3_2.topInfos
  L3_2 = #L3_2
  L4_2 = 1
  for L5_2 = L2_2, L3_2, L4_2 do
    L6_2 = cfg
    L6_2 = L6_2.topInfos
    L7_2 = getTopInfo
    L8_2 = cfg
    L8_2 = L8_2.topInfos
    L8_2 = L8_2[L5_2]
    L7_2 = L7_2(L8_2)
    L6_2[L5_2] = L7_2
  end
  L2_2 = SendReactMessage
  L3_2 = "setTopInfos"
  L4_2 = cfg
  L4_2 = L4_2.topInfos
  L2_2(L3_2, L4_2)
  L2_2 = izzy
  L2_2 = L2_2.debug
  L3_2 = "Top infos initialized!"
  L2_2(L3_2)
  L2_2 = Wait
  L3_2 = 100
  L2_2(L3_2)
  if not isSessionActive() then return end
  L2_2 = map
  L3_2 = current
  L3_2 = L3_2.settings
  L3_2 = L3_2.mapStyle
  L2_2(L3_2)
  if not isSessionActive() then return end
  L2_2 = current
  L3_2 = izzy
  L3_2 = L3_2.callback
  L4_2 = "izzy-hudv6:getStress"
  L3_2 = L3_2(L4_2)
  if not isSessionActive() then return end
  L2_2.stress = L3_2
  L2_2 = GetActiveScreenResolution
  L2_2, L3_2 = L2_2()
  L4_2 = SendReactMessage
  L5_2 = "setXOffset"
  L6_2 = getMinimapAnchor
  L6_2 = L6_2()
  L6_2 = L6_2.x
  L6_2 = L2_2 * L6_2
  L7_2 = current
  L7_2 = L7_2.settings
  L7_2 = L7_2.mapStyle
  if "circle" == L7_2 then
    L7_2 = 9.0
    if L7_2 then
      goto lbl_221
    end
  end
  L7_2 = 0
  ::lbl_221::
  L6_2 = L6_2 + L7_2
  L4_2(L5_2, L6_2)
end
initialize = L0_1
function L0_1()
  local L0_2, L1_2, L2_2
  L0_2 = current
  L0_2.initialized = false
  current.inVehicle = false
  current.stress = 0
  seatbeltOn = false
  SendReactMessage('setVehicleDisplay', false)
  L0_2 = SendReactMessage
  L1_2 = "setDisplay"
  L2_2 = current
  L2_2 = L2_2.initialized
  L0_2(L1_2, L2_2)
  L0_2 = DisplayRadar
  L1_2 = 0
  L0_2(L1_2)
end
unloadData = L0_1
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L0_2 = SetNuiFocus
  L1_2 = false
  L0_2(L1_2)
  L0_2 = DisplayRadar
  L1_2 = 0
  L0_2(L1_2)
  while true do
    L0_2 = current
    L0_2 = L0_2.initialized
    if L0_2 then
      L0_2 = PlayerPedId
      L0_2 = L0_2()
      L1_2 = GetSelectedPedWeapon
      L2_2 = L0_2
      L1_2 = L1_2(L2_2)
      L2_2 = izzy
      L2_2 = L2_2.weapons
      L2_2 = L2_2[L1_2]
      L3_2 = 1
      L4_2 = cfg
      L4_2 = L4_2.status
      L4_2 = #L4_2
      L5_2 = 1
      for L6_2 = L3_2, L4_2, L5_2 do
        L7_2 = cfg
        L7_2 = L7_2.status
        L7_2 = L7_2[L6_2]
        L8_2 = L7_2.name
        if "mic" == L8_2 then
          L8_2 = getVoiceState
          L8_2 = L8_2()
          L8_2 = L8_2.talking
          L7_2.active = L8_2
        end
        L8_2 = cfg
        L8_2 = L8_2.status
        L8_2 = L8_2[L6_2]
        L9_2 = mathfloor
        L10_2 = getStatus
        L11_2 = L7_2.name
        L10_2, L11_2 = L10_2(L11_2)
        L9_2 = L9_2(L10_2, L11_2)
        L8_2.value = L9_2
      end
      if L1_2 and -1569615261 ~= L1_2 and L2_2 then
        L3_2 = GetAmmoInClip
        L4_2 = L0_2
        L5_2 = L1_2
        L3_2, L4_2 = L3_2(L4_2, L5_2)
        L5_2 = SendReactMessage
        L6_2 = "setWeapon"
        L7_2 = {}
        L7_2.current = L4_2
        L8_2 = GetAmmoInPedWeapon
        L9_2 = L0_2
        L10_2 = L1_2
        L8_2 = L8_2(L9_2, L10_2)
        L8_2 = L8_2 - L4_2
        L7_2.total = L8_2
        if L2_2 then
          L8_2 = L2_2.name
          L9_2 = L8_2
          L8_2 = L8_2.lower
          L8_2 = L8_2(L9_2)
          if L8_2 then
            goto lbl_75
          end
        end
        L8_2 = "WEAPON_ASSAULTRIFLE"
        ::lbl_75::
        L7_2.name = L8_2
        if L2_2 then
          L8_2 = L2_2.label
          if L8_2 then
            goto lbl_82
          end
        end
        L8_2 = "Assault Rifle"
        ::lbl_82::
        L7_2.label = L8_2
        L5_2(L6_2, L7_2)
      else
        L3_2 = SendReactMessage
        L4_2 = "setWeapon"
        L5_2 = {}
        L3_2(L4_2, L5_2)
      end
      L3_2 = SetRadarBigmapEnabled
      L4_2 = false
      L5_2 = false
      L3_2(L4_2, L5_2)
      L3_2 = SetRadarZoom
      L4_2 = cfg
      L4_2 = L4_2.minimapScale
      L3_2(L4_2)
      L3_2 = SendReactMessage
      L4_2 = "setStatus"
      L5_2 = cfg
      L5_2 = L5_2.status
      L3_2(L4_2, L5_2)
    end
    L0_2 = Wait
    L1_2 = cfg
    L1_2 = L1_2.statusInterval
    L0_2(L1_2)
  end
end
L0_1(L1_1)
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  while true do
    L0_2 = current
    L0_2 = L0_2.initialized
    if L0_2 then
      L0_2 = 1
      L1_2 = cfg
      L1_2 = L1_2.topInfos
      L1_2 = #L1_2
      L2_2 = 1
      for L3_2 = L0_2, L1_2, L2_2 do
        L4_2 = cfg
        L4_2 = L4_2.topInfos
        L5_2 = getTopInfo
        L6_2 = cfg
        L6_2 = L6_2.topInfos
        L6_2 = L6_2[L3_2]
        L5_2 = L5_2(L6_2)
        L4_2[L3_2] = L5_2
      end
      L0_2 = SendReactMessage
      L1_2 = "setTopInfos"
      L2_2 = cfg
      L2_2 = L2_2.topInfos
      L0_2(L1_2, L2_2)
      L0_2 = SendReactMessage
      L1_2 = "setVisibility"
      L2_2 = IsPauseMenuActive
      L2_2 = L2_2()
      L2_2 = not L2_2
      L0_2(L1_2, L2_2)
      L0_2 = current
      L0_2 = L0_2.settings
      L0_2 = L0_2.cinematic
      if L0_2 then
        L0_2 = DisplayRadar
        L1_2 = 0
        L0_2(L1_2)
      else
        L0_2 = current
        L0_2 = L0_2.settings
        L0_2 = L0_2.mapVisibility
        if "always" ~= L0_2 then
          L0_2 = current
          L0_2 = L0_2.inVehicle
          if not L0_2 then
            goto lbl_52
          end
        end
        L0_2 = DisplayRadar
        L1_2 = 1
        L0_2(L1_2)
      end
    end
    ::lbl_52::
    L0_2 = Wait
    L1_2 = cfg
    L1_2 = L1_2.topInfosInterval
    L0_2(L1_2)
  end
end
L0_1(L1_1)
L0_1 = 0
L1_1 = {}
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = GetGameTimer
  L1_2 = L1_2()
  L2_2 = L0_1
  L2_2 = L1_2 - L2_2
  L3_2 = 1500
  if L2_2 > L3_2 then
    L2_2 = GetEntityCoords
    L3_2 = A0_2
    L2_2 = L2_2(L3_2)
    L3_2 = GetStreetNameAtCoord
    L4_2 = L2_2.x
    L5_2 = L2_2.y
    L6_2 = L2_2.z
    L3_2, L4_2 = L3_2(L4_2, L5_2, L6_2)
    L0_1 = L1_2
    L5_2 = {}
    L6_2 = GetStreetNameFromHashKey
    L7_2 = L3_2
    L6_2 = L6_2(L7_2)
    L7_2 = GetStreetNameFromHashKey
    L8_2 = L4_2
    L7_2, L8_2 = L7_2(L8_2)
    L5_2[1] = L6_2
    L5_2[2] = L7_2
    L5_2[3] = L8_2
    L1_1 = L5_2
  end
  L2_2 = L1_1
  return L2_2
end
L3_1 = CreateThread
function L4_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L0_2 = 1
  L1_2 = "0"
  while true do
    L2_2 = cfg
    L2_2 = L2_2.showCompass
    if not L2_2 then
      break
    end
    L2_2 = current
    L2_2 = L2_2.initialized
    if L2_2 then
      L2_2 = GetGameplayCamRot
      L3_2 = 0
      L2_2 = L2_2(L3_2)
      L3_2 = tostring
      L4_2 = mathfloor
      L5_2 = L2_2.z
      L5_2 = L5_2 + 360.0
      L5_2 = L5_2 % 360.0
      L6_2 = 360.0
      L5_2 = L6_2 - L5_2
      L4_2, L5_2, L6_2 = L4_2(L5_2)
      L3_2 = L3_2(L4_2, L5_2, L6_2)
      L1_2 = L3_2
      L3_2 = SendReactMessage
      L4_2 = "setLocation"
      L5_2 = {}
      L6_2 = cfg
      L6_2 = L6_2.showCompass
      L6_2 = L1_2 or L6_2
      L6_2 = L0_2 or L6_2
      if not L6_2 or (L1_2 == L0_2 or not L1_2) and not L0_2 then
        L6_2 = "0"
      end
      L5_2.heading = L6_2
      L6_2 = getDirection
      L6_2 = L6_2()
      L5_2.direction = L6_2
      L6_2 = current
      L6_2 = L6_2.inVehicle
      L5_2.inVehicle = L6_2
      L3_2(L4_2, L5_2)
    end
    L2_2 = Wait
    L3_2 = cfg
    L3_2 = L3_2.locationInterval
    L2_2(L3_2)
  end
end
L3_1(L4_1)
L3_1 = CreateThread
function L4_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  while true do
    L0_2 = current
    L0_2 = L0_2.initialized
    if L0_2 then
      L0_2 = cfg
      L0_2 = L0_2.showLocation
      if not L0_2 then
        L0_2 = current
        L0_2 = L0_2.settings
        L0_2 = L0_2.statusStyle
        if 7 ~= L0_2 then
          goto lbl_36
        end
      end
      L0_2 = SendReactMessage
      L1_2 = "setLocation"
      L2_2 = {}
      L3_2 = L2_1
      L4_2 = PlayerPedId
      L4_2, L5_2, L6_2 = L4_2()
      L3_2 = L3_2(L4_2, L5_2, L6_2)
      L3_2 = L3_2[1]
      L4_2 = " "
      L5_2 = L2_1
      L6_2 = PlayerPedId
      L6_2 = L6_2()
      L5_2 = L5_2(L6_2)
      L5_2 = L5_2[2]
      L3_2 = L3_2 .. L4_2 .. L5_2
      L2_2.street = L3_2
      L3_2 = calculateTime
      L3_2 = L3_2()
      L2_2.time = L3_2
      L0_2(L1_2, L2_2)
      goto lbl_39
      ::lbl_36::
      L0_2 = Wait
      L1_2 = 1000
      L0_2(L1_2)
    end
    ::lbl_39::
    L0_2 = Wait
    L1_2 = 1000
    L0_2(L1_2)
  end
end
L3_1(L4_1)
function L3_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2
  L4_2 = SendReactMessage
  L5_2 = "addNotification"
  L6_2 = {}
  if "error" == A0_2 then
    L7_2 = "error"
    if L7_2 then
      goto lbl_16
    end
  end
  if "success" == A0_2 then
    L7_2 = "success"
    if L7_2 then
      goto lbl_16
    end
  end
  L7_2 = "inform"
  ::lbl_16::
  L6_2.type = L7_2
  L6_2.str = A2_2
  L7_2 = A3_2 or L7_2
  if not A3_2 then
    L7_2 = 5000
  end
  L6_2.duration = L7_2
  L6_2.title = A1_2
  L4_2(L5_2, L6_2)
end
addNotification = L3_1
L3_1 = exports
L4_1 = "addNotification"
L5_1 = addNotification
L3_1(L4_1, L5_1)
L3_1 = RegisterNetEvent
L4_1 = "izzy-hudv6:client:addNotification"
L5_1 = addNotification
L3_1(L4_1, L5_1)
L3_1 = RegisterCommand
L4_1 = "notify"
function L5_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = addNotification
  L1_2 = "success"
  L2_2 = "Izzy"
  L3_2 = "Izzy Shop"
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = Wait
  L1_2 = 100
  L0_2(L1_2)
  L0_2 = addNotification
  L1_2 = "inform"
  L2_2 = "Izzy"
  L3_2 = "Izzy Shop"
  L0_2(L1_2, L2_2, L3_2)
  L0_2 = Wait
  L1_2 = 100
  L0_2(L1_2)
  L0_2 = addNotification
  L1_2 = "error"
  L2_2 = "Izzy"
  L3_2 = "Izzy Shop"
  L0_2(L1_2, L2_2, L3_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "reset"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = cfg
  L2_2 = L2_2.defaultSettings
  L3_2 = current
  L3_2.settings = L2_2
  L3_2 = pairs
  L4_2 = cfg
  L4_2 = L4_2.status
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = current
    L9_2 = L9_2.settings
    L9_2 = L9_2.statusColors
    L10_2 = L8_2.name
    L11_2 = cfg
    L11_2 = L11_2.colors
    L12_2 = L8_2.color
    L11_2 = L11_2[L12_2]
    if not L11_2 then
      L11_2 = cfg
      L11_2 = L11_2.colors
      L11_2 = L11_2.theme
    end
    L9_2[L10_2] = L11_2
  end
  L3_2 = SendReactMessage
  L4_2 = "clearLocalStorage"
  L3_2(L4_2)
  L3_2 = SendReactMessage
  L4_2 = "setData"
  L5_2 = {}
  L5_2.settings = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = SendReactMessage
  L4_2 = "setDisplay"
  L5_2 = false
  L3_2(L4_2, L5_2)
  L3_2 = Wait
  L4_2 = 500
  L3_2(L4_2)
  L3_2 = SendReactMessage
  L4_2 = "setDisplay"
  L5_2 = true
  L3_2(L4_2, L5_2)
  L3_2 = SetResourceKvp
  L4_2 = "settings"
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = L2_2
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2 = L5_2(L6_2)
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "updateData"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L2_2 = pairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = current
    L8_2 = L8_2.settings
    L8_2[L6_2] = L7_2
    if "mapVisibility" == L6_2 or "mapStyle" == L6_2 then
      L8_2 = map
      L9_2 = current
      L9_2 = L9_2.settings
      L9_2 = L9_2.mapStyle
      L8_2(L9_2)
      L8_2 = GetActiveScreenResolution
      L8_2, L9_2 = L8_2()
      L10_2 = SendReactMessage
      L11_2 = "setXOffset"
      L12_2 = getMinimapAnchor
      L12_2 = L12_2()
      L12_2 = L12_2.x
      L12_2 = L8_2 * L12_2
      L13_2 = current
      L13_2 = L13_2.settings
      L13_2 = L13_2.mapStyle
      if "circle" == L13_2 then
        L13_2 = 9.0
        if L13_2 then
          goto lbl_35
        end
      end
      L13_2 = 0
      ::lbl_35::
      L12_2 = L12_2 + L13_2
      L10_2(L11_2, L12_2)
    end
  end
  L2_2 = SetResourceKvp
  L3_2 = "settings"
  L4_2 = json
  L4_2 = L4_2.encode
  L5_2 = current
  L5_2 = L5_2.settings
  L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = L4_2(L5_2)
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
  L2_2 = A1_2
  L3_2 = {}
  L4_2 = "ok"
  L3_2[1] = L4_2
  L2_2(L3_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "getStatus"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = A1_2
  L3_2 = cfg
  L3_2 = L3_2.status
  L2_2(L3_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "close"
function L5_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = SetNuiFocus
  L3_2 = false
  L4_2 = false
  L2_2(L3_2, L4_2)
  L2_2 = SendReactMessage
  L3_2 = "setSettingsDisplay"
  L4_2 = false
  L2_2(L3_2, L4_2)
  L2_2 = SendReactMessage
  L3_2 = "setMusicDisplay"
  L4_2 = false
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = {}
  L4_2 = "ok"
  L3_2[1] = L4_2
  L2_2(L3_2)
end
L3_1(L4_1, L5_1)
L3_1 = cfg
L3_1 = L3_1.useSettings
if L3_1 then
  L3_1 = RegisterCommand
  L4_1 = cfg
  L4_1 = L4_1.settingsCommand
  function L5_1()
    local L0_2, L1_2, L2_2
    L0_2 = SendReactMessage
    L1_2 = "setSettingsDisplay"
    L2_2 = true
    L0_2(L1_2, L2_2)
    L0_2 = SetNuiFocus
    L1_2 = true
    L2_2 = true
    L0_2(L1_2, L2_2)
  end
  L3_1(L4_1, L5_1)
end
L3_1 = cfg
L3_1 = L3_1.useMusicPlayer
if L3_1 then
  L3_1 = RegisterCommand
  L4_1 = cfg
  L4_1 = L4_1.musicCommand
  function L5_1()
    local L0_2, L1_2, L2_2
    L0_2 = current
    L0_2 = L0_2.inVehicle
    if not L0_2 then
      return
    end
    L0_2 = SendReactMessage
    L1_2 = "setMusicDisplay"
    L2_2 = true
    L0_2(L1_2, L2_2)
    L0_2 = SetNuiFocus
    L1_2 = true
    L2_2 = true
    L0_2(L1_2, L2_2)
  end
  L3_1(L4_1, L5_1)
  L3_1 = RegisterCommand
  L4_1 = cfg
  L4_1 = L4_1.focusCommand
  function L5_1()
    local L0_2, L1_2, L2_2
    L0_2 = current
    L0_2 = L0_2.inVehicle
    if not L0_2 then
      return
    end
    L0_2 = SetNuiFocus
    L1_2 = true
    L2_2 = true
    L0_2(L1_2, L2_2)
  end
  L3_1(L4_1, L5_1)
end
function L3_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L0_2 = GetSafeZoneSize
  L0_2 = L0_2()
  L1_2 = 0.05
  L2_2 = 0.05
  L3_2 = GetAspectRatio
  L4_2 = 0
  L3_2 = L3_2(L4_2)
  L4_2 = GetActiveScreenResolution
  L4_2, L5_2 = L4_2()
  L6_2 = 1.0
  L6_2 = L6_2 / L4_2
  L7_2 = 1.0
  L7_2 = L7_2 / L5_2
  L8_2 = {}
  L9_2 = 4 * L3_2
  L9_2 = L4_2 / L9_2
  L9_2 = L6_2 * L9_2
  L8_2.width = L9_2
  L9_2 = L5_2 / 5.674
  L9_2 = L7_2 * L9_2
  L8_2.height = L9_2
  L9_2 = math
  L9_2 = L9_2.abs
  L10_2 = L0_2 - 1.0
  L9_2 = L9_2(L10_2)
  L9_2 = L9_2 * 10
  L9_2 = L1_2 * L9_2
  L9_2 = L4_2 * L9_2
  L9_2 = L6_2 * L9_2
  L8_2.left_x = L9_2
  L9_2 = math
  L9_2 = L9_2.abs
  L10_2 = L0_2 - 1.0
  L9_2 = L9_2(L10_2)
  L9_2 = L9_2 * 10
  L9_2 = L2_2 * L9_2
  L9_2 = L5_2 * L9_2
  L9_2 = L7_2 * L9_2
  L10_2 = 1.0
  L9_2 = L10_2 - L9_2
  L8_2.bottom_y = L9_2
  L9_2 = L8_2.left_x
  L10_2 = L8_2.width
  L9_2 = L9_2 + L10_2
  L8_2.right_x = L9_2
  L9_2 = L8_2.bottom_y
  L10_2 = L8_2.height
  L9_2 = L9_2 - L10_2
  L8_2.top_y = L9_2
  L9_2 = L8_2.left_x
  L8_2.x = L9_2
  L9_2 = L8_2.top_y
  L8_2.y = L9_2
  L8_2.xunit = L6_2
  L8_2.yunit = L7_2
  return L8_2
end
getMinimapAnchor = L3_1
