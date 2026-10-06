Framework.Core(Framework)

local jsReady = false
local ui = {}
ui.pages = Config and Config.Pages
ui.speech = Config and Config.Speech
ui.bgMusic = Config and Config.BackgroundMusic
ui.cinematicMode = Config and Config.CinematicMode
ui.deleteButtonStatus = Config.DeleteButton
ui.lang = require("locales." .. Config.Lang)

CreateThread(function()
  while true do
    Wait(0)
    if NetworkIsSessionStarted() and jsReady then
      Wait(300)
      pcall(function()
        exports.spawnmanager:setAutoSpawn(false)
      end)
      Debug("Network Player Active | Auto Spawn False |" .. PlayerId())
      TriggerEvent("qb-multicharacter:client:chooseChar")
      break
    end
  end
end)

RegisterNUICallback("jsReady", function(_, cb)
  jsReady = true
  Debug("JS Ready")
  cb("ok")
end)

RegisterNetEvent("qb-multicharacter:client:chooseChar", function()
  UMShutDownNui()
end)

RegisterNetEvent("cr-multicharacter:client:GetCharacters", function()
  SetNui(false)
  SetFollowPedCamViewMode(2)
  local characters, totalSlots = lib.callback.await("cr-multicharacter:server:GetCharacters", 5000)
  if characters then
    local customDelete = lib.callback.await("cr-multicharacter:callback:CustomDeleteCharacterAccess")
    SendNUIMessage({
      ui = true,
      myCharacters = characters,
      Lang = ui.lang,
      totalSlots = totalSlots,
      deleteButtonStatus = customDelete or (ui and ui.deleteButtonStatus),
      pagesList = ui.pages,
      speechList = ui.speech,
      bgMusic = ui.bgMusic,
      cinematicMode = ui.cinematicMode
    })
    Debug("Characters Received")
    Debug("Total Number of Slots:" .. totalSlots)
    SetNui(true)
  else
    SendNUIMessage({
      ui = true,
      Lang = ui.lang,
      totalSlots = totalSlots,
      pagesList = ui.pages,
      bgMusic = ui.bgMusic,
      cinematicMode = ui.cinematicMode
    })
    Debug("Character Not Found | New Character Screen Introduced", "warn")
    Debug("Character Not Found | Number of Slots:" .. totalSlots, "warn")
    SetNui(true)
  end
  SetUseHideDofLoop()
end) --decrypt by cr leak discord.gg/fxd

RegisterNetEvent("cr-multicharacter:client:defaultSpawn", function()
  local invoker = GetInvokingResource()
  if invoker then
    return
  end
  SetNui(false)
  DoScreenFadeOut(500)
  Wait(2000)
  local pos = Config.NewPlayerNoApartmentStartCoords
  SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z)
  SetEntityHeading(PlayerPedId(), pos.w)
  TriggerServerEvent(Framework.Events.loadedS)
  TriggerEvent(Framework.Events.loadedC)
  TriggerServerEvent(Framework.Events.houseS, 0, false)
  TriggerServerEvent(Framework.Events.apartS, 0, 0, false)
  Wait(500)
  SetEntityVisible(PlayerPedId(), true)
  Wait(500) --decrypt by cr leak discord.gg/fxd
  DoScreenFadeIn(500)
  TriggerEvent("qb-weathersync:client:EnableSync")
  TriggerEvent(Config.NewPlayerNoApartmentStartClothingUI)
end)

