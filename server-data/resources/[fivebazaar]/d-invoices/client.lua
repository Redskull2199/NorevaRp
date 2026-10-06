
-- Fatura Sistemi Client.lua Entegrasyonu

local QBCore = exports['qb-core']:GetCoreObject()
lib.locale()

local function hasRequiredJob()
    local xPlayer = QBCore.Functions.GetPlayerData()

    for k , allowedJob in ipairs(Config.AllowedJobs) do
        if xPlayer.job and xPlayer.job.name == allowedJob.job and xPlayer.job.grade.level >= allowedJob.rank then
            return true 
        end
    end

    return false
end

local function checkJobForInvoices()
    SendNUIMessage({
        type = 'showSocietyInvoices',
        show = hasRequiredJob()
    })
end

-- Banka ve ATM kullanımı için target ekleme
exports.ox_target:addModel(Config.Banks, {
    {
        icon = "fas fa-credit-card",
        label = locale('access_invoices'),
        distance = 2,
        onSelect = function()
            -- Fatura bilgilerini ve banka sistemini göstermek için event tetikle
            TriggerServerEvent('d-invoices:fetchBills')
            TriggerServerEvent('d-invoices:fetchHistory')
            TriggerServerEvent('d-invoices:fetchDashboardInfo')
            checkJobForInvoices() 
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'showInvoiceMenu',
            })
        end,
    },
})

-- Fatura oluşturma komutu
RegisterCommand(Config.makeInvoicesCommand, function()
    if hasRequiredJob() then
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = 'showCreateBillMenu'
        })
    else
        lib.notify({
            title = locale('title'),
            description = locale('nopermission'),
            type = 'error'
        })
    end
end, false)

-- Dashboard bilgilerini al
RegisterNetEvent('d-invoices:client:receiveDashboardInfo')
AddEventHandler('d-invoices:client:receiveDashboardInfo', function(data)
    SendNUIMessage({
        type = 'updateDashboard',
        playerId = data.playerId,
        totalBills = data.totalBills,
        paidBills = data.paidBills,
        unpaidBills = data.unpaidBills
    })
end)

-- Ödenmemiş faturaları al
RegisterNetEvent('d-invoices:client:receiveBills')
AddEventHandler('d-invoices:client:receiveBills', function(bills)
    local cills = donusturucu(bills)
    SendNUIMessage({
        type = 'updateYourBillings',
        bills = cills
    })
end)

-- Banka veri formatını fatura sistemi formatına dönüştür
function donusturucu(degisken)
    if not degisken or type(degisken) ~= "table" then return {} end
    
    local degisken2 = {}
    for _, row in ipairs(degisken) do
        table.insert(degisken2, {
            id = row.id,
            amount = row.amount,
            status = (row.isPaid == 1 or row.isPaid == true) and "Ödenmiş" or "Ödenmemiş",
            created_at = row.created_at or row.date, -- bank_invoices veya phone_invoices uyumluluğu
            reason = row.reason or row.type, -- bank_invoices veya phone_invoices uyumluluğu
            organization = row.society
        })
    end
    
    return degisken2
end

-- Fatura geçmişini al
RegisterNetEvent('d-invoices:client:receiveHistory')
AddEventHandler('d-invoices:client:receiveHistory', function(history)
    local cistory = donusturucu(history)
    SendNUIMessage({
        type = 'updateHistory',
        history = cistory
    })
end)

-- Meslek faturalarını getir
RegisterNUICallback('getSocietyInvoices', function(_, cb)
    lib.callback('d-invoices:getAllPlayerData', source, function(invoices)
        cb({ invoices = invoices or {}})
    end)
end)

-- Fatura öde
RegisterNUICallback('payBill', function(data, cb)
    local billId = tonumber(data.billId)
    TriggerServerEvent('d-invoices:payBill', billId)
    cb('ok')
end)

-- Fatura geçmişini yenile
RegisterNUICallback('fetchHistory', function(_, cb)
    TriggerServerEvent('d-invoices:fetchHistory')
    cb('ok')
end)

-- Meslek faturalarını yenile
RegisterNUICallback('fetchSocityInvoices', function(_, cb)
    TriggerServerEvent('d-invoices:fetchHistory')
    cb('ok')
end)

-- Faturayı iptal et
RegisterNUICallback('cancelInvoice', function(data, cb)
    local invoiceId = data.invoiceId
    TriggerServerEvent('d-invoices:cancelInvoice', invoiceId)
    cb('ok')
end)

-- Menüyü kapat
RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Fatura oluştur
RegisterNUICallback('submitBill', function(data, cb)
    local playerId = tonumber(data.playerId)
    local reason = data.reason
    local amount = tonumber(data.amount)
    local comment = data.comment
    TriggerServerEvent('d-invoices:createBill', playerId, amount, reason, comment)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'hideInvoiceMenu'
    })
    cb('ok')
end)