-- Fatura Sistemi Server.lua Entegrasyonu

local QBCore = exports['qb-core']:GetCoreObject()
local ox = exports['oxmysql']

lib.locale()

local function getPlayerIdentifier(playerId)
    for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
        if string.match(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

function getPlayerIdFromLicense(license)
    for _, playerId in ipairs(GetPlayers()) do 
        local identifiers = GetPlayerIdentifiers(playerId) 
        for _, id in ipairs(identifiers) do
            if id == license then
                return playerId 
            end
        end
    end
    return nil  
end

-- Fatura oluşturma olayını banka sistemine entegre ettik
RegisterNetEvent('d-invoices:createBill')
AddEventHandler('d-invoices:createBill', function(playerId, amount, reason, comment)
    local src = source
    local FaturaKesen = QBCore.Functions.GetPlayer(src)
    local FaturaAlan = QBCore.Functions.GetPlayer(playerId)
    
    if not FaturaKesen or not FaturaAlan then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = "Oyuncu bulunamadı",
            type = "error"
        })
        return
    end
    
    local PlayerJob = FaturaKesen.PlayerData.job.name
    local FaturaAlancitizenid = FaturaAlan.PlayerData.citizenid
    local FaturaKesencitizenid = FaturaKesen.PlayerData.citizenid

    -- Banka sisteminin export fonksiyonunu kullanıyoruz
    local success = exports["real-bank"]:createBill({
        identifier = FaturaAlancitizenid,
        kesenidentifier = FaturaKesencitizenid,
        description = comment,
        type = reason,
        society = PlayerJob,
        amount = amount,
    })
    
    if success then
        -- Fatura başarıyla oluşturulduğunda bildirim gönder
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('bill_created'),
            type = "success"
        })
        
        -- Fatura alan kişiye bildirim gönder
        TriggerClientEvent('ox_lib:notify', playerId, {
            title = locale('title'),
            description = locale("you_have_been_fined"),
            type = "info"
        })
        
        -- Discord webhook'a mesaj gönder (opsiyonel)
        local message = string.format("**Fatura Oluşturuldu**\n**Gönderen:** %s\n**Alan:** %s\n**Sebep:** %s\n**Tutar:** %s\n**Açıklama:** %s", 
            GetPlayerName(src), GetPlayerName(playerId), reason, amount, comment)
        SendToDiscord(Config.DiscordWebhook.Invoices, 'Fatura oluşturuldu', message, 65280)
    else
        -- Hata durumunda bildirim gönder
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('failed_to_create'),
            type = "error"
        })
    end
end)

-- Dashboard bilgisi alma fonksiyonu - bank_invoices tablosunu kullanıyor
RegisterNetEvent('d-invoices:fetchDashboardInfo')
AddEventHandler('d-invoices:fetchDashboardInfo', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local identifier = Player.PlayerData.citizenid

    if identifier then
        ox:execute("SELECT COUNT(*) AS totalBills FROM bank_invoices WHERE citizenid = ?", {identifier}, function(totalResult)
            local totalBills = totalResult[1].totalBills or 0

            ox:execute("SELECT COUNT(*) AS paidBills FROM bank_invoices WHERE citizenid = ? AND isPaid = 1", {identifier}, function(paidResult)
                local paidBills = paidResult[1].paidBills or 0

                ox:execute("SELECT COUNT(*) AS unpaidBills FROM bank_invoices WHERE citizenid = ? AND isPaid = 0", {identifier}, function(unpaidResult)
                    local unpaidBills = unpaidResult[1].unpaidBills or 0

                    TriggerClientEvent('d-invoices:client:receiveDashboardInfo', src, {
                        totalBills = totalBills,
                        paidBills = paidBills,
                        unpaidBills = unpaidBills
                    })
                end)
            end)
        end)
    end
end)

-- Faturaları getirme olayı - bank_invoices tablosunu kullanıyor
RegisterNetEvent('d-invoices:fetchBills')
AddEventHandler('d-invoices:fetchBills', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local identifier = Player.PlayerData.citizenid

    if identifier then
        -- Banka sisteminden faturaları getiriyoruz
        local bills = exports["real-bank"]:getInvoices(identifier, true)
        TriggerClientEvent('d-invoices:client:receiveBills', src, bills)
    end
end)

-- Fatura geçmişi alma olayı - bank_invoices tablosunu kullanıyor
RegisterNetEvent('d-invoices:fetchHistory')
AddEventHandler('d-invoices:fetchHistory', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local identifier = Player.PlayerData.citizenid

    if identifier then
        -- Banka sisteminden tüm faturaları getiriyoruz
        local history = exports["real-bank"]:getInvoices(identifier, false)
        if history then
            TriggerClientEvent('d-invoices:client:receiveHistory', src, history) 
        end
    end
end)

