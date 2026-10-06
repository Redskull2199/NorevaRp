function GetPlayerIdentifier()
    while not frameworkObject do
        Citizen.Wait(0)
    end
    if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        return frameworkObject.Functions.GetPlayerData().citizenid
    else
        return frameworkObject.GetPlayerData().identifier
    end
end

function CheckAccess(id)
    local Identifier = GetPlayerIdentifier()
    for k, v in ipairs(Config.Vehicleshops[id].Employees) do
        if v.identifier == Identifier then
            return true
        end
    end
    if Config.Vehicleshops[id].Owner == Identifier then
        return true
    end
    return false
end

function BuyCompany(k)
    SendNUIMessage({
        action = 'BuyCompany',
        vehicleshop = k,
        price = Config.Vehicleshops[k].Price,
        name = Config.Vehicleshops[k].CompanyName
    })
    SetNuiFocus(true, true)
end

function OpenBossmenu(k)
    local data = Callback('real-vehicleshop:GetCompanyData', k)

    if data then
        SendNUIMessage({
            action = 'OpenBossmenu',
            vehicleshop = k,
            playername = data.Name,
            playermoney = data.Money,
            playerpfp = data.Pfp,
            playerrank = data.PlayerRank,
            allvehiclestable = Config.VehiclesData[Config.Vehicleshops[k].Type],
            vehicleshopname = Config.Vehicleshops[k].CompanyName,
            vehicleshopdescription = Config.Vehicleshops[k].CompanyDescriptionText,
            companymoney = Config.Vehicleshops[k].CompanyMoney,
            employees = Config.Vehicleshops[k].Employees,
            vehicles = Config.Vehicleshops[k].Vehicles,
            vehiclessold = Config.Vehicleshops[k].SoldVehicles,
            feedbacks = Config.Vehicleshops[k].Feedbacks,
            preorders = Config.Vehicleshops[k].Preorders,
            transactions = Config.Vehicleshops[k].Transactions,
            perms = Config.Vehicleshops[k].Perms,
            discount = Config.Vehicleshops[k].Discount,
            categories = Config.Vehicleshops[k].Categories,
            complaints = Config.Vehicleshops[k].Complaints,
        })
        SetNuiFocus(true, true)
        CurrentVehicleshop = k
    end
end

function OpenComplaintForm(k)
    SendNUIMessage({
        action = 'OpenComplaintForm',
        vehicleshop = k,
    })
    SetNuiFocus(true, true)
end

function AcceptedBuyCompany(data)
    local result = Callback('real-vehicleshop:BuyCompany', data)
    if result then
        SendNUIMessage({ action = 'CloseTransferReq' })
        Config.Notification(Language('successfully_bought_company'), 'success', false)
    else
        Config.Notification(Language('not_enough_money'), 'error', false)
    end
end

function DepositMoney(data)
    TriggerServerEvent('real-vehicleshop:MoneyAction', 'deposit', data)
end

function WithdrawMoney(data)
    TriggerServerEvent('real-vehicleshop:MoneyAction', 'withdraw', data)
end

function ChangeCompanyName(data)
    TriggerServerEvent('real-vehicleshop:ChangeCompanyName', data)
end

function SendTransferRequest(data)
    TriggerServerEvent('real-vehicleshop:SendTransferRequest', data)
end

function AcceptedTransferReq(data)
    TriggerServerEvent('real-vehicleshop:TransferCompany', data)
end

function SendCancelTransferReqNotifyToSender(src)
    TriggerServerEvent('real-vehicleshop:SendCancelTransferReqNotifyToSender', src)
end

function MakeDiscount(data)
    TriggerServerEvent('real-vehicleshop:MakeDiscount', data)
end

function CancelDiscount(data)
    TriggerServerEvent('real-vehicleshop:CancelDiscount', data)
end

function DeleteAllLogs(data)
    TriggerServerEvent('real-vehicleshop:DeleteAllLogs', data)
end

function SendBonusToStaff(data)
    TriggerServerEvent('real-vehicleshop:SendBonusToStaff', data)
