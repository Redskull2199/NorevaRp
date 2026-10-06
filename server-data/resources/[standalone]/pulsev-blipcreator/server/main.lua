local P=PulseV.Protocol
local config=PulseV.Config
local commandName=type(config)=='table' and type(config.Command)=='string'
    and config.Command:match('^[A-Za-z0-9_-]+$') and config.Command or 'blipcreator'
local commandHandler,commandSerial,startupFailure=nil,0,'initializing'
-- Register before Config validation, QBCore exports, service construction or SQL.
RegisterCommand(commandName,function(playerSource)
    print(('[pulsev-blipcreator] /%s source=%s command_received'):format(commandName,tostring(playerSource)))
    if commandHandler then commandHandler(playerSource); return end
    commandSerial=commandSerial+1
    print(('[pulsev-blipcreator] /%s panel_open_failed: %s; command remains registered.'):format(commandName,startupFailure))
    if playerSource>0 then
        TriggerClientEvent(P.Events.response,playerSource,{requestId='command_'..commandSerial,ok=false,
            error={code='unavailable',message='Blip paneli hazır değil. Sunucu başlangıç logunu kontrol edin.'}})
    end
end,false)
print(('[pulsev-blipcreator] server/main.lua loaded; RegisterCommand /%s completed (restricted=false).'):format(commandName))
local configOk,configErrors=PulseV.Validation.validateConfig(config)
if not configOk then
    startupFailure='invalid_config'
    local fields={}; for field in pairs(configErrors) do fields[#fields+1]=field end; table.sort(fields)
    print(('[pulsev-blipcreator] Panel disabled: invalid Config (%s); command remains registered.'):format(table.concat(fields,', ')))
    return
end
local coreOk,core=pcall(function() return exports['qb-core']:GetCoreObject() end)
if not coreOk or type(core)~='table' or type(core.Functions)~='table'
    or not PulseV.Bridge.isCallable(core.Functions.GetPlayer) then
    startupFailure='qbcore_unavailable'
    print('[pulsev-blipcreator] Panel disabled: qb-core unavailable; command remains registered. Start qb-core first.')
    return
end
print(('[pulsev-blipcreator] QBCore export ready: GetPlayer=%s HasPermission=%s.'):format(
    type(core.Functions.GetPlayer),type(core.Functions.HasPermission)))
local db=PulseV.Database.new(MySQL,config,PulseV.Catalog)
local bridge=PulseV.Bridge.new(core,{
    GetPlayerName=GetPlayerName,GetPlayerPed=GetPlayerPed,GetVehiclePedIsIn=GetVehiclePedIsIn,
    IsPlayerAceAllowed=IsPlayerAceAllowed,
    GetPlayerIdentifierByType=GetPlayerIdentifierByType,
},config,db)
local previous,elapsed
local function clock()
    -- Interpret the native's signed/unsigned rollover as one 32-bit elapsed counter.
    local current=GetGameTimer()%4294967296
    if previous==nil then previous=current; elapsed=0
    else elapsed=elapsed+(current-previous)%4294967296; previous=current end
    return elapsed
end
local service=PulseV.Service.new({db=db,bridge=bridge,
    config=config,catalog=PulseV.Catalog,clock=clock,spawn=CreateThread,
    epochFactory=function()
        return ('%s-%s-%08x-%08x'):format(GetCurrentResourceName(),os.date('!%Y%m%d%H%M%S'),math.random(0,0x7fffffff),math.random(0,0x7fffffff))
    end,
    sendPublic=function(delta) TriggerClientEvent(P.Events.delta,-1,delta) end,
    sendAdmin=function(source,delta) TriggerClientEvent(P.Events.adminDelta,source,delta) end,
    sendReady=function(epoch) TriggerClientEvent(P.Events.ready,-1,epoch) end,
    sendTeleport=function(source,data) TriggerClientEvent(P.Events.teleport,source,data) end,
})

RegisterNetEvent(P.Events.request,function(request)
    local playerSource=source
    service:request(playerSource,request,function(response)
        TriggerClientEvent(P.Events.response,playerSource,response)
    end)
end)
RegisterNetEvent(P.Events.requestSnapshot,function(requestId)
    local playerSource=source
    local ticket=bridge:ticket(playerSource)
    if not ticket then return end
    local snapshot,failure=service:snapshot(playerSource,requestId,'public')
    if not bridge:isCurrent(ticket) then return end
    if snapshot then TriggerLatentClientEvent(P.Events.snapshot,playerSource,config.SnapshotBandwidth,snapshot)
    else
        local safeId=type(requestId)=='string' and #requestId<=64 and requestId:match('^[A-Za-z0-9_-]+$') and requestId or nil
        TriggerClientEvent(P.Events.snapshot,playerSource,{requestId=safeId,error=failure})
    end
end)
local function describeChecks(permissions,checks)
    local values={}
    for _,permission in ipairs(permissions or {}) do
        local value=checks[permission]
        values[#values+1]=permission..'='..(value==nil and 'not_checked' or tostring(value))
    end
    return table.concat(values,',')
end
local function commandLog(playerSource,result,details)
    print(('[pulsev-blipcreator] /%s source=%s %s: %s'):format(config.Command,tostring(playerSource),result,details))
end
commandHandler=function(playerSource)
    commandSerial=commandSerial+1
    local requestId='command_'..commandSerial
    local status=bridge:permissionStatus(playerSource)
    commandLog(playerSource,status.allowed and 'permission_granted' or 'permission_denied',
        ('reason=%s active_player=%s qbcore=[%s] ace=[%s]'):format(status.reason,tostring(status.active),
            describeChecks(config.Permissions,status.qbcore),describeChecks(config.AcePermissions,status.ace)))
    if not status.allowed then
        if status.active then
            TriggerClientEvent(P.Events.response,playerSource,{requestId=requestId,ok=false,
                error={code='unauthorized',message=PulseV.Locales.tr.unauthorized..' Sunucu konsolundaki yetki kontrolünü inceleyin.'}})
        end
        return
    end
    service:request(playerSource,{requestId=requestId,action='open',payload={}},function(response)
        if response.ok then
            commandLog(playerSource,'panel_open_sent','Authorized admin snapshot sent to client.')
            TriggerClientEvent(P.Events.open,playerSource,response.data)
        else
            local code=response.error and response.error.code or 'unknown'
            commandLog(playerSource,'panel_open_failed','code='..code..(code=='unavailable'
                and '; database not ready, startup failed, or dependency stopped. Check startup logs.' or ''))
            TriggerClientEvent(P.Events.response,playerSource,response)
        end
    end)
end
print(('[pulsev-blipcreator] Command handler ready /%s; QBCore roles=[%s] OR ACE=[%s]. Permission is checked on execution.'):format(
    config.Command,table.concat(config.Permissions,','),table.concat(config.AcePermissions or {},',')))
-- No network endpoint can grant access. Only the trusted server console manages the durable ACL.
RegisterCommand(config.Command..'permission',function(playerSource,args)
    if playerSource~=0 then return end
    local action,target=args[1],args[2]
    if (action~='grant' and action~='revoke') or not target or #args~=2 then
        print(('[pulsev-blipcreator] Usage: %spermission grant|revoke <server-id|license:hash>'):format(config.Command)); return
    end
    local license=target
    if target:match('^%d+$') then
        local ticket=bridge:ticket(tonumber(target)); license=ticket and ticket.license
    end
    local ok,code=bridge:setPermission(license,action=='grant')
    print(('[pulsev-blipcreator] Persistent permission %s: %s'):format(action,ok and 'saved' or tostring(code)))
end,false)
AddEventHandler('playerDropped',function()
    local playerSource=source
    service:drop(playerSource)
end)
AddEventHandler('QBCore:Server:OnPlayerUnload',function(playerSource)
    -- QBCore's local logout event also covers relogging into the same citizen ID.
    if GetInvokingResource()=='qb-core' then service:drop(playerSource) end
end)
AddEventHandler('onResourceStop',function(resource)
    if resource==GetCurrentResourceName() or resource=='qb-core' or resource=='oxmysql' then service:shutdown() end
end)
MySQL.ready(function()
    CreateThread(function()
        local ok,failure=service:start()
        if not ok then print(('[pulsev-blipcreator] Startup failed: %s; panel unavailable.'):format(failure.code))
        else print('[pulsev-blipcreator] Database ready; license permissions and saved blips loaded.') end
    end)
end)
