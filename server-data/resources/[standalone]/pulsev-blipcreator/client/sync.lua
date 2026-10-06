PulseV = PulseV or {}
PulseV.Sync = {}
-- A reset or a new sync instance must not correlate an earlier session's reply.
local nextRequestId = 0
local function copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}
    for key,item in pairs(value) do result[key] = copy(item) end
    return result
end
local function sequenceValid(value)
    return type(value)=='number' and value>=0 and value<math.huge and value%1==0
end

function PulseV.Sync.new(deps)
    local config = deps.config or {}
    local cap = config.SnapshotBuffer or 512
    local timeout = config.RequestTimeout or 10000
    local retryInterval = config.StartupRetryInterval or 1000
    local retryLimit = config.StartupRetryCount or 3
    local rate = config.RateLimits and config.RateLimits.snapshot or {window=5000,capacity=2}
    local recoveryInterval = math.ceil(rate.window/rate.capacity)
    local epoch,sequence,pending = nil,0,nil
    local buffer,count,overflow = {},0,false
    local initialized,retries,generation,retryToken = false,0,0,0
    local issued,hints,hintCount,retired,retiredOrder = 0,{},0,{},{}
    local recoveryCooldown,recoveryQueued = false,false
    local recoveryRemaining,readyObserved = retryLimit+1,false
    local sync = {}
    local function clearBuffer() buffer,count,overflow = {},0,false end
    local function startupRetry(delay)
        if initialized or retries>=retryLimit then return end
        retries = retries+1
        local session,token = generation,retryToken
        deps.schedule(delay or retryInterval,function()
            if generation==session and retryToken==token and not initialized and not pending then sync:request() end
        end)
    end
    function sync:request()
        nextRequestId = nextRequestId+1
        local id = 'snapshot-'..nextRequestId
        pending = id
        issued = issued+1
        recoveryQueued = false
        recoveryRemaining = retryLimit+1
        retryToken = retryToken+1
        local session = generation
        deps.schedule(timeout,function()
            if generation~=session or pending~=id then return end
            pending = nil
            startupRetry()
        end)
        -- The dependency transports this string as the server requestId.
        deps.requestSnapshot(id)
        return id
    end
    local function resync()
        if pending or recoveryRemaining<=0 then return end
        if recoveryCooldown then recoveryQueued=true; return end
        local remaining = recoveryRemaining
        sync:request()
        recoveryRemaining = remaining-1
        recoveryCooldown = true
        local session = generation
        deps.schedule(recoveryInterval,function()
            if generation~=session then return end
            recoveryCooldown = false
            if recoveryQueued then recoveryQueued=false; resync() end
        end)
    end
    local function retire(value)
        if retired[value] then return end
        retired[value] = true
        retiredOrder[#retiredOrder+1] = value
        if #retiredOrder>cap then retired[table.remove(retiredOrder,1)] = nil end
    end
    local function hint(value)
        if value==epoch or retired[value] or hints[value] then return end
        if hintCount>=cap then clearBuffer(); overflow=true; return true end
        -- One confirmation capture after the request associated with this hint
        -- resolves it, even if the server keeps returning its current epoch.
        hints[value] = issued+(pending and 0 or 1)
        hintCount = hintCount+1
        return true
    end
    local function enqueue(delta)
        if overflow then return end
        local key = delta.epoch..'\0'..delta.sequence
        if buffer[key] then return end
        if count>=cap then clearBuffer(); overflow=true; return end
        buffer[key],count = copy(delta),count+1
    end
    local function replay()
        local deltas,foreign = {},{}
        for _,delta in pairs(buffer) do
            if delta.epoch==epoch and delta.sequence>sequence then deltas[#deltas+1] = delta end
            if hints[delta.epoch] then foreign[#foreign+1] = delta end
        end
        clearBuffer()
        table.sort(deltas,function(a,b) return a.sequence<b.sequence end)
        for _,delta in ipairs(deltas) do
            if delta.sequence==sequence+1 then
                deps.applyDelta(delta)
                sequence = delta.sequence
            else
                enqueue(delta)
            end
        end
        for _,delta in ipairs(foreign) do enqueue(delta) end
        if count>0 or hintCount>0 then resync() end
    end
    function sync:receiveSnapshot(snapshot)
        if type(snapshot)~='table' or not pending or snapshot.requestId~=pending then return end
        if snapshot.error then
            pending = nil
            if snapshot.error.code=='unavailable' then startupRetry() end
            if snapshot.error.code=='rate_limited' then startupRetry(math.max(retryInterval,recoveryInterval)) end
            return
        end
        if type(snapshot.epoch)~='string' or not sequenceValid(snapshot.sequence)
            or type(snapshot.records)~='table' then return end
        pending = nil
        if overflow or (epoch==snapshot.epoch and snapshot.sequence<sequence) then
            clearBuffer(); resync(); return
        end
        local previousEpoch = epoch
        if previousEpoch~=snapshot.epoch or snapshot.sequence>sequence then recoveryRemaining=retryLimit+1 end
        deps.applySnapshot(copy(snapshot.records))
        epoch,sequence,initialized = snapshot.epoch,snapshot.sequence,true
        retries = 0
        retryToken = retryToken+1
        if previousEpoch and previousEpoch~=epoch then retire(previousEpoch) end
        for value,observedRequest in pairs(hints) do
            if value==epoch or issued>observedRequest or retired[value] then
                hints[value],hintCount = nil,hintCount-1
                if value~=epoch then retire(value) end
            end
        end
        replay()
    end
    function sync:receiveDelta(delta)
        if type(delta)~='table' or type(delta.epoch)~='string' or not sequenceValid(delta.sequence)
            or (delta.op~='upsert' and delta.op~='remove' and delta.op~='noop') then return end
        if retired[delta.epoch] then return end
        if delta.epoch==epoch and delta.sequence<=sequence then return end
        if buffer[delta.epoch..'\0'..delta.sequence] then return end
        recoveryRemaining = retryLimit+1
        if delta.epoch~=epoch then hint(delta.epoch) end
        if pending or delta.epoch~=epoch or delta.sequence~=sequence+1 or overflow then
            enqueue(delta); resync(); return
        end
        deps.applyDelta(copy(delta))
        sequence = delta.sequence
        replay()
    end
    function sync:onReady(readyEpoch)
        if readyEpoch~=nil and type(readyEpoch)~='string' then return end
        if initialized and (readyEpoch==nil or readyEpoch==epoch) then return end
        if readyEpoch and retired[readyEpoch] then return end
        if readyEpoch then
            if hint(readyEpoch) then recoveryRemaining=retryLimit+1 end
        elseif not readyObserved then
            readyObserved=true; recoveryRemaining=retryLimit+1
        end
        resync()
    end
    function sync:reset()
        generation,retryToken = generation+1,retryToken+1
        epoch,sequence,pending,initialized,retries = nil,0,nil,false,0
        issued,hints,hintCount,retired,retiredOrder = 0,{},0,{},{}
        recoveryCooldown,recoveryQueued = false,false
        recoveryRemaining,readyObserved = retryLimit+1,false
        clearBuffer()
    end
    return sync
end