end

function RaisePrices(data)
    TriggerServerEvent('real-vehicleshop:RaisePrices', data)
end

function SendJobRequest(data)
    TriggerServerEvent('real-vehicleshop:SendJobRequest', data)
end

function AcceptedJobRequest(data)
    TriggerServerEvent('real-vehicleshop:AcceptedJobRequest', data)
end

function SendRejectedJobReqToSender(src)
    TriggerServerEvent('real-vehicleshop:SendRejectedJobReqToSender', src)
end

function GiveSalaryPenalty(data)
    TriggerServerEvent('real-vehicleshop:GiveSalaryPenalty', data)
end

function EndThePunishment(data)
    TriggerServerEvent('real-vehicleshop:EndThePunishment', data)
end

function RankUpEmployee(data)
    TriggerServerEvent('real-vehicleshop:RankUpEmployee', data)
end

function ReduceEmployeeRank(data)
    TriggerServerEvent('real-vehicleshop:ReduceEmployeeRank', data)
end

function FireEmployee(data)
    TriggerServerEvent('real-vehicleshop:FireEmployee', data)
end

function CreateCategory(data)
    TriggerServerEvent('real-vehicleshop:CreateCategory', data)
end

function RemoveCategory(data)
    TriggerServerEvent('real-vehicleshop:RemoveCategory', data)
end

function EditCategory(data)
    TriggerServerEvent('real-vehicleshop:EditCategory', data)
end

function EditVehicle(data)
    TriggerServerEvent('real-vehicleshop:EditVehicle', data)
end

function BuyVehicle(data)
    TriggerServerEvent('real-vehicleshop:BuyVehicle', data)
end

function CreatePermission(data)
    TriggerServerEvent('real-vehicleshop:CreatePermission', data)
end

function RemovePerm(data)
    TriggerServerEvent('real-vehicleshop:RemovePerm', data)
end

function SaveNewPermissions(data)
    TriggerServerEvent('real-vehicleshop:SaveNewPermissions', data)
end

function SendComplaint(data)
    TriggerServerEvent('real-vehicleshop:SendComplaint', data)
end

function SendFeedback(data)
    TriggerServerEvent('real-vehicleshop:SendFeedback', data)
end

function RemoveComplaint(data)
    TriggerServerEvent('real-vehicleshop:RemoveComplaint', data)
end

function RemoveFeedback(data)
    TriggerServerEvent('real-vehicleshop:RemoveFeedback', data)
end

function DeclinePreorder(data)
    TriggerServerEvent('real-vehicleshop:DeclinePreorder', data)
end

function AcceptPreorder(data)
    TriggerServerEvent('real-vehicleshop:AcceptPreorder', data)
end

RegisterNetEvent('real-vehicleshop:UpdateUI', function()
    local data = Callback('real-vehicleshop:GetPlayerInformation', CurrentVehicleshop)
    if data then
        SendNUIMessage({
            action = 'UpdateUI',
            playermoney = data.Money,
            playerrank = data.PlayerRank,
            vehicleshopname = Config.Vehicleshops[CurrentVehicleshop].CompanyName,
            companymoney = Config.Vehicleshops[CurrentVehicleshop].CompanyMoney,
            employees = Config.Vehicleshops[CurrentVehicleshop].Employees,
            vehicles = Config.Vehicleshops[CurrentVehicleshop].Vehicles,
            vehiclessold = Config.Vehicleshops[CurrentVehicleshop].SoldVehicles,
            feedbacks = Config.Vehicleshops[CurrentVehicleshop].Feedbacks,
            preorders = Config.Vehicleshops[CurrentVehicleshop].Preorders,
            transactions = Config.Vehicleshops[CurrentVehicleshop].Transactions,
            perms = Config.Vehicleshops[CurrentVehicleshop].Perms,
            discount = Config.Vehicleshops[CurrentVehicleshop].Discount,
            categories = Config.Vehicleshops[CurrentVehicleshop].Categories,
            complaints = Config.Vehicleshops[CurrentVehicleshop].Complaints
        })
    end
end)