local function playEntryAnim()
  SetTimeout(1000, function()
    local dict = "anim@scripted@heist@ig25_beach@male@"
    lib.requestAnimDict(dict)
    local pedPos = GetEntityCoords(cache.ped)
    local pedHeading = GetEntityHeading(cache.ped)
    local scenePos = vector4(pedPos.x, pedPos.y, pedPos.z - 1, pedHeading)
    local scene = NetworkCreateSynchronisedScene(scenePos.x, scenePos.y, scenePos.z, 0.0, 0.0, scenePos.w, 2, false, false, 8.0, 1000.0, 1.0)
    NetworkAddPedToSynchronisedScene(cache.ped, scene, dict, "action", 1000.0, 8.0, 0, 0, 1000.0, 8192)
    local cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
    PlayCamAnim(cam, "action_camera", dict, scenePos.x, scenePos.y, scenePos.z, 0.0, 0.0, scenePos.w, false, 2)
    RenderScriptCams(true, false, 0, true, false)
    NetworkStartSynchronisedScene(scene)
    local localScene = NetworkGetLocalSceneFromNetworkId(scene)
    while localScene == -1 do
      Wait(0) --decrypt by cr leak discord.gg/fxd
      localScene = NetworkGetLocalSceneFromNetworkId(scene)
    end
    repeat
      Wait(0)
    until GetSynchronizedScenePhase(localScene) > 0.85
    StopRenderingScriptCamsUsingCatchUp(false, 4.0, 3)
    DestroyCam(cam, false)
    FreezeEntityPosition(cache.ped, false)
    RemoveAnimDict(dict)
  end)
end

local function runSwitchCutscene()
  FreezeEntityPosition(cache.ped, true)
  DoScreenFadeOut(0)
  TriggerScreenblurFadeIn(10)
  if not IsPlayerSwitchInProgress() then
    SwitchOutPlayer(cache.ped, 0, 1)
  end
  while GetPlayerSwitchState() ~= 5 do
    Wait(0)
  end
  DoScreenFadeIn(1000)
  while not IsScreenFadedIn() do
    Wait(0)
  end
  playEntryAnim()
  SwitchInPlayer(cache.ped)
  while GetPlayerSwitchState() ~= 12 do
    Wait(0)
  end
  TriggerScreenblurFadeOut(100)
  FreezeEntityPosition(cache.ped, false)
end

RegisterNetEvent("cr-multicharacter:client:spawnLastCoords", function(coords)
  local invoker = GetInvokingResource()
  if invoker then
    return
  end
  SetNui(false)
  Wait(1000)
  local state = GetResourceState("ps-housing")
  if state == "started" then
    local apt = lib.callback.await("ps-housing:cb:GetOwnedApartment", source, coords and coords.citizenid)
    if apt then
      TriggerEvent("apartments:client:SetHomeBlip", apt and apt.type)
    end --decrypt by cr leak discord.gg/fxd
  end
  local pdata = Framework:GetPlayerData(Framework)
  local inside = pdata and pdata.metadata and pdata.metadata.inside
  SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z - 1)
  SetEntityHeading(PlayerPedId(), (coords and coords.w) or 0.0)
  if inside and inside.house ~= nil then
    TriggerEvent(Framework.Events.house, inside.house)
  else
    local aptType = inside and inside.apartment and inside.apartment.apartmentType
    if aptType == nil then
      local prop = inside and (inside.propertyId or inside.property_id)
      if prop then
        TriggerServerEvent("ps-housing:server:enterProperty", tostring(inside.propertyId))
      end --decrypt by cr leak discord.gg/fxd
    else
      local aptId = inside.apartment.apartmentId
      TriggerEvent(Framework.Events.apart, aptType, aptId)
    end
  end
  TriggerServerEvent(Framework.Events.loadedS)
  TriggerEvent(Framework.Events.loadedC)
  RequestCollisionAtCoord(coords.x, coords.y, coords.z)
  while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    Debug("Colission Loading Last Location")
    Wait(0) 
  end
  Wait(500)
  if Config.NoSpawnMenuOnlyLastLocation.gtaVNativeAndCutScene then
    runSwitchCutscene()
    return
  end
  DoScreenFadeIn(1000)
end)

RegisterNetEvent("cr-multicharacter:client:logout", function()
  local invoker = GetInvokingResource()
  if invoker then
    return
  end
  TriggerEvent("um-clearCacheSkin")
  TriggerEvent("qb-multicharacter:client:chooseChar")
end)
