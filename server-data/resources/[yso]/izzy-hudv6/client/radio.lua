local L0_1, L1_1, L2_1
L0_1 = cfg
L0_1 = L0_1.useMusicPlayer
if not L0_1 then
  return
end
volume = 50
function L0_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L0_2 = current
  L0_2 = L0_2.sound
  if L0_2 then
    L0_2 = exports
    L0_2 = L0_2.xsound
    L1_2 = L0_2
    L0_2 = L0_2.getInfo
    L2_2 = current
    L2_2 = L2_2.sound
    L2_2 = L2_2.plate
    L0_2 = L0_2(L1_2, L2_2)
    if not L0_2 then
      L1_2 = exports
      L1_2 = L1_2.xsound
      L2_2 = L1_2
      L1_2 = L1_2.PlayUrl
      L3_2 = current
      L3_2 = L3_2.sound
      L3_2 = L3_2.plate
      L4_2 = current
      L4_2 = L4_2.sound
      L4_2 = L4_2.url
      L5_2 = 0.1
      L6_2 = false
      L1_2(L2_2, L3_2, L4_2, L5_2, L6_2)
      L1_2 = Wait
      L2_2 = 1000
      L1_2(L2_2)
      L1_2 = exports
      L1_2 = L1_2.xsound
      L2_2 = L1_2
      L1_2 = L1_2.setTimeStamp
      L3_2 = current
      L3_2 = L3_2.sound
      L3_2 = L3_2.plate
      L4_2 = current
      L4_2 = L4_2.sound
      L4_2 = L4_2.timeStamp
      if not L4_2 then
        L4_2 = 0
      end
      L1_2(L2_2, L3_2, L4_2)
    else
      L1_2 = current
      L1_2 = L1_2.sound
      L2_2 = current
      L2_2 = L2_2.sound
      L2_2 = L2_2.isPlaying
      L2_2 = not L2_2
      L1_2.isPlaying = L2_2
      L1_2 = current
      L1_2 = L1_2.sound
      L2_2 = L0_2.timeStamp
      L1_2.timeStamp = L2_2
    end
    L1_2 = TriggerServerEvent
    L2_2 = "izzy-hudv6:server:updateSound"
    L3_2 = current
    L3_2 = L3_2.sound
    L1_2(L2_2, L3_2)
  else
    L0_2 = SendReactMessage
    L1_2 = "setRadio"
    L2_2 = nil
    L0_2(L1_2, L2_2)
  end
end
updateSoundState = L0_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  A0_2.timeStamp = 0
  A0_2.isPlaying = true
  L1_2 = volume
  A0_2.volume = L1_2
  L1_2 = TriggerServerEvent
  L2_2 = "izzy-hudv6:server:playSound"
  L3_2 = GetVehicleNumberPlateText
  L4_2 = GetVehiclePedIsIn
  L5_2 = PlayerPedId
  L5_2 = L5_2()
  L6_2 = false
  L4_2, L5_2, L6_2 = L4_2(L5_2, L6_2)
  L3_2 = L3_2(L4_2, L5_2, L6_2)
  L4_2 = A0_2
  L1_2(L2_2, L3_2, L4_2)
