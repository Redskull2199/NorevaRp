PulseV = PulseV or {}
local Service = {}
PulseV.Service = Service
local P,V=PulseV.Protocol,PulseV.Validation
local publicFields={'id','name','sprite','color','scale','alpha','display','short_range','x','y','z','rotation','map_category'}
local mutations={create=true,update=true,delete=true,setEnabled=true}
local function copy(value)
    if type(value)~='table' then return value end
    local result={}; for key,item in pairs(value) do result[key]=copy(item) end; return result
end
local function equal(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~='table' then return a==b end
    for key,value in pairs(a) do if not equal(value,b[key]) then return false end end
    for key in pairs(b) do if a[key]==nil then return false end end
    return true
end
local function err(code,fields,current)
    return {code=code,message=PulseV.Locales.tr[code] or PulseV.Locales.tr.invalid_request,fields=fields,current=copy(current)}
end
function Service.toPublic(record)
    if not record or not record.enabled then return nil end
    local out={}; for _,key in ipairs(publicFields) do out[key]=record[key] end; return out
end

function Service.new(deps)
    local db,bridge,config,catalog=deps.db,deps.bridge,deps.config,deps.catalog
    local clock,spawn=deps.clock,deps.spawn
    local service={}
    local ready,stopped,starting=false,false,false
    local records,count,epoch,sequence={},0,nil,0
    local sessions,subscribers,queue={}, {}, {}
    local draining,outstanding=false,0

    local function valid(ticket)
        return bridge:isCurrent(ticket) and bridge:isAllowed(ticket.source)
    end
    local function active(ticket) return bridge:isCurrent(ticket) end
    local function stateFor(ticket)
        local state=sessions[ticket.source]
        if not state or state.ticket.generation~=ticket.generation or state.ticket.citizenid~=ticket.citizenid then
            subscribers[ticket.source]=nil
            state={ticket=copy(ticket),rates={},pending={},pendingCount=0,results={},order={}}
            sessions[ticket.source]=state
        end
        return state
    end
    local function rate(state,kind)
        local settings=config.RateLimits[kind]; local now=clock(); local bucket=state.rates[kind]
        if not bucket or now-bucket.start>=settings.window then bucket={start=now,count=0}; state.rates[kind]=bucket end
        if bucket.count>=settings.capacity then return false end
        bucket.count=bucket.count+1; return true
    end
    local function cleanResults(state)
        local now=clock(); local order={}
        for _,id in ipairs(state.order) do
            local result=state.results[id]
            if result and now-result.at<config.ResultCache.ttl then order[#order+1]=id else state.results[id]=nil end
        end
        state.order=order
    end
    local function respond(ticket,reply,response)
        if valid(ticket) then reply(copy(response)) end
    end
    local function complete(item,response)
        item.state.pending[item.request.requestId]=nil
        item.state.pendingCount=item.state.pendingCount-1
        if valid(item.ticket) and sessions[item.ticket.source]==item.state then
            cleanResults(item.state)
            for index=#item.state.order,1,-1 do
                if item.state.order[index]==item.request.requestId then table.remove(item.state.order,index) end
            end
            while #item.state.order>=config.ResultCache.capacity do
                local id=table.remove(item.state.order,1); item.state.results[id]=nil
            end
            item.state.order[#item.state.order+1]=item.request.requestId
            item.state.results[item.request.requestId]={fingerprint=item.fingerprint,response=copy(response),at=clock()}
        end
        for _,reply in ipairs(item.replies) do respond(item.ticket,reply,response) end
    end
    local function normalized(record)
        if not record then return nil end
        local row=copy(record)
        row.short_range=record.short_range==true and 1 or record.short_range==false and 0 or record.short_range
        row.enabled=record.enabled==true and 1 or record.enabled==false and 0 or record.enabled
        return V.fromRow(row,config,catalog.spritesById)
    end
    local function publish(id,before,after)
        -- All changes are observed in the same queue; never modify an existing Record in place.
        if not before and after then count=count+1 elseif before and not after then count=count-1 end
        records[id]=copy(after); sequence=sequence+1
        local oldPublic,newPublic=Service.toPublic(before),Service.toPublic(after)
        local public={epoch=epoch,sequence=sequence,op='noop'}
        if not equal(oldPublic,newPublic) then
            if newPublic then public.op='upsert'; public.record=newPublic else public.op='remove'; public.id=id end
        end
        deps.sendPublic(copy(public))
        local admin={epoch=epoch,sequence=sequence,op=after and 'upsert' or 'remove'}
        if after then admin.record=copy(after) else admin.id=id end
        for source,ticket in pairs(subscribers) do
            if valid(ticket) then deps.sendAdmin(source,copy(admin)) else subscribers[source]=nil end
        end
    end
    local function options()
        local out={Defaults={},Limits={}}
        for _,key in ipairs(P.DraftFields) do out.Defaults[key]=config.Defaults[key] end
        for _,key in ipairs({'name','note','category','scale','x','y','z'}) do
            out.Limits[key]={}
            local fields=(key=='name' or key=='note' or key=='category') and {'minChars','maxChars','maxBytes'} or {'min','max'}
            for _,field in ipairs(fields) do out.Limits[key][field]=config.Limits[key][field] end
        end
        for _,key in ipairs({'MaxBlips','RequestTimeout','PreviewDebounce','TeleportTimeout','ListPageSize','SpritePageSize'}) do
            out[key]=copy(config[key])
        end
        return out
    end
    local function capture(requestId,kind)
        local snapshot={requestId=requestId,epoch=epoch,sequence=sequence,records={}}
        local ids={}; for id in pairs(records) do ids[#ids+1]=id end; table.sort(ids)
        for _,id in ipairs(ids) do
            local record=kind=='admin' and copy(records[id]) or Service.toPublic(records[id])
            if record then snapshot.records[#snapshot.records+1]=record end
        end
        return snapshot
    end
    function service:start()
        if stopped or starting then return false,err('unavailable') end
        if ready then return true end
        starting=true
        local good,fields=V.validateConfig(config)
        if not good then starting=false; return false,err('invalid_draft',fields) end
        local defaults=copy(config.Defaults)
        defaults.name=string.rep('a',config.Limits.name.minChars)
        for _,key in ipairs({'x','y','z'}) do defaults[key]=config.Limits[key].min end
        local draft,draftFields=V.validateDraft(defaults,config,catalog.spritesById)
        if not draft then starting=false; return false,err('invalid_draft',draftFields) end
        local ok,loaded=pcall(function()
            if bridge.loadPermissions then bridge:loadPermissions() end
            return db:loadAll()
        end)
        starting=false
        if not ok or stopped then return false,err('database_error') end
        local fresh,n={},0
        for _,record in ipairs(loaded) do
            local clean=normalized(record)
            if clean and not fresh[clean.id] then fresh[clean.id]=clean; n=n+1 end
        end
        records,count=fresh,n; epoch=deps.epochFactory(); sequence=0; ready=true
        deps.sendReady(epoch); return true
    end
    function service:snapshot(source,requestId,kind)
        if type(requestId)~='string' or #requestId<1 or #requestId>64 or not requestId:match('^[A-Za-z0-9_-]+$') then return nil,err('invalid_request') end
        local ticket=bridge:ticket(source)
        if not ticket or (kind~='public' and kind~='admin') or (kind=='admin' and not valid(ticket)) then return nil,err('unauthorized') end
        if not ready or stopped then return nil,err('unavailable') end
        local state=stateFor(ticket)
        if not rate(state,kind=='public' and 'snapshot' or 'reads') then return nil,err('rate_limited') end
        -- Establish subscription before taking the non-yielding snapshot copy.
        if kind=='admin' then subscribers[source]=copy(ticket) end
        return capture(requestId,kind)
    end

    local function readCurrent(id)
        local ok,current=pcall(function() return db:get(id) end)
        if not ok then return nil,err('database_error') end
        if stopped then return nil,err('unavailable') end
        if current then
            current=normalized(current)
            if not current or current.id~=id then return nil,err('database_error') end
        end
        return current
    end
    local function mutate(item)
        local request=item.request; local payload=request.payload; local action=request.action
        local before=records[payload.id]
        local cached=before
        if action=='create' and count>=config.MaxBlips then return nil,err('limit_reached') end
        if action~='create' and not before then return nil,err('not_found') end
        if before and before.version~=payload.expectedVersion then
            local current,failure=readCurrent(payload.id)
            if failure then return nil,failure end
            if not valid(item.ticket) or sessions[item.ticket.source]~=item.state then return nil,err('unauthorized') end
            if clock()-item.acceptedAt>=config.RequestTimeout then return nil,err('timeout') end
            if not current or current.version~=payload.expectedVersion then
                if not equal(cached,current) then publish(payload.id,cached,current) end
                return nil,err(current and 'conflict' or 'not_found',nil,current)
            end
            -- The requested SQL version is authoritative for fields the mutation preserves.
            before=current
        end
        local stamp=os.date('!%Y-%m-%d %H:%M:%S')
        local after,id
        local ok,result=pcall(function()
            if action=='create' then return db:insert(payload.draft,item.ticket.citizenid,stamp) end
            if action=='update' then return db:update(payload.id,payload.expectedVersion,payload.draft,item.ticket.citizenid,stamp) end
            if action=='setEnabled' then return db:setEnabled(payload.id,payload.expectedVersion,payload.enabled,item.ticket.citizenid,stamp) end
            return db:delete(payload.id,payload.expectedVersion)
        end)
        if not ok then return nil,err('database_error') end
        if stopped then return nil,err('unavailable') end
        if action=='create' then
            if type(result)~='number' or result<1 or result%1~=0 or result>4294967295 then return nil,err('database_error') end
            id=result; after=copy(payload.draft); after.id=id; after.version=1
            after.created_by=item.ticket.citizenid; after.updated_by=item.ticket.citizenid
            after.created_at=stamp; after.updated_at=stamp
        else
            id=payload.id
            if result==0 then
                local current,failure=readCurrent(id)
                if failure then return nil,failure end
                if not equal(cached,current) then publish(id,cached,current) end
                return nil,err(current and 'conflict' or 'not_found',nil,current)
            elseif result~=1 then return nil,err('database_error') end
            if action~='delete' then
                after=action=='update' and copy(payload.draft) or copy(before)
                if action=='setEnabled' then after.enabled=payload.enabled end
                after.id=id; after.version=payload.expectedVersion+1
                after.created_by=before.created_by; after.created_at=before.created_at
                after.updated_by=item.ticket.citizenid; after.updated_at=stamp
            end
        end
        publish(id,cached,after)
        if after then return {record=copy(after),epoch=epoch,sequence=sequence} end
        return {id=id,epoch=epoch,sequence=sequence}
    end
    local function drain()
        while #queue>0 do
            local item=table.remove(queue,1)
            local data,failure
            if not ready or stopped then failure=err('unavailable')
            elseif not valid(item.ticket) or sessions[item.ticket.source]~=item.state then failure=err('unauthorized')
            elseif clock()-item.acceptedAt>=config.RequestTimeout then failure=err('timeout')
            else data,failure=mutate(item) end
            outstanding=outstanding-1
            complete(item,{requestId=item.request.requestId,ok=failure==nil,data=data,error=failure})
        end
        draining=false
    end
    function service:request(source,input,reply)
        -- Authority is derived exclusively from the event source, before accepting any action.
        local ticket=bridge:ticket(source)
        local requestId=type(input)=='table' and type(input.requestId)=='string' and #input.requestId<=64 and input.requestId or nil
        local function reject(failure)
            if ticket then
                if active(ticket) then reply({requestId=requestId,ok=false,error=failure}) end
            else reply({requestId=requestId,ok=false,error=failure}) end
        end
        if not ticket or not valid(ticket) then reject(err('unauthorized')); return end
        local request,failure=P.validateRequest(input)
        if not request then reject(failure); return end
        request=copy(request)
        local fingerprint=P.fingerprint(request.action,request.payload)
        if not ready or stopped then reject(err('unavailable')); return end
        if request.payload.draft then
            local draft,fields=V.validateDraft(request.payload.draft,config,catalog.spritesById)
            if not draft then reject(err('invalid_draft',fields)); return end
            request.payload.draft=draft
        end
        local state=stateFor(ticket)
        cleanResults(state)
        local previous=state.pending[request.requestId] or state.results[request.requestId]
        if previous then
            if previous.fingerprint~=fingerprint then reject(err('invalid_request')); return end
            if previous.response then
                -- Mutations/teleport must replay their result; reads/close must restore current panel state.
                if mutations[request.action] or request.action=='teleport' then respond(ticket,reply,previous.response); return end
            elseif #previous.replies<config.MaxPendingPerPlayer then previous.replies[#previous.replies+1]=reply
                return
            else reject(err('queue_full')); return end
        end
        if mutations[request.action] then
            if outstanding>=config.QueueCapacity or state.pendingCount>=config.MaxPendingPerPlayer then reject(err('queue_full')); return end
            if not rate(state,'mutations') then reject(err('rate_limited')); return end
            local item={ticket=copy(ticket),state=state,request=request,fingerprint=fingerprint,replies={reply},acceptedAt=clock()}
            state.pending[request.requestId]=item; state.pendingCount=state.pendingCount+1
            queue[#queue+1]=item; outstanding=outstanding+1
            if not draining then draining=true; spawn(drain) end
            return
        end
        local data
        if request.action=='open' or request.action=='list' then
            if request.action=='open' and bridge.rememberPermission then
                local remembered,code=bridge:rememberPermission(ticket)
                if not remembered then reject(err(code)); return end
                if not ready or stopped then reject(err('unavailable')); return end
                if not valid(ticket) or sessions[ticket.source]~=state then reject(err('unauthorized')); return end
            end
            local snapshot; snapshot,failure=self:snapshot(source,request.requestId,'admin')
            if snapshot then data={snapshot=snapshot,options=options()} end
        elseif request.action=='close' then
            subscribers[source]=nil; data={closed=true}
        elseif request.action=='teleport' then
            if not rate(state,'teleport') then failure=err('rate_limited')
            else
                local allowed; allowed,failure=bridge:canTeleport(source)
                local record=records[request.payload.id]
                if allowed and not record then failure=err('not_found') end
                if allowed and record and valid(ticket) then
                    deps.sendTeleport(source,{requestId=request.requestId,target={x=record.x,y=record.y,z=record.z}})
                    data={accepted=true}
                end
            end
        end
        state.pendingCount=state.pendingCount+1
        complete({ticket=ticket,state=state,request=request,fingerprint=fingerprint,replies={reply}},
            {requestId=request.requestId,ok=failure==nil,data=data,error=failure})
    end
    function service:drop(source)
        subscribers[source]=nil; sessions[source]=nil; bridge:drop(source)
    end
    function service:shutdown()
        stopped=true; ready=false; subscribers={}; sessions={}
    end
    return service
end
