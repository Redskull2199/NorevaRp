PulseV = PulseV or {}
local P = {}
PulseV.Protocol = P
P.Events = {
    requestSnapshot='pulsev-blipcreator:server:requestSnapshot', request='pulsev-blipcreator:server:request',
    snapshot='pulsev-blipcreator:client:snapshot', ready='pulsev-blipcreator:client:ready',
    delta='pulsev-blipcreator:client:delta', response='pulsev-blipcreator:client:response',
    open='pulsev-blipcreator:client:open', adminDelta='pulsev-blipcreator:client:adminDelta',
    teleport='pulsev-blipcreator:client:teleport',
}
P.NuiCallbacks = {
    close='close',minimize='minimize',list='list',create='create',update='update',delete='delete',
    setEnabled='setEnabled',teleport='teleport',getPosition='getPosition',preview='preview',clearPreview='clearPreview',
}
P.DraftFields = {'name','note','sprite','color','scale','alpha','display','short_range',
    'x','y','z','rotation','category','map_category','enabled'}
-- Server Response = {requestId,ok,data?,error?}; Error = {code,message,fields?,current?}.
-- current is an authorized conflict Record. Failed Snapshot = {requestId,error}.
-- NUI POST = {generation,payload}; callback = {generation,ok,data?,error?};
-- message = {type,generation,data}. generation is local and never part of Request.
local shapes = {open={},list={},close={},create={'draft'},update={'id','expectedVersion','draft'},
    delete={'id','expectedVersion'},setEnabled={'id','expectedVersion','enabled'},teleport={'id'}}
local function exact(value, keys)
    if type(value) ~= 'table' then return false end
    local allowed = {}
    for _, key in ipairs(keys) do allowed[key]=true; if value[key] == nil then return false end end
    for key in pairs(value) do if not allowed[key] then return false end end
    return true
end
local function positiveInt(value)
    return type(value)=='number' and value==value and value>=1 and value<=4294967295 and value%1==0
end
function P.validateRequest(input)
    local function bad(field)
        return nil, {code='invalid_request',message='Geçersiz istek.',fields={[field]='Geçersiz değer.'}}
    end
    if not exact(input,{'requestId','action','payload'}) then return bad('request') end
    if type(input.requestId)~='string' or #input.requestId<1 or #input.requestId>64
        or not input.requestId:match('^[A-Za-z0-9_-]+$') then return bad('requestId') end
    local shape = type(input.action)=='string' and shapes[input.action]
    if not shape then return bad('action') end
    if not exact(input.payload,shape) then return bad('payload') end
    local payload = input.payload
    if payload.id~=nil and not positiveInt(payload.id) then return bad('id') end
    if payload.expectedVersion~=nil and not positiveInt(payload.expectedVersion) then return bad('expectedVersion') end
    if payload.enabled~=nil and type(payload.enabled)~='boolean' then return bad('enabled') end
    if payload.draft~=nil then
        if not exact(payload.draft,P.DraftFields) then return bad('draft') end
        for _, key in ipairs(P.DraftFields) do
            local expected = ({name='string',note='string',category='string',short_range='boolean',enabled='boolean'})[key] or 'number'
            if type(payload.draft[key])~=expected then return bad('draft.'..key) end
        end
    end
    -- Value limits and sprite membership are validated with the configured catalog by Validation.
    return input
end
local function encode(value)
    local kind = type(value)
    if kind=='nil' then return 'n;' end
    if kind=='boolean' then return value and 'b1;' or 'b0;' end
    local text = kind=='number' and string.format('%.17g',value==0 and 0 or value) or tostring(value)
    return kind:sub(1,1)..#text..':'..text
end
function P.fingerprint(action,payload)
    local parts = {encode(action)}
    for _, key in ipairs({'id','expectedVersion','enabled'}) do parts[#parts+1]=encode(payload[key]) end
    for _, key in ipairs(P.DraftFields) do parts[#parts+1]=encode(payload.draft and payload.draft[key]) end
    return table.concat(parts)
end
