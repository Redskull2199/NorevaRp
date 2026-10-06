QBCore = exports['qb-core']:GetCoreObject()

lib.addCommand('admin', {
    help = 'Yönetici menüsünü aç',
    restricted = 'qbcore.mod'
}, function(source)
    if not QBCore.Functions.IsOptin(source) then TriggerClientEvent('QBCore:Notify', source, 'Görevde değilsiniz', 'error'); return end
    TriggerClientEvent('ps-adminmenu:client:OpenUI', source)
end)
-- Callbacks