end
playSound = L0_1
L0_1 = RegisterNUICallback
L1_1 = "playMusic"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = current
  L2_2 = L2_2.sound
  if L2_2 then
    L2_2 = current
    L2_2 = L2_2.sound
    if L2_2 then
      L2_2 = L2_2.url
    end
    L3_2 = A0_2.url
    if L2_2 == L3_2 then
      goto lbl_17
    end
  end
  L2_2 = playSound
  L3_2 = A0_2
  L2_2(L3_2)
  goto lbl_19
  ::lbl_17::
  L2_2 = updateSoundState
  L2_2()
  ::lbl_19::
  L2_2 = A1_2
  L3_2 = {}
  L4_2 = "ok"
  L3_2[1] = L4_2
  L2_2(L3_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "updateSoundState"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = updateSoundState
  L2_2()
  L2_2 = A1_2
  L3_2 = {}
  L4_2 = "ok"
  L3_2[1] = L4_2
  L2_2(L3_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "getMusicDatas"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = A1_2
  L3_2 = {}
  L4_2 = json
  L4_2 = L4_2.decode
  L5_2 = GetResourceKvpString
  L6_2 = "playlists"
  L5_2, L6_2 = L5_2(L6_2)
  L4_2 = L4_2(L5_2, L6_2)
  if not L4_2 then
    L4_2 = {}
  end
  L3_2.playlists = L4_2
  L4_2 = json
  L4_2 = L4_2.decode
  L5_2 = GetResourceKvpString
  L6_2 = "favoriteMusics"
  L5_2, L6_2 = L5_2(L6_2)
  L4_2 = L4_2(L5_2, L6_2)
  if not L4_2 then
    L4_2 = {}
  end
  L3_2.favorites = L4_2
  L2_2(L3_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "addPlaylist"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "playlists"
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = table
  L3_2 = L3_2.insert
  L4_2 = L2_2
  L5_2 = A0_2
  L3_2(L4_2, L5_2)
  L3_2 = SetResourceKvp
  L4_2 = "playlists"
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = L2_2
  L5_2, L6_2 = L5_2(L6_2)
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = SendReactMessage
  L4_2 = "setPlaylists"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = SendReactMessage
  L4_2 = "setCurrent"
  L5_2 = #L2_2
  L5_2 = L5_2 - 1
  L3_2(L4_2, L5_2)
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "editPlaylist"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "playlists"
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = A0_2.id
  L3_2 = L3_2 + 1
  L2_2[L3_2] = A0_2
  L3_2 = SetResourceKvp
  L4_2 = "playlists"
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = L2_2
  L5_2, L6_2 = L5_2(L6_2)
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = SendReactMessage
  L4_2 = "setPlaylists"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "deletePlaylist"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "playlists"
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = A0_2.id
  L3_2 = L3_2 + 1
  L3_2 = L2_2[L3_2]
  if L3_2 then
    L3_2 = table
    L3_2 = L3_2.remove
    L4_2 = L2_2
    L5_2 = A0_2.id
    L5_2 = L5_2 + 1
    L3_2(L4_2, L5_2)
  end
  L3_2 = SetResourceKvp
  L4_2 = "playlists"
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = L2_2
  L5_2, L6_2 = L5_2(L6_2)
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = SendReactMessage
  L4_2 = "setPlaylists"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "deleteMusic"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "playlists"
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = A0_2.playlistId
  L3_2 = L2_2[L3_2]
  if L3_2 then
    L3_2 = A0_2.playlistId
    L3_2 = L2_2[L3_2]
    L3_2 = L3_2.musics
    L4_2 = A0_2.musicId
    L3_2 = L3_2[L4_2]
    if L3_2 then
      L3_2 = A0_2.playlistId
      L3_2 = L2_2[L3_2]
      L3_2 = L3_2.musics
      L4_2 = A0_2.musicId
      L3_2 = L3_2[L4_2]
      L4_2 = current
      L4_2 = L4_2.sound
      if L4_2 then
        L4_2 = L3_2.url
        L5_2 = current
        L5_2 = L5_2.sound
        L5_2 = L5_2.url
        if L4_2 == L5_2 then
          L4_2 = exports
          L4_2 = L4_2.xsound
          L5_2 = L4_2
          L4_2 = L4_2.Destroy
          L6_2 = current
          L6_2 = L6_2.sound
          L6_2 = L6_2.plate
          L4_2(L5_2, L6_2)
          L4_2 = TriggerServerEvent
          L5_2 = "izzy-hudv6:server:updateSound"
          L6_2 = GetVehicleNumberPlateText
          L7_2 = GetVehiclePedIsIn
          L8_2 = PlayerPedId
          L8_2 = L8_2()
          L9_2 = false
          L7_2, L8_2, L9_2 = L7_2(L8_2, L9_2)
          L6_2 = L6_2(L7_2, L8_2, L9_2)
          L7_2 = true
          L8_2 = true
          L4_2(L5_2, L6_2, L7_2, L8_2)
          L4_2 = SendReactMessage
          L5_2 = "setRadio"
          L6_2 = nil
          L4_2(L5_2, L6_2)
          L4_2 = current
          L4_2.sound = nil
        end
      end
      L4_2 = table
      L4_2 = L4_2.remove
      L5_2 = A0_2.playlistId
      L5_2 = L2_2[L5_2]
      L5_2 = L5_2.musics
      L6_2 = A0_2.musicId
      L4_2(L5_2, L6_2)
    end
  end
  L3_2 = SetResourceKvp
  L4_2 = "playlists"
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = L2_2
  L5_2, L6_2, L7_2, L8_2, L9_2 = L5_2(L6_2)
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  L3_2 = SendReactMessage
  L4_2 = "setPlaylists"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "addMusic"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "playlists"
  L3_2, L4_2, L5_2, L6_2, L7_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = A0_2.id
  L3_2 = L3_2 + 1
  L3_2 = L2_2[L3_2]
  if L3_2 then
    L3_2 = izzy
    L3_2 = L3_2.callback
    L4_2 = "izzy-hudv6:server:getMusicData"
    L5_2 = A0_2.url
    L3_2 = L3_2(L4_2, L5_2)
    if not L3_2 then
      return
    end
    L4_2 = table
    L4_2 = L4_2.insert
    L5_2 = A0_2.id
    L5_2 = L5_2 + 1
    L5_2 = L2_2[L5_2]
    L5_2 = L5_2.musics
    L6_2 = L3_2
    L4_2(L5_2, L6_2)
    L4_2 = SetResourceKvp
    L5_2 = "playlists"
    L6_2 = json
    L6_2 = L6_2.encode
    L7_2 = L2_2
    L6_2, L7_2 = L6_2(L7_2)
    L4_2(L5_2, L6_2, L7_2)
    L4_2 = SendReactMessage
    L5_2 = "setPlaylists"
    L6_2 = L2_2
    L4_2(L5_2, L6_2)
  end
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "addFavorite"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "favoriteMusics"
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = table
  L3_2 = L3_2.insert
  L4_2 = L2_2
  L5_2 = A0_2
  L3_2(L4_2, L5_2)
  L3_2 = SetResourceKvp
  L4_2 = "favoriteMusics"
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = L2_2
  L5_2, L6_2 = L5_2(L6_2)
  L3_2(L4_2, L5_2, L6_2)
  L3_2 = SendReactMessage
  L4_2 = "setFavorites"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "removeFavorite"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "favoriteMusics"
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = pairs
  L4_2 = L2_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = L8_2.url
    L10_2 = A0_2.url
    if L9_2 == L10_2 then
      L9_2 = table
      L9_2 = L9_2.remove
      L10_2 = L2_2
      L11_2 = L7_2
      L9_2(L10_2, L11_2)
      break
    end
  end
  L3_2 = SetResourceKvp
  L4_2 = "favoriteMusics"
  L5_2 = json
  L5_2 = L5_2.encode
  L6_2 = L2_2
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L5_2(L6_2)
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  L3_2 = SendReactMessage
  L4_2 = "setFavorites"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "previousMusic"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = current
  L2_2 = L2_2.sound
  L2_2 = L2_2.favorite
  if L2_2 then
    L2_2 = json
    L2_2 = L2_2.decode
    L3_2 = GetResourceKvpString
    L4_2 = "favoriteMusics"
    L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
    L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
    if L2_2 then
      goto lbl_20
    end
  end
  L2_2 = json
  L2_2 = L2_2.decode
  L3_2 = GetResourceKvpString
  L4_2 = "playlists"
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  ::lbl_20::
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = #L2_2
  if L3_2 > 0 then
    L3_2 = current
    L3_2 = L3_2.sound
    L3_2 = L3_2.favorite
    L3_2 = L2_2 or L3_2
    if not L3_2 or not L2_2 then
      L3_2 = current
      L3_2 = L3_2.sound
      L3_2 = L3_2.playlistId
      L3_2 = L2_2[L3_2]
      L3_2 = L3_2.musics
    end
    L4_2 = current
    L4_2 = L4_2.sound
    L4_2 = L4_2.musicId
    L4_2 = L4_2 - 1
    L4_2 = L3_2[L4_2]
    if L4_2 then
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.playlistId
      L4_2.playlistId = L5_2
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.musicId
      L5_2 = L5_2 - 1
      L4_2.musicId = L5_2
      L5_2 = playSound
      L6_2 = L4_2
      L5_2(L6_2)
    end
  end
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "nextMusic"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  L2_2 = current
  L2_2 = L2_2.sound
  if L2_2 then
    L2_2 = json
    L2_2 = L2_2.decode
    L3_2 = GetResourceKvpString
    L4_2 = "playlists"
    L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
    L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
    if L2_2 then
      goto lbl_15
    end
  end
  L2_2 = {}
  ::lbl_15::
  if not L2_2 then
    L3_2 = {}
    L2_2 = L3_2
  end
  L3_2 = #L2_2
  if L3_2 > 0 then
    L3_2 = current
    L3_2 = L3_2.sound
    L3_2 = L3_2.playlistId
    L3_2 = L2_2[L3_2]
    L3_2 = L3_2.musics
    L4_2 = current
    L4_2 = L4_2.sound
    L4_2 = L4_2.musicId
    L4_2 = L4_2 + 1
    L4_2 = L3_2[L4_2]
    if L4_2 then
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.playlistId
      L4_2.playlistId = L5_2
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.musicId
      L5_2 = L5_2 + 1
      L4_2.musicId = L5_2
      L5_2 = playSound
      L6_2 = L4_2
      L5_2(L6_2)
    end
  end
  L3_2 = A1_2
  L4_2 = {}
  L5_2 = "ok"
  L4_2[1] = L5_2
  L3_2(L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "updateVolume"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  volume = A0_2
  L2_2 = current
  L2_2 = L2_2.sound
  if L2_2 then
    L2_2 = exports
    L2_2 = L2_2.xsound
    L3_2 = L2_2
    L2_2 = L2_2.getInfo
    L4_2 = current
    L4_2 = L4_2.sound
    L4_2 = L4_2.plate
    L2_2 = L2_2(L3_2, L4_2)
    if L2_2 then
      L3_2 = exports
      L3_2 = L3_2.xsound
      L4_2 = L3_2
      L3_2 = L3_2.setVolume
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.plate
      L6_2 = volume
      L6_2 = L6_2 / 100
      L3_2(L4_2, L5_2, L6_2)
    end
  end
  L2_2 = SendReactMessage
  L3_2 = "setRadio"
  L4_2 = {}
  L5_2 = volume
  L4_2.volume = L5_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = {}
  L4_2 = "ok"
  L3_2[1] = L4_2
  L2_2(L3_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "closeMusic"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = current
  L2_2 = L2_2.sound
  if L2_2 then
    L2_2 = exports
    L2_2 = L2_2.xsound
    L3_2 = L2_2
    L2_2 = L2_2.getInfo
    L4_2 = current
    L4_2 = L4_2.sound
    L4_2 = L4_2.plate
    L2_2 = L2_2(L3_2, L4_2)
    if L2_2 then
      L3_2 = exports
      L3_2 = L3_2.xsound
      L4_2 = L3_2
      L3_2 = L3_2.Destroy
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.plate
      L3_2(L4_2, L5_2)
    end
    L3_2 = current
    L3_2.sound = nil
  end
  L2_2 = TriggerServerEvent
  L3_2 = "izzy-hudv6:server:updateSound"
  L4_2 = GetVehicleNumberPlateText
  L5_2 = GetVehiclePedIsIn
  L6_2 = PlayerPedId
  L6_2 = L6_2()
  L7_2 = false
  L5_2, L6_2, L7_2 = L5_2(L6_2, L7_2)
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  L5_2 = true
  L6_2 = true
  L2_2(L3_2, L4_2, L5_2, L6_2)
  L2_2 = SendReactMessage
  L3_2 = "setRadio"
  L4_2 = "{}"
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = {}
  L4_2 = "ok"
  L3_2[1] = L4_2
  L2_2(L3_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNetEvent
L1_1 = "izzy-hudv6:client:playSound"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L1_2 = GetVehiclePedIsIn
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = false
  L1_2 = L1_2(L2_2, L3_2)
  if 0 ~= L1_2 then
    L2_2 = GetVehicleNumberPlateText
    L3_2 = L1_2
    L2_2 = L2_2(L3_2)
    L3_2 = A0_2.plate
    if L2_2 == L3_2 then
      goto lbl_15
    end
  end
  do return end
  ::lbl_15::
  L2_2 = exports
  L2_2 = L2_2.xsound
  L3_2 = L2_2
  L2_2 = L2_2.PlayUrl
  L4_2 = A0_2.plate
  L5_2 = A0_2.url
  L6_2 = A0_2.volume
  L6_2 = L6_2 / 100
  L7_2 = false
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
  L2_2 = current
  L2_2.sound = A0_2
  L2_2 = SendReactMessage
  L3_2 = "setRadio"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNetEvent
L1_1 = "izzy-hudv6:client:updateSound"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = GetVehiclePedIsIn
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = false
  L1_2 = L1_2(L2_2, L3_2)
  if 0 ~= L1_2 then
    L2_2 = GetVehicleNumberPlateText
    L3_2 = L1_2
    L2_2 = L2_2(L3_2)
    L3_2 = A0_2.plate
    if L2_2 == L3_2 then
      goto lbl_15
    end
  end
  do return end
  ::lbl_15::
  L2_2 = exports
  L2_2 = L2_2.xsound
  L3_2 = L2_2
  L2_2 = L2_2.getInfo
  L4_2 = current
  L4_2 = L4_2.sound
  L4_2 = L4_2.plate
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L3_2 = current
    L3_2 = L3_2.sound
    L3_2 = L3_2.isPlaying
    if L3_2 then
      L3_2 = exports
      L3_2 = L3_2.xsound
      L4_2 = L3_2
      L3_2 = L3_2.PlayUrl
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.plate
      L6_2 = current
      L6_2 = L6_2.sound
      L6_2 = L6_2.url
      L7_2 = 0.1
      L8_2 = false
      L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
      L3_2 = Wait
      L4_2 = 1000
      L3_2(L4_2)
      L3_2 = exports
      L3_2 = L3_2.xsound
      L4_2 = L3_2
      L3_2 = L3_2.setTimeStamp
      L5_2 = current
      L5_2 = L5_2.sound
      L5_2 = L5_2.plate
      L6_2 = current
      L6_2 = L6_2.sound
      L6_2 = L6_2.timeStamp
      if not L6_2 then
        L6_2 = 0
      end
      L3_2(L4_2, L5_2, L6_2)
    end
  end
  L3_2 = A0_2.isPlaying
  if not L3_2 then
    L3_2 = exports
    L3_2 = L3_2.xsound
    L4_2 = L3_2
    L3_2 = L3_2.Pause
    L5_2 = A0_2.plate
    L3_2(L4_2, L5_2)
    if L2_2 then
      L3_2 = current
      L3_2 = L3_2.sound
      L4_2 = exports
      L4_2 = L4_2.xsound
      L5_2 = L4_2
      L4_2 = L4_2.getMaxDuration
      L6_2 = current
      L6_2 = L6_2.sound
      L6_2 = L6_2.plate
      L4_2 = L4_2(L5_2, L6_2)
      L3_2.maxDuration = L4_2
      L3_2 = current
      L3_2 = L3_2.sound
      L4_2 = exports
      L4_2 = L4_2.xsound
      L5_2 = L4_2
      L4_2 = L4_2.getTimeStamp
      L6_2 = current
      L6_2 = L6_2.sound
      L6_2 = L6_2.plate
      L4_2 = L4_2(L5_2, L6_2)
      L3_2.timeStamp = L4_2
    end
  else
    L3_2 = exports
    L3_2 = L3_2.xsound
    L4_2 = L3_2
    L3_2 = L3_2.Resume
    L5_2 = A0_2.plate
    L3_2(L4_2, L5_2)
    L3_2 = exports
    L3_2 = L3_2.xsound
    L4_2 = L3_2
    L3_2 = L3_2.setTimeStamp
    L5_2 = A0_2.plate
    L6_2 = A0_2.timeStamp
    L3_2(L4_2, L5_2, L6_2)
  end
  L3_2 = SendReactMessage
  L4_2 = "setRadio"
  L5_2 = current
  L5_2 = L5_2.sound
  L3_2(L4_2, L5_2)
end
L0_1(L1_1, L2_1)
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  while true do
    L0_2 = cfg
    L0_2 = L0_2.useMusicPlayer
    if not L0_2 then
      break
    end
    L0_2 = current
    L0_2 = L0_2.sound
    if L0_2 then
      L0_2 = exports
      L0_2 = L0_2.xsound
      L1_2 = L0_2
      L0_2 = L0_2.soundExists
      L2_2 = current
      L2_2 = L2_2.sound
      L2_2 = L2_2.plate
      L0_2 = L0_2(L1_2, L2_2)
      if L0_2 then
        L0_2 = exports
        L0_2 = L0_2.xsound
        L1_2 = L0_2
        L0_2 = L0_2.getMaxDuration
        L2_2 = current
        L2_2 = L2_2.sound
        L2_2 = L2_2.plate
        L0_2 = L0_2(L1_2, L2_2)
        if L0_2 then
          goto lbl_28
        end
      end
      L0_2 = 0
      ::lbl_28::
      L1_2 = exports
      L1_2 = L1_2.xsound
      L2_2 = L1_2
      L1_2 = L1_2.soundExists
      L3_2 = current
      L3_2 = L3_2.sound
      L3_2 = L3_2.plate
      L1_2 = L1_2(L2_2, L3_2)
      if L1_2 then
        L1_2 = exports
        L1_2 = L1_2.xsound
        L2_2 = L1_2
        L1_2 = L1_2.getTimeStamp
        L3_2 = current
        L3_2 = L3_2.sound
        L3_2 = L3_2.plate
        L1_2 = L1_2(L2_2, L3_2)
        if L1_2 then
          goto lbl_47
        end
      end
      L1_2 = 0
      ::lbl_47::
      L2_2 = exports
      L2_2 = L2_2.xsound
      L3_2 = L2_2
      L2_2 = L2_2.soundExists
      L4_2 = current
      L4_2 = L4_2.sound
      L4_2 = L4_2.plate
      L2_2 = L2_2(L3_2, L4_2)
      if L2_2 then
        L2_2 = SendReactMessage
        L3_2 = "setRadio"
        L4_2 = {}
        L4_2.maxDuration = L0_2
        L4_2.timeStamp = L1_2
        L2_2(L3_2, L4_2)
        if L0_2 < L1_2 then
          L2_2 = current
          L2_2 = L2_2.sound
          L2_2 = L2_2.musicId
          if L2_2 then
            L2_2 = current
            L2_2 = L2_2.sound
            L2_2 = L2_2.isPlaying
            if L2_2 then
              L2_2 = json
              L2_2 = L2_2.decode
              L3_2 = GetResourceKvpString
              L4_2 = "playlists"
              L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
              L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
              if not L2_2 then
                L3_2 = {}
                L2_2 = L3_2
              end
              L3_2 = #L2_2
              if L3_2 > 0 then
                L3_2 = current
                L3_2 = L3_2.sound
                L3_2 = L3_2.favorite
                L3_2 = L2_2 or L3_2
                if not L3_2 or not L2_2 then
                  L3_2 = current
                  L3_2 = L3_2.sound
                  L3_2 = L3_2.playlistId
                  L3_2 = L2_2[L3_2]
                  L3_2 = L3_2.musics
                end
                L4_2 = current
                L4_2 = L4_2.sound
                L4_2 = L4_2.musicId
                L4_2 = L4_2 + 1
                L5_2 = #L3_2
                if L4_2 > L5_2 then
                  L4_2 = L3_2[1]
                  if L4_2 then
                    goto lbl_118
                  end
                end
                L4_2 = current
                L4_2 = L4_2.sound
                L4_2 = L4_2.musicId
                L4_2 = L4_2 + 1
                L4_2 = L3_2[L4_2]
                ::lbl_118::
                if L4_2 then
                  L5_2 = playSound
                  L6_2 = L4_2
                  L5_2(L6_2)
                end
              end
            end
          end
        end
      end
      L2_2 = Wait
      L3_2 = 1000
      L2_2(L3_2)
    else
      L0_2 = Wait
      L1_2 = 2000
      L0_2(L1_2)
    end
  end
end
L0_1(L1_1)
