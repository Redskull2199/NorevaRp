local L0_1, L1_1, L2_1, L3_1, L4_1
local QBCore = exports['qb-core']:GetCoreObject()
local function getQbStress(src)
  local player = QBCore.Functions.GetPlayer(src)
  if not player then return end
  return player, tonumber((player.PlayerData.metadata or {}).stress) or 0
end

local function updateQbStress(src, amount, relieve)
  amount = tonumber(amount)
  if not amount or amount ~= amount or amount < 0 or amount == math.huge then return end
  local player, stress = getQbStress(src)
  if not player then return end
  stress = math.max(0, math.min(100, stress + (relieve and -amount or amount)))
  player.Functions.SetMetaData('stress', stress)
  TriggerClientEvent('izzy-hudv6:client:setStress', src, stress)
end

L0_1 = {}
L1_1 = {}
L2_1 = CreateThread
function L3_1()
  local L0_2, L1_2
  while true do
    L0_2 = GlobalState
    L1_2 = GetNumPlayerIndices
    L1_2 = L1_2()
    L0_2.playerCount = L1_2
    L0_2 = Wait
    L1_2 = 15000
    L0_2(L1_2)
  end
end
L2_1(L3_1)
L2_1 = izzy
L2_1 = L2_1.createCallback
L3_1 = "izzy-hudv6:getName"
function L4_1(A0_2)
  local L1_2, L2_2
  L1_2 = getPlayerName
  L2_2 = A0_2
  return L1_2(L2_2)
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "izzy-hudv6:server:gainStress"
function L4_1(A0_2)
  if framework == 'qb' then updateQbStress(source, A0_2, false) return end
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = source
  L2_2 = getIdentifier
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  if not L2_2 then
    return
  end
  L3_2 = L1_1
  L3_2 = L3_2[L2_2]
  if not L3_2 then
    L3_2 = L1_1
    L3_2[L2_2] = 0
  end
  L3_2 = L1_1
  L4_2 = L1_1
  L4_2 = L4_2[L2_2]
  L4_2 = L4_2 + A0_2
  if L4_2 > 100 then
    L4_2 = 100
    if L4_2 then
      goto lbl_28
    end
  end
  L4_2 = L1_1
  L4_2 = L4_2[L2_2]
  L4_2 = L4_2 + A0_2
  ::lbl_28::
  L3_2[L2_2] = L4_2
  L3_2 = TriggerClientEvent
  L4_2 = "izzy-hudv6:client:setStress"
  L5_2 = L1_2
  L6_2 = L1_1
  L6_2 = L6_2[L2_2]
  L3_2(L4_2, L5_2, L6_2)
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "izzy-hudv6:server:relieveStress"
function L4_1(A0_2)
  if framework == 'qb' then updateQbStress(source, A0_2, true) return end
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = source
  L2_2 = getIdentifier
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  if not L2_2 then
    return
  end
  L3_2 = L1_1
  L3_2 = L3_2[L2_2]
  if not L3_2 then
    L3_2 = L1_1
    L3_2[L2_2] = 0
  end
  L3_2 = L1_1
  L4_2 = L1_1
  L4_2 = L4_2[L2_2]
  L4_2 = L4_2 - A0_2
  if L4_2 < 0 then
    L4_2 = 0
    if L4_2 then
      goto lbl_28
    end
  end
  L4_2 = L1_1
  L4_2 = L4_2[L2_2]
  L4_2 = L4_2 - A0_2
  ::lbl_28::
  L3_2[L2_2] = L4_2
  L3_2 = TriggerClientEvent
  L4_2 = "izzy-hudv6:client:setStress"
  L5_2 = L1_2
  L6_2 = L1_1
  L6_2 = L6_2[L2_2]
  L3_2(L4_2, L5_2, L6_2)
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "hud:server:GainStress"
function L4_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = TriggerClientEvent
  L2_2 = "izzy-hudv6:client:gainStress"
  L3_2 = source
  L4_2 = A0_2
  L1_2(L2_2, L3_2, L4_2)
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "hud:server:RelieveStress"
function L4_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = TriggerClientEvent
  L2_2 = "izzy-hudv6:client:relieveStress"
  L3_2 = source
  L4_2 = A0_2
  L1_2(L2_2, L3_2, L4_2)
