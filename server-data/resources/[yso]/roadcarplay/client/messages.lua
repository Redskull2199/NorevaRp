-- ============================================================
-- roadcarplay/client/messages.lua
-- lb-phone 2.5.3 integration — client side
-- ============================================================
--
-- What this file does:
--   1. loadLBPhoneData() — fetches phone number, messages and
--      contacts via server-side SQL callbacks (the only real
--      way to get this data in lb-phone 2.5.3; there are no
--      client exports for GetConversations or GetContacts).
--
--   2. Listens for roadcarplay:lbphone:newMessage (forwarded
--      from server after lb-phone fires messageSent) and
--      injects the new message into the CarPlay NUI live.
--
--   3. Listens for lb-phone:numberChanged to reload data
--      when the equipped phone number changes.
--
--   4. NUI callbacks: sendMessage, setGPS, setMessagesRead.
-- ============================================================

local cachedMessages = {}

-- ─── setMessages ─────────────────────────────────────────────────────────────

local function setMessages_impl(messages)
    cachedMessages = messages or {}
    SendNUIMessage({ event = "setMessages", messages = cachedMessages })
end
setMessages = setMessages_impl

-- ─── loadLBPhoneData ─────────────────────────────────────────────────────────
-- Called by loadPlayer() in client.lua when Config.LBPhone = true.
-- Uses Bridge callbacks that hit SQL on the server side.

local function loadLBPhoneData_impl()
    -- GetEquippedPhoneNumber is the only real data-fetching client export
    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber()
    if not phoneNumber then return end

    -- Push phone number to NUI immediately
    SendNUIMessage({ event = "setPhoneNumber", number = phoneNumber })

    -- Fetch full message history from server (SQL-backed)
    Bridge.TriggerCallback("roadcarplay:lbphone:getMessages", function(messages)
        if messages then
            setMessages(messages)
        end
    end, phoneNumber)

    -- Fetch contacts from server (SQL-backed)
    Bridge.TriggerCallback("roadcarplay:lbphone:getContacts", function(contacts)
        if contacts and #contacts > 0 then
            SendNUIMessage({ event = "setContacts", contacts = contacts })
        end
    end, phoneNumber)
end
loadLBPhoneData = loadLBPhoneData_impl

-- ─── Live incoming/outgoing message ──────────────────────────────────────────
-- Forwarded from server/messages_lbphone.lua after lb-phone fires
-- lb-phone:messages:messageSent. Updates the CarPlay NUI in real-time.

RegisterNetEvent("roadcarplay:lbphone:newMessage")
AddEventHandler("roadcarplay:lbphone:newMessage", function(msg)
    table.insert(cachedMessages, msg)
    SendNUIMessage({ event = "newMessage", message = msg })
end)

-- ─── Phone number changed ─────────────────────────────────────────────────────
-- lb-phone fires this client event when the equipped phone changes.
-- We reload all data for the new number.

RegisterNetEvent("lb-phone:numberChanged")
AddEventHandler("lb-phone:numberChanged", function(newNumber)
    if newNumber then
        SendNUIMessage({ event = "setPhoneNumber", number = newNumber })
        if Config.LBPhone then
            cachedMessages = {}
            loadLBPhoneData()
        end
    end
end)

-- ─── NUI CALLBACK: sendMessage ───────────────────────────────────────────────

RegisterNUICallback("sendMessage", function(data, cb)
    local messageBody = data.message
    -- Special token: replace %pos% with player GPS coords
    if messageBody == "%pos%" then
        local coords = GetEntityCoords(PlayerPedId())
        messageBody  = "GPS: " .. string.format("%.4f", coords.x)
                    .. ", " .. string.format("%.4f", coords.y)
        data.message = messageBody
    end
    TriggerServerEvent("roadcarplay:lbphone:sendMessage", data.phoneNumber, data.message)
    cb("ok")
end)

-- ─── NUI CALLBACK: setGPS ────────────────────────────────────────────────────

RegisterNUICallback("setGPS", function(data, cb)
    SetNewWaypoint(tonumber(data.x), tonumber(data.y))
    cb("ok")
end)

-- ─── NUI CALLBACK: setMessagesRead ───────────────────────────────────────────

RegisterNUICallback("setMessagesRead", function(data, cb)
    TriggerServerEvent("roadcarplay:lbphone:setRead", data.sender)
    cb("ok")
end)