-- Fatura ödeme olayı - Banka sisteminin export fonksiyonunu kullanıyor
RegisterNetEvent('d-invoices:payBill')
AddEventHandler('d-invoices:payBill', function(billId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local identifier = Player.PlayerData.citizenid
    
    -- Banka sisteminin ödeme fonksiyonunu kullanıyoruz
    local success, message = exports["real-bank"]:payInvoice(billId, identifier, src)
    
    if success then
        -- Fatura listelerini güncelliyoruz
        local bills = exports["real-bank"]:getInvoices(identifier, true)
        TriggerClientEvent('d-invoices:client:receiveBills', src, bills)

        local history = exports["real-bank"]:getInvoices(identifier, false)
        TriggerClientEvent('d-invoices:client:receiveHistory', src, history)

        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale('paid'),
            type = "success"
        })
        
        -- Log gönderme
        local playerName = GetPlayerName(src)
        local message = string.format("\n**Ödeyen:** %s\n**Fatura ID:** %s\n", playerName, billId)
        SendToDiscord(Config.DiscordWebhook.Invoices, 'Fatura ödendi', message, 65280)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = message or locale('failed_to_pay'),
            type = "error"
        })
    end
end)

-- Fatura iptal etme olayı
RegisterNetEvent('d-invoices:cancelInvoice')
AddEventHandler('d-invoices:cancelInvoice', function(invoiceId)
    local src = source
    
    -- Faturayla ilgili bilgileri alalım
    local invoice = exports.oxmysql:query_async('SELECT * FROM bank_invoices WHERE id = ?', {invoiceId})
    
    if invoice and #invoice > 0 then
        -- Faturayı iptal et (ödenmiş olarak işaretle)
        exports.oxmysql:update('UPDATE bank_invoices SET isPaid = 1, paid_at = NOW() WHERE id = ?', {invoiceId}, function(affectedRows)
            if affectedRows > 0 then
                local invoice = invoice[1]
                local receiverName = invoice.citizenid
                local sender = invoice.sender
                local reason = invoice.reason
                local amount = invoice.amount
                local comment = invoice.description
                local organization = invoice.society

                local message = string.format("**Gönderen:** %s\n**Alan:** %s\n**Sebep:** %s\n**Tutar:** %s\n**Açıklama:** %s\n**Kurum:** %s", 
                    sender, receiverName, reason, amount, comment, organization)

                SendToDiscord(Config.DiscordWebhook.Invoices, 'Fatura iptal edildi', message, 65280)
                TriggerClientEvent('ox_lib:notify', src, {
                    title = locale('title'),
                    description = locale("invoice_canceled"),
                    type = "info"
                })
                
                -- Fatura listesini güncelle
                local Player = QBCore.Functions.GetPlayer(src)
                if Player then
                    local identifier = Player.PlayerData.citizenid
                    local bills = exports["real-bank"]:getInvoices(identifier, true)
                    TriggerClientEvent('d-invoices:client:receiveBills', src, bills)
                    
                    local history = exports["real-bank"]:getInvoices(identifier, false)
                    TriggerClientEvent('d-invoices:client:receiveHistory', src, history)
                end
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = locale('title'),
                    description = locale("failed_to_update"),
                    type = "error"
                })
            end
        end)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title'),
            description = locale("invoice_not_found"),
            type = "error"
        })
    end
end)

-- Meslek için bütün faturaları getir
lib.callback.register('d-invoices:getAllPlayerData', function(source)
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if not xPlayer then return { error = 'Player not found' } end

    local playerJob = xPlayer.PlayerData.job.name
    
    -- Banka sisteminden mesleğe ait faturaları al
    local invoiceQuery = "SELECT * FROM bank_invoices WHERE isPaid = 0 AND society = ?"
    local invoices = exports.oxmysql:query_async(invoiceQuery, {playerJob})

    -- Her faturaya receiver bilgisini ekle (client tarafında bu bilgi kullanılıyor olabilir)
    for i = 1, #invoices do
        local citizenId = invoices[i].citizenid
        -- İsim bilgisini getir
        local playerInfo = exports.oxmysql:query_async("SELECT charinfo FROM players WHERE citizenid = ?", {citizenId})
        if playerInfo and #playerInfo > 0 then
            local charinfo = json.decode(playerInfo[1].charinfo)
            if charinfo then
                invoices[i].receiver = charinfo.firstname .. " " .. charinfo.lastname
            else
                invoices[i].receiver = citizenId -- Kullanıcı adı bulunamazsa citizenid göster
            end
        else
            invoices[i].receiver = citizenId
        end
    end

    return invoices
end)

-- Discord webhook gönderme fonksiyonu
function SendToDiscord(webhook, title, message, color)
    if not webhook or webhook == "" then return end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color, 
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S"), 
            },
        }
    }

    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "Banka Faturaları", 
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Faturaların doğru formatta dönüştürülmesi için yardımcı fonksiyon
function InvoiceConverter(invoices)
    if not invoices or #invoices == 0 then return {} end
    
    local converted = {}
    for _, invoice in ipairs(invoices) do
        table.insert(converted, {
            id = invoice.id,
            amount = invoice.amount,
            status = invoice.isPaid == 1 and "Ödenmiş" or "Ödenmemiş",
            created_at = invoice.created_at,
            reason = invoice.reason,
            organization = invoice.society
        })
    end
    
    return converted
end

-- Test komutu
RegisterCommand('faturadeneme', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        exports["real-bank"]:createBill({
            identifier = Player.PlayerData.citizenid,
            kesenidentifier = Player.PlayerData.citizenid,
            description = "Deneme Faturası",
            society = 'police',
            type = "Test",
            amount = 150.00,
        })
        
        TriggerClientEvent('ox_lib:notify', src, {
            title = "Fatura Sistemi",
            description = "Deneme faturası oluşturuldu!",
            type = "success"
        })
    end
end, false)