end
L2_1(L3_1, L4_1)
L2_1 = izzy
L2_1 = L2_1.createCallback
L3_1 = "izzy-hudv6:getStress"
function L4_1(A0_2)
  if framework == 'qb' then
    local player, stress = getQbStress(A0_2)
    return stress or 0
  end
  local L1_2, L2_2
  L1_2 = getIdentifier
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = L1_1
  L1_2 = L2_2[L1_2]
  if not L1_2 then
    L1_2 = 0
  end
  return L1_2
end
L2_1(L3_1, L4_1)
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L1_2 = promise
  L1_2 = L1_2.new
  L1_2 = L1_2()
  L2_2 = PerformHttpRequest
  L3_2 = A0_2
  function L4_2(A0_3, A1_3, A2_3)
    local L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
    if 200 == A0_3 then
      L3_3 = string
      L3_3 = L3_3.match
      L4_3 = A1_3
      L5_3 = "<meta property=\"og:image\" content=\"(.-)\">"
      L3_3 = L3_3(L4_3, L5_3)
      L4_3 = string
      L4_3 = L4_3.match
      L5_3 = A1_3
      L6_3 = "<meta property=\"og:title\" content=\"(.-)\">"
      L4_3 = L4_3(L5_3, L6_3)
      L5_3 = string
      L5_3 = L5_3.match
      L6_3 = A1_3
      L7_3 = "\"ownerChannelName\":\"(.-)\""
      L5_3 = L5_3(L6_3, L7_3)
      L6_3 = L1_2
      L7_3 = L6_3
      L6_3 = L6_3.resolve
      L8_3 = {}
      L8_3.photo = L3_3
      L8_3.name = L4_3
      L8_3.author = L5_3
      L9_3 = A0_2
      L8_3.url = L9_3
      L6_3(L7_3, L8_3)
    else
      L3_3 = L1_2
      L4_3 = L3_3
      L3_3 = L3_3.resolve
      L5_3 = false
      L3_3(L4_3, L5_3)
    end
  end
  L5_2 = "GET"
  L6_2 = ""
  L7_2 = {}
  L7_2["Content-Type"] = "text/html"
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
  L2_2 = Citizen
  L2_2 = L2_2.Await
  L3_2 = L1_2
  return L2_2(L3_2)
end
getYouTubeVideoInfo = L2_1
L2_1 = RegisterNetEvent
L3_1 = "izzy-hudv6:server:playSound"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  if A1_2 then
    if nil == A1_2 then
      goto lbl_9
    end
    L2_2 = A1_2.url
    if L2_2 then
      goto lbl_9
    end
  end
  do return end
  ::lbl_9::
  L2_2 = getYouTubeVideoInfo
  L3_2 = A1_2.url
  L2_2 = L2_2(L3_2)
  if not A0_2 then
    return
  end
  if L2_2 then
    L3_2 = L2_2.photo
    A1_2.photo = L3_2
    L3_2 = L2_2.name
    A1_2.name = L3_2
    L3_2 = L2_2.author
    A1_2.author = L3_2
  end
  A1_2.maxDuration = 100
  A1_2.plate = A0_2
  L3_2 = L0_1
  L3_2[A0_2] = A1_2
  L3_2 = TriggerClientEvent
  L4_2 = "izzy-hudv6:client:playSound"
  L5_2 = -1
  L6_2 = A1_2
  L3_2(L4_2, L5_2, L6_2)
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNetEvent
L3_1 = "izzy-hudv6:server:updateSound"
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2
  if A2_2 then
    L3_2 = L0_1
    L3_2[A0_2] = nil
  else
    L4_2 = A0_2.plate
    L3_2 = L0_1
    L3_2[L4_2] = A0_2
  end
  if not A1_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "izzy-hudv6:client:updateSound"
    L5_2 = -1
    L6_2 = A0_2
    L3_2(L4_2, L5_2, L6_2)
  end
end
L2_1(L3_1, L4_1)
L2_1 = izzy
L2_1 = L2_1.createCallback
L3_1 = "izzy-hudv6:server:getMusicData"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = getYouTubeVideoInfo
  L3_2 = A1_2
  L2_2 = L2_2(L3_2)
  L3_2 = L2_2 or L3_2
  if not L2_2 or not L2_2 then
    L3_2 = false
  end
  return L3_2
end
L2_1(L3_1, L4_1)
L2_1 = izzy
L2_1 = L2_1.createCallback
L3_1 = "izzy-hudv6:server:getSoundByPlate"
function L4_1(A0_2, A1_2)
  local L2_2
  L2_2 = L0_1
  L2_2 = L2_2[A1_2]
  return L2_2
end
L2_1(L3_1, L4_1)
