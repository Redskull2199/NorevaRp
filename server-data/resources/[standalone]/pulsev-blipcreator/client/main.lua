PulseV = PulseV or {}
PulseV.Client = {}
local serial = 0
local function errorResult(code, message) return {code=code,message=message} end

-- Chat visibility is independent of the server's permission and database state.
if AddEventHandler and TriggerEvent then
    local command=type(PulseV.Config.Command)=='string'
        and PulseV.Config.Command:match('^[A-Za-z0-9_-]+$') and PulseV.Config.Command or 'blipcreator'
    local function suggest() TriggerEvent('chat:addSuggestion','/'..command,'Blip yönetim panelini aç.',{}) end
    suggest()
    print(('[pulsev-blipcreator] client/main.lua loaded; chat suggestion /%s added.'):format(command))
    AddEventHandler('onClientResourceStart',function(resource)
        if resource=='chat' or resource=='0r-chatv3' then suggest() end
    end)
    AddEventHandler('QBCore:Client:OnPlayerLoaded',suggest)
    AddEventHandler('onResourceStop',function(resource)
        if resource==GetCurrentResourceName() then TriggerEvent('chat:removeSuggestion','/'..command) end
    end)
end

function PulseV.Client.new(deps)
    local P, config = PulseV.Protocol, deps.config or PulseV.Config
    local generation, state, pending, live = 0, 'closed', {}, true
    if deps.isLoggedIn then live=deps.isLoggedIn()==true end
    local client = {}
    local function message(kind, data, session)
        deps.sendNui({type=kind,generation=session or generation,data=data})
    end
    local function focus(enabled)
        deps.focus(enabled, enabled)
        if deps.keepInput then deps.keepInput(false) end
    end
    local function reply(item, ok, data, err)
        if item.finished then return end
        item.finished = true
        pending[item.id] = nil
        if item.callback then item.callback({generation=item.generation,ok=ok,data=data,error=err}) end
        if ok and item.generation==generation and ({create=true,update=true,delete=true,setEnabled=true,teleport=true})[item.action] then
            client.notify('success', item.action=='teleport' and 'Hedefe ışınlandınız.' or 'Blip değişikliği kaydedildi.')
        end
    end
    function client.notify(kind, text)
        local provider = config.Notification or {adapter='qbcore'}
        if provider.adapter=='nui' and state=='open' then
            message('notification',{kind=kind,message=text}); return
        end
        if provider.adapter=='custom' and deps.customNotify then
            local ok = pcall(deps.customNotify, provider.customEvent, text, kind)
            if ok then return end
        end
        deps.notify(text, kind)
    end
    function client.request(action, payload, callback)
        serial = serial + 1
        local id = 'client-'..serial
        local item = {id=id,action=action,generation=generation,callback=callback}
        local request, err = P.validateRequest({requestId=id,action=action,payload=payload or {}})
        if not request then reply(item, false, nil, err); return id end
        pending[id] = item
        deps.schedule(config.RequestTimeout or 10000, function()
            if pending[id] ~= item then return end
            reply(item, false, nil, errorResult('timeout','İstek zaman aşımına uğradı.'))
            if item.action=='teleport' then deps.teleport:cleanup('timeout') end
        end)
        deps.sendRequest(request)
        return id
    end
    function client.open(data)
        if type(data)~='table' or type(data.snapshot)~='table' or type(data.options)~='table' then return end
        if state == 'closed' then generation = generation + 1 end
        state = 'open'
        deps.preview:setSession(generation, state)
        focus(true)
        message('open',data)
    end
    function client.close(reason)
        local session = generation
        state = 'closed'
        generation = generation + 1
        deps.preview:setSession(generation, state)
        focus(false)
        deps.teleport:cleanup(reason or 'closed')
        local cancelled = {}
        for _, item in pairs(pending) do cancelled[#cancelled+1] = item end
        for _, item in ipairs(cancelled) do reply(item, false, nil, errorResult('cancelled','Panel kapatıldı.')) end
        message('close',{reason=reason or 'closed'},session)
    end
    function client.minimize()
        if state~='open' then return end
        state = 'preview-minimized'
        deps.preview:setSession(generation,state)
        focus(false)
        message('close',{reason='minimize'})
    end
    function client.shutdown()
        if not live then return end
        live = false
        client.close('shutdown')
        deps.sync:reset()
        deps.store:clear()
    end
    function client.receiveResponse(response)
        if type(response)~='table' then return end
        local item = pending[response.requestId]
        if not item then
            if response.ok==false and type(response.requestId)=='string' and response.requestId:match('^command_')
                and type(response.error)=='table' and type(response.error.message)=='string' then
                client.notify('error', response.error.message)
            end
            return
        end
        if item.generation~=generation then return end
        if response.ok ~= true then
            reply(item, false, nil, response.error or errorResult('failed','İstek başarısız.'))
            if item.action=='teleport' then deps.teleport:cleanup('rejected') end
            if response.error and (response.error.code=='unauthorized' or response.error.code=='unavailable') then
                client.close(response.error.code)
            end
            return
        end
        if item.action=='teleport' then
            if type(response.data)~='table' or response.data.accepted~=true then return end
            item.accepted = true
            if item.nativeDone then reply(item,item.nativeOk,response.data,item.nativeError) end
        else
            if item.action=='list' then message('adminSnapshot',response.data,item.generation) end
            reply(item,true,response.data)
        end
    end
    function client.receiveTeleport(event)
        if type(event)~='table' then return end
        local item = pending[event.requestId]
        if not item or item.action~='teleport' or item.generation~=generation or item.started or state~='open' then return end
        item.started = true
        deps.teleport:start(event.target,function(ok, err)
            if pending[item.id]~=item or item.finished then return end
            item.nativeDone, item.nativeOk, item.nativeError = true, ok, err
            if item.accepted then reply(item,ok,{accepted=true},err) end
        end)
    end
    local function bindNui(action)
        deps.registerNui(action,function(input, callback)
            local session = type(input)=='table' and input.generation or nil
            local answered = false
            local function answer(result)
                if answered then return end
                answered = true
                result.generation = session
                callback(result)
            end
            if session~=generation or state~='open' then
                answer({ok=false,error=errorResult('stale_session','Panel oturumu kapalı.')}); return
            end
            local payload = input.payload or {}
            local ok, err = pcall(function()
                if action=='close' then
                    client.close('closed')
                    client.request('close',{},function() end)
                    answer({ok=true,data={closed=true}})
                elseif action=='minimize' then client.minimize(); answer({ok=true})
                elseif action=='getPosition' then answer({ok=true,data=deps.position()})
                elseif action=='preview' then
                    local valid, failure = deps.preview:apply(payload.draft or payload, session)
                    answer({ok=valid==true,error=failure})
                elseif action=='clearPreview' then deps.preview:clear(); answer({ok=true})
                else client.request(action,payload,answer) end
            end)
            if not ok then answer({ok=false,error=errorResult('client_error','İstek işlenemedi.')}) end
        end)
    end
    for _, action in pairs(P.NuiCallbacks) do bindNui(action) end
    local function serverEvent(event, fn)
        deps.registerNet(event,function(...)
            if deps.eventSource()~=65535 or not live then return end
            fn(...)
        end)
    end
    serverEvent(P.Events.open,client.open)
    serverEvent(P.Events.response,client.receiveResponse)
    serverEvent(P.Events.teleport,client.receiveTeleport)
    serverEvent(P.Events.snapshot,function(data) deps.sync:receiveSnapshot(data) end)
    serverEvent(P.Events.delta,function(data) deps.sync:receiveDelta(data) end)
    serverEvent(P.Events.ready,function(epoch) deps.sync:onReady(epoch) end)
    serverEvent(P.Events.adminDelta,function(data)
        if state~='closed' then message('adminDelta',data) end
    end)
    deps.registerLocal('QBCore:Client:OnPlayerLoaded',function()
        live=true
        -- Login/spawn can invalidate native handles even while the SQL epoch is unchanged.
        deps.store:clear(); deps.sync:reset(); deps.sync:onReady()
    end)
    deps.registerLocal('QBCore:Client:OnPlayerUnload',client.shutdown)
    deps.registerLocal('onClientResourceStart',function(resource)
        if resource==deps.resourceName() and (not deps.isLoggedIn or deps.isLoggedIn()) then
            live=true; deps.sync:onReady()
        end
    end)
    deps.registerLocal('onResourceStop',function(resource)
        if resource==deps.resourceName() or resource=='qb-core' then client.shutdown() end
    end)
    deps.registerLocal('onClientResourceStop',function(resource)
        if resource==deps.resourceName() or resource=='qb-core' then client.shutdown() end
    end)
    if live then deps.sync:onReady() end
    function client.session() return generation,state end
    return client
end

-- The constructor remains injectable for deterministic native/event tests.
if RegisterNetEvent and RegisterNUICallback then
    local core = exports['qb-core']:GetCoreObject()
    local config = PulseV.Config
    local natives = {AddBlipForCoord=AddBlipForCoord,DoesBlipExist=DoesBlipExist,RemoveBlip=RemoveBlip,SetBlipCoords=SetBlipCoords,
        SetBlipSprite=SetBlipSprite,SetBlipColour=SetBlipColour,SetBlipScale=SetBlipScale,
        SetBlipAlpha=SetBlipAlpha,SetBlipDisplay=SetBlipDisplay,SetBlipAsShortRange=SetBlipAsShortRange,
        SetBlipRotation=SetBlipRotation,SetBlipCategory=SetBlipCategory,
        BeginTextCommandSetBlipName=BeginTextCommandSetBlipName,
        AddTextComponentSubstringPlayerName=AddTextComponentSubstringPlayerName,EndTextCommandSetBlipName=EndTextCommandSetBlipName}
    local renderOptions={config=config,sprites=PulseV.Catalog.spritesById,
        onError=function(code,id,field)
            print(('[pulsev-blipcreator] %s id=%s field=%s'):format(code,tostring(id),tostring(field)))
        end}
    local store = PulseV.Blips.new(natives,renderOptions)
    local sync = PulseV.Sync.new({config=config,schedule=SetTimeout,
        requestSnapshot=function(id) TriggerServerEvent(PulseV.Protocol.Events.requestSnapshot,id) end,
        applySnapshot=function(records)
            store:reconcile(records)
            print(('[pulsev-blipcreator] Map snapshot applied: records=%d handles=%d.'):format(#records,store:count()))
        end,
        applyDelta=function(delta)
            if delta.op=='remove' then store:remove(delta.id)
            elseif delta.op=='upsert' then store:upsert(delta.record) end
        end})
    PulseV.Client = PulseV.Client.new({config=config,sync=sync,store=store,
        isLoggedIn=function() return LocalPlayer.state.isLoggedIn==true end,
        preview=PulseV.Preview.new({config=config,blips=PulseV.Blips.new(natives,renderOptions),schedule=SetTimeout}),
        teleport=PulseV.Teleport.new({PlayerPedId=PlayerPedId,DoesEntityExist=DoesEntityExist,
            IsPedInAnyVehicle=IsPedInAnyVehicle,GetEntityCoords=GetEntityCoords,GetEntityHeading=GetEntityHeading,
            SetEntityHeading=SetEntityHeading,SetEntityCoordsNoOffset=SetEntityCoordsNoOffset,
            FreezeEntityPosition=FreezeEntityPosition,DoScreenFadeIn=DoScreenFadeIn,DoScreenFadeOut=DoScreenFadeOut,
            RequestCollisionAtCoord=RequestCollisionAtCoord,HasCollisionLoadedAroundEntity=HasCollisionLoadedAroundEntity,
            GetGameTimer=GetGameTimer,Wait=Wait,CreateThread=CreateThread},config),
        schedule=SetTimeout,sendNui=SendNUIMessage,focus=SetNuiFocus,keepInput=SetNuiFocusKeepInput,
        registerNui=RegisterNUICallback,registerNet=RegisterNetEvent,registerLocal=AddEventHandler,
        eventSource=function() return source end,resourceName=GetCurrentResourceName,
        sendRequest=function(request) TriggerServerEvent(PulseV.Protocol.Events.request,request) end,
        notify=function(text,kind) core.Functions.Notify(text,kind,5000) end,
        customNotify=function(event,text,kind) TriggerEvent(event,text,kind) end,
        position=function()
            local ped=PlayerPedId(); local coords=GetEntityCoords(ped)
            return {x=coords.x,y=coords.y,z=coords.z,rotation=math.floor(GetEntityHeading(ped)+0.5)%360}
        end})
end
