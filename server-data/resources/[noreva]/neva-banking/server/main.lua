local function SendDiscordLog(title, description, color, fields)
    if not Config.DiscordWebhook.Enabled or Config.DiscordWebhook.WebhookURL == 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL_HERE' then
        return
    end

    print("discord.gg/norevaRp")

    local embed = {
        {
            ['title'] = title,
            ['description'] = description,
            ['color'] = color or Config.DiscordWebhook.Color,
            ['fields'] = fields or {},
            ['footer'] = {
                ['text'] = os.date('%Y-%m-%d %H:%M:%S'),
                ['icon_url'] = Config.DiscordWebhook.BotAvatar
            },
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }
    }

    PerformHttpRequest(Config.DiscordWebhook.WebhookURL, function(errorCode, result, resultHeaders)
        if errorCode ~= 200 then
            print('^1[Neva Banking] Discord webhook error: ' .. errorCode .. '^7')
        end
    end, 'POST', json.encode({
        username = Config.DiscordWebhook.BotName,
        avatar_url = Config.DiscordWebhook.BotAvatar,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `neva_bank_transactions` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `identifier` varchar(50) NOT NULL,
          `type` varchar(20) NOT NULL,
          `amount` int(11) NOT NULL,
          `title` varchar(255) DEFAULT NULL,
          `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `neva_bank_cards` (
          `id` int(11) NOT NULL AUTO_INCREMENT,
          `identifier` varchar(50) NOT NULL,
          `pin` varchar(4) DEFAULT NULL,
          `card_name` varchar(50) DEFAULT NULL,
          `is_blocked` tinyint(1) NOT NULL DEFAULT '0',
          PRIMARY KEY (`id`),
          UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]])

    MySQL.query.await([[
        ALTER TABLE `neva_bank_cards`
        ADD COLUMN IF NOT EXISTS `card_name` varchar(50) DEFAULT NULL AFTER `pin`,
        ADD COLUMN IF NOT EXISTS `card_number` varchar(19) DEFAULT NULL AFTER `card_name`
    ]])

    MySQL.query.await([[
        ALTER TABLE `neva_bank_cards`
        MODIFY COLUMN `pin` varchar(4) DEFAULT NULL
    ]])

    print('^2[Neva Banking] Database tables checked/created successfully^7')
end)

local function LogTransaction(identifier, type, amount, title)
    local p, err = pcall(MySQL.insert.await, 'INSERT INTO neva_bank_transactions (identifier, type, amount, title) VALUES (?, ?, ?, ?)', {
        identifier, type, amount, title
    })
    if not p then
        print('^1[Neva Banking] SQL Error: Failed to insert transaction! Error: ' .. tostring(err) .. '^7')
    end
    return p
end

local function GetBankingDataForSource(source)
    local identifier = Bridge.GetIdentifier(source)
    if not identifier then return false end

    local name = Bridge.GetName(source)
    local bankBalance = Bridge.GetBankMoney(source)

    local p1, transactions = pcall(MySQL.query.await, 'SELECT * FROM neva_bank_transactions WHERE identifier = ? ORDER BY date DESC LIMIT 20', {identifier})
    local p2, card = pcall(MySQL.single.await, 'SELECT * FROM neva_bank_cards WHERE identifier = ?', {identifier})

    if p2 and card and not card.card_number then
        card.card_number = string.format("%04d %04d %04d %04d", math.random(1000, 9999), math.random(1000, 9999), math.random(1000, 9999), math.random(1000, 9999))
        pcall(MySQL.update.await, 'UPDATE neva_bank_cards SET card_number = ? WHERE identifier = ?', {card.card_number, identifier})
    end

    return {
        name = name,
        balance = bankBalance,
        transactions = (p1 and transactions) or {},
        card = (p2 and card) or nil
    }
end

Bridge.RegisterCallback('neva-banking:server:getBankingData', function(source, cb)
    cb(GetBankingDataForSource(source))
end)

Bridge.RegisterCallback('neva-banking:server:setCardName', function(source, cb, cardName)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return cb({ success = false }) end

    if not cardName or string.len(cardName) < 2 then
        Bridge.Notify(src, 'Invalid name', 'error')
        return cb({ success = false })
    end

    local p, card = pcall(MySQL.single.await, 'SELECT id FROM neva_bank_cards WHERE identifier = ?', {identifier})
    if p and card then
        pcall(MySQL.update.await, 'UPDATE neva_bank_cards SET card_name = ? WHERE identifier = ?', {cardName, identifier})
    else
        pcall(MySQL.insert.await, 'INSERT INTO neva_bank_cards (identifier, card_name) VALUES (?, ?)', {identifier, cardName})
    end

    Bridge.Notify(src, 'Card name updated successfully', 'success')
    cb({ success = true })
end)

Bridge.RegisterCallback('neva-banking:server:createCard', function(source, cb, cardName, pin)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    local name = Bridge.GetName(src)
    if not identifier then return cb({ success = false, message = 'Invalid identifier' }) end

    if not cardName or string.len(cardName) < 2 then
        return cb({ success = false, message = 'Invalid name' })
    end

    if not pin or string.len(pin) ~= 4 then
        return cb({ success = false, message = 'PIN must be 4 digits' })
    end

    local p, card = pcall(MySQL.single.await, 'SELECT * FROM neva_bank_cards WHERE identifier = ?', {identifier})
    if p and card and card.card_name and card.pin then
        return cb({ success = false, message = 'You already have a card. Use reset to change PIN.' })
    end

    local cardNumber = string.format("%04d %04d %04d %04d", math.random(1000, 9999), math.random(1000, 9999), math.random(1000, 9999), math.random(1000, 9999))

    if p and card then
        pcall(MySQL.update.await, 'UPDATE neva_bank_cards SET card_name = ?, pin = ?, card_number = ? WHERE identifier = ?', {cardName, pin, cardNumber, identifier})
    else
        pcall(MySQL.insert.await, 'INSERT INTO neva_bank_cards (identifier, card_name, pin, card_number) VALUES (?, ?, ?, ?)', {identifier, cardName, pin, cardNumber})
    end

    Bridge.Notify(src, 'Card created successfully!', 'success')

    SendDiscordLog(_U('log_discord_card_title'),
        _U('log_discord_card_desc', name, cardName),
        10181046, 
        {
            { name = 'Player', value = name, inline = true },
            { name = 'Identifier', value = identifier, inline = true },
            { name = 'Card Name', value = cardName, inline = true },
            { name = 'Type', value = 'Card Creation', inline = true }
        }
    )

    local p2, updatedCard = pcall(MySQL.single.await, 'SELECT * FROM neva_bank_cards WHERE identifier = ?', {identifier})
    cb({ success = true, data = { card = updatedCard } })
end)

RegisterNetEvent('neva-banking:server:setPin', function(pin)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    if not pin or string.len(pin) ~= 4 then
        Bridge.Notify(src, 'PIN must be 4 digits', 'error')
        return
    end

    local p, card = pcall(MySQL.single.await, 'SELECT * FROM neva_bank_cards WHERE identifier = ?', {identifier})
    if p and card and card.pin then
        Bridge.Notify(src, 'You already have a PIN set. Use reset to change it.', 'error')
        return
    end

    if p and card then
        pcall(MySQL.update.await, 'UPDATE neva_bank_cards SET pin = ? WHERE identifier = ?', {pin, identifier})
    else
        pcall(MySQL.insert.await, 'INSERT INTO neva_bank_cards (identifier, pin) VALUES (?, ?)', {identifier, pin})
    end
    Bridge.Notify(src, _U('pin_updated'), 'success')
end)

Bridge.RegisterCallback('neva-banking:server:resetPin', function(source, cb, currentPin, newPin)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    local name = Bridge.GetName(src)
    if not identifier then return cb({ success = false, message = 'Invalid identifier' }) end

    if not currentPin or string.len(currentPin) ~= 4 then
        return cb({ success = false, message = 'Current PIN must be 4 digits' })
    end

    if not newPin or string.len(newPin) ~= 4 then
        return cb({ success = false, message = 'New PIN must be 4 digits' })
    end

    local p, card = pcall(MySQL.single.await, 'SELECT * FROM neva_bank_cards WHERE identifier = ?', {identifier})
    if not p or not card then
        return cb({ success = false, message = 'Card not found' })
    end

    if card.pin ~= tostring(currentPin) then
        return cb({ success = false, message = 'Current PIN is incorrect' })
    end

    pcall(MySQL.update.await, 'UPDATE neva_bank_cards SET pin = ? WHERE identifier = ?', {newPin, identifier})
    Bridge.Notify(src, 'PIN reset successfully', 'success')

    SendDiscordLog(_U('log_discord_pin_title'),
        _U('log_discord_pin_desc', name),
        15158332, 
        {
            { name = 'Player', value = name, inline = true },
            { name = 'Identifier', value = identifier, inline = true },
            { name = 'Type', value = 'PIN Reset', inline = true }
        }
    )

    local p2, updatedCard = pcall(MySQL.single.await, 'SELECT * FROM neva_bank_cards WHERE identifier = ?', {identifier})
    cb({ success = true, data = { card = updatedCard } })
end)

Bridge.RegisterCallback('neva-banking:server:checkPin', function(source, cb, pin)
    local identifier = Bridge.GetIdentifier(source)
    if not identifier then return cb({ success = false }) end

    local p, card = pcall(MySQL.single.await, 'SELECT pin FROM neva_bank_cards WHERE identifier = ?', {identifier})
    if p and card and card.pin == tostring(pin) then
        local bankData = GetBankingDataForSource(source)
        return cb({ success = true, data = bankData })
    end
    cb({ success = false })
end)

Bridge.RegisterCallback('neva-banking:server:hasPin', function(source, cb)
    local identifier = Bridge.GetIdentifier(source)
    if not identifier then return cb(false) end

    local p, card = pcall(MySQL.single.await, 'SELECT pin FROM neva_bank_cards WHERE identifier = ?', {identifier})
    if p and card and card.pin then
        return cb(true)
    end
    cb(false)
end)

Bridge.RegisterCallback('neva-banking:server:doDeposit', function(source, cb, amount)
    local src = source
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        Bridge.Notify(src, _U('invalid_amount'), 'error')
        return cb({ success = false, message = _U('invalid_amount') })
    end

    local identifier = Bridge.GetIdentifier(src)
    local name = Bridge.GetName(src)
    local cash = Bridge.GetCash(src)

    if cash >= amount then
        Bridge.RemoveCash(src, amount)
        Bridge.AddBankMoney(src, amount)
        LogTransaction(identifier, 'deposit', amount, _U('log_deposit'))

        SendDiscordLog(_U('log_discord_deposit_title'),
            _U('log_discord_deposit-desc', name, amount),
            5763719, 
            {
                { name = 'Player', value = name, inline = true },
                { name = 'Identifier', value = identifier, inline = true },
                { name = 'Amount', value = '$' .. amount, inline = true },
                { name = 'Type', value = 'Deposit', inline = true }
            }
        )

        Bridge.Notify(src, _U('deposit_success', amount), 'success')

        local bankData = GetBankingDataForSource(src)
        cb({ success = true, data = bankData })
    else
        Bridge.Notify(src, _U('not_enough_money'), 'error')
        cb({ success = false, message = _U('not_enough_money') })
    end
end)

Bridge.RegisterCallback('neva-banking:server:doWithdraw', function(source, cb, amount)
    local src = source
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        Bridge.Notify(src, _U('invalid_amount'), 'error')
        return cb({ success = false, message = _U('invalid_amount') })
    end

    local identifier = Bridge.GetIdentifier(src)
    local name = Bridge.GetName(src)
    local bank = Bridge.GetBankMoney(src)

    if bank >= amount then
        Bridge.RemoveBankMoney(src, amount)
        Bridge.AddCash(src, amount)
        LogTransaction(identifier, 'withdraw', amount, _U('log_withdraw'))

        SendDiscordLog(_U('log_discord_withdraw_title'),
            _U('log_discord_withdraw_desc', name, amount),
            15548997, 
            {
                { name = 'Player', value = name, inline = true },
                { name = 'Identifier', value = identifier, inline = true },
                { name = 'Amount', value = '$' .. amount, inline = true },
                { name = 'Type', value = 'Withdraw', inline = true }
            }
        )

        Bridge.Notify(src, _U('withdraw_success', amount), 'success')

        local bankData = GetBankingDataForSource(src)
        cb({ success = true, data = bankData })
    else
        Bridge.Notify(src, _U('not_enough_bank'), 'error')
        cb({ success = false, message = _U('not_enough_bank') })
    end
end)

Bridge.RegisterCallback('neva-banking:server:doTransfer', function(source, cb, targetId, amount)
    local src = source
    amount = tonumber(amount)
    targetId = tonumber(targetId)

    if not amount or amount <= 0 then
        Bridge.Notify(src, _U('invalid_amount'), 'error')
        return cb({ success = false, message = _U('invalid_amount') })
    end

    if src == targetId then
        Bridge.Notify(src, _U('cant_transfer_self'), 'error')
        return cb({ success = false, message = _U('cant_transfer_self') })
    end

    local identifier = Bridge.GetIdentifier(src)
    local targetIdentifier = Bridge.GetIdentifier(targetId)

    if not targetIdentifier then
        Bridge.Notify(src, _U('player_not_found'), 'error')
        return cb({ success = false, message = _U('player_not_found') })
    end

    local bank = Bridge.GetBankMoney(src)

    if bank >= amount then
        Bridge.RemoveBankMoney(src, amount)
        Bridge.AddBankMoney(targetId, amount)

        local srcName = Bridge.GetName(src)
        local targetName = Bridge.GetName(targetId)

        print('^2[Neva Banking] Transfer: ' .. srcName .. ' (' .. identifier .. ') -> ' .. targetName .. ' (' .. targetIdentifier .. ') Amount: $' .. amount .. '^7')

        local log1 = LogTransaction(identifier, 'transfer_out', amount, _U('log_transfer_out', targetName))
        local log2 = LogTransaction(targetIdentifier, 'transfer_in', amount, _U('log_transfer_in', srcName))

        print('^2[Neva Banking] Log1 (transfer_out): ' .. tostring(log1) .. ', Log2 (transfer_in): ' .. tostring(log2) .. '^7')

        SendDiscordLog(_U('log_discord_transfer_title'),
            _U('log_discord_transfer_desc', srcName, amount, targetName),
            3447003, 
            {
                { name = 'Sender', value = srcName, inline = true },
                { name = 'Sender ID', value = identifier, inline = true },
                { name = 'Receiver', value = targetName, inline = true },
                { name = 'Receiver ID', value = targetIdentifier, inline = true },
                { name = 'Amount', value = '$' .. amount, inline = true },
                { name = 'Type', value = 'Transfer', inline = true }
            }
        )

        Bridge.Notify(src, _U('transfer_success', amount, targetName), 'success')
        Bridge.Notify(targetId, _U('received_transfer', amount, srcName), 'success')

        local bankData = GetBankingDataForSource(src)
        cb({ success = true, data = bankData })
    else
        Bridge.Notify(src, _U('not_enough_bank'), 'error')
        cb({ success = false, message = _U('not_enough_bank') })
    end
end)

local DynamicBankLocations = {}

CreateThread(function()
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "bank_locations.json")
    if loadFile then
        local decoded = json.decode(loadFile)
        if decoded then
            DynamicBankLocations = decoded
        end
    else
        SaveResourceFile(GetCurrentResourceName(), "bank_locations.json", "[]", -1)
    end
end)

Bridge.RegisterCallback('neva-banking:server:getDynamicLocations', function(source, cb)
    cb(DynamicBankLocations)
end)

local function IsAdmin(src)
    local identifiers = GetPlayerIdentifiers(src)
    local discordId = nil
    for _, id in ipairs(identifiers) do
        if string.find(id, "discord:") then
            discordId = string.sub(id, 9)
            break
        end
    end

    if discordId then
        for _, adminId in ipairs(Config.AdminDiscordIDs) do
            if discordId == adminId then
                return true
            end
        end
    end
    return false
end

RegisterCommand('nbanking', function(source, args, rawCommand)
    local src = source
    if src == 0 then return end 

    if IsAdmin(src) then
        TriggerClientEvent('neva-banking:client:openAdminMenu', src)
    else
        Bridge.Notify(src, 'You are not authorized to use this command.', 'error')
    end
end, false)

RegisterNetEvent('neva-banking:server:addBankLocation', function(coordsStr)
    local src = source
    if not IsAdmin(src) then return end

    local x, y, z, w = coordsStr:match("([^,]+)[%s,]+([^,]+)[%s,]+([^,]+)[%s,]*([^,]*)")
    
    if not x or not y or not z then
        Bridge.Notify(src, 'Invalid vector4 format! Use x, y, z, w', 'error')
        return
    end

    w = tonumber(w) or 0.0 

    local newLocation = {
        coords = { x = tonumber(x), y = tonumber(y), z = tonumber(z), w = tonumber(w) },
        npcModel = 'ig_bankman'
    }

    table.insert(DynamicBankLocations, newLocation)
    SaveResourceFile(GetCurrentResourceName(), "bank_locations.json", json.encode(DynamicBankLocations, { indent = true }), -1)

    TriggerClientEvent('neva-banking:client:syncBankLocation', -1, newLocation)
    Bridge.Notify(src, 'Bank location added successfully!', 'success')
end)

RegisterCommand('deletecard', function(source, args, rawCommand)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if identifier then
        pcall(MySQL.query.await, 'DELETE FROM neva_bank_cards WHERE identifier = ?', {identifier})
        Bridge.Notify(src, 'Your bank card data has been deleted.', 'success')
    end
end, false)