RegisterNetEvent('real-vehicleshop:ShowTransferReqToPlayer', function(src, targetsrc, id, price)
    SendNUIMessage({
        action = 'SendTransferRequest',
        vehicleshop = id,
        name = Config.Vehicleshops[id].CompanyName,
        price = price,
        sender = src,
        target = targetsrc
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('real-vehicleshop:CloseBossmenu', function()
    SendNUIMessage({ action = 'CloseBossmenu' })
end)

RegisterNetEvent('real-vehicleshop:CloseTransferReqForTarget', function()
    SendNUIMessage({ action = 'CloseTransferReq' })
    SetNuiFocus(false, false)
end)

RegisterNetEvent('real-vehicleshop:ShowJobReqToPlayer', function(src, targetsrc, id, salary)
    SendNUIMessage({
        action = 'SendJobRequest',
        vehicleshop = id,
        name = Config.Vehicleshops[id].CompanyName,
        salary = salary,
        sender = src,
        target = targetsrc
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('real-vehicleshop:CloseJobReqScreen', function()
    SendNUIMessage({ action = 'CloseJobReq' })
    SetNuiFocus(false, false)
end)

RegisterNetEvent('real-vehicleshop:CloseBossPopup', function(type)
    SendNUIMessage({
        action = 'CloseBossPopup',
        type = type
    })
end)

RegisterNetEvent('real-vehicleshop:ShowFeedbackScreen', function(data)
    SendNUIMessage({
        action = 'ShowFeedbackScreen',
        id = data
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('BuyCompany', AcceptedBuyCompany)
RegisterNUICallback('DepositMoney', DepositMoney)
RegisterNUICallback('WithdrawMoney', WithdrawMoney)
RegisterNUICallback('ChangeCompanyName', ChangeCompanyName)
RegisterNUICallback('SendTransferRequest', SendTransferRequest)
RegisterNUICallback('AcceptedTransferReq', AcceptedTransferReq)
RegisterNUICallback('SendCancelTransferReqNotifyToSender', SendCancelTransferReqNotifyToSender)
RegisterNUICallback('MakeDiscount', MakeDiscount)
RegisterNUICallback('CancelDiscount', CancelDiscount)
RegisterNUICallback('DeleteAllLogs', DeleteAllLogs)
RegisterNUICallback('SendBonusToStaff', SendBonusToStaff)
RegisterNUICallback('RaisePrices', RaisePrices)
RegisterNUICallback('SendJobRequest', SendJobRequest)
RegisterNUICallback('AcceptedJobRequest', AcceptedJobRequest)
RegisterNUICallback('SendRejectedJobReqToSender', SendRejectedJobReqToSender)
RegisterNUICallback('GiveSalaryPenalty', GiveSalaryPenalty)
RegisterNUICallback('EndThePunishment', EndThePunishment)
RegisterNUICallback('RankUpEmployee', RankUpEmployee)
RegisterNUICallback('ReduceEmployeeRank', ReduceEmployeeRank)
RegisterNUICallback('FireEmployee', FireEmployee)
RegisterNUICallback('CreateCategory', CreateCategory)
RegisterNUICallback('RemoveCategory', RemoveCategory)
RegisterNUICallback('EditCategory', EditCategory)
RegisterNUICallback('EditVehicle', EditVehicle)
RegisterNUICallback('BuyVehicle', BuyVehicle)
RegisterNUICallback('CreatePermission', CreatePermission)
RegisterNUICallback('RemovePerm', RemovePerm)
RegisterNUICallback('SaveNewPermissions', SaveNewPermissions)
RegisterNUICallback('SendComplaint', SendComplaint)
RegisterNUICallback('RemoveComplaint', RemoveComplaint)
RegisterNUICallback('RemoveFeedback', RemoveFeedback)
RegisterNUICallback('SendFeedback', SendFeedback)
RegisterNUICallback('DeclinePreorder', DeclinePreorder)
RegisterNUICallback('AcceptPreorder', AcceptPreorder)