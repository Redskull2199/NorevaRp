PulseV = PulseV or {}
local V = {}
PulseV.Validation = V
local draftFields = {'name','note','sprite','color','scale','alpha','display','short_range',
    'x','y','z','rotation','category','map_category','enabled'}
local allowed = {}
for _, key in ipairs(draftFields) do allowed[key]=true end
local function finite(value) return type(value)=='number' and value==value and value~=math.huge and value~=-math.huge end
local function integer(value,min,max) return finite(value) and value%1==0 and value>=min and value<=max end
local function text(value,limits,trim,allowLF,noFormat)
    if type(value)~='string' or type(limits)~='table' then return nil end
    if trim then value=value:gsub('^ +',''):gsub(' +$','') end
    local count=utf8.len(value)
    if not count or count<limits.minChars or count>limits.maxChars or #value>limits.maxBytes then return nil end
    for _, cp in utf8.codes(value) do
        if (cp<32 and not (allowLF and cp==10)) or (cp>=127 and cp<=159) then return nil end
    end
    if noFormat and value:find('~[^~]*~') then return nil end
    return value
end
local function mapCategory(value)
    return integer(value,1,254) and (value==1 or value==2 or value==7 or value>=10)
end
function V.validateDraft(input,config,sprites)
    local errors, result = {}, {}
    if type(input)~='table' then return nil,{draft='Nesne bekleniyor.'} end
    for key in pairs(input) do if not allowed[key] then errors[key]='Bilinmeyen alan.' end end
    for _, key in ipairs({'name','note','category'}) do
        result[key]=text(input[key],config.Limits[key],key~='note',key=='note',key=='name')
        if result[key]==nil then errors[key]='Geçerli metin ve uzunluk gerekli.' end
    end
    for _, key in ipairs({'scale','x','y','z'}) do
        local value,limit=input[key],config.Limits[key]
        if not finite(value) or value<limit.min or value>limit.max
            or (key=='scale' and math.abs(value*100-math.floor(value*100+0.5))>0.00000001) then
            errors[key]='Sonlu ve sınırlar içinde sayı gerekli.'
        else result[key]=value end
    end
    local ranges={color={0,85},alpha={0,255},display={0,10},rotation={0,359}}
    for key, range in pairs(ranges) do
        if not integer(input[key],range[1],range[2]) then errors[key]='İzin verilen tam sayı gerekli.' else result[key]=input[key] end
    end
    if not integer(input.sprite,0,65535) or type(sprites)~='table' or not sprites[input.sprite] then errors.sprite='Desteklenmeyen sprite.' else result.sprite=input.sprite end
    if not mapCategory(input.map_category) then errors.map_category='Desteklenmeyen harita kategorisi.' else result.map_category=input.map_category end
    for _, key in ipairs({'short_range','enabled'}) do
        if type(input[key])~='boolean' then errors[key]='Boolean gerekli.' else result[key]=input[key] end
    end
    if next(errors) then return nil,errors end
    return result,errors
end
function V.validateConfig(config)
    local errors={}
    if type(config)~='table' then return false,{config='Nesne bekleniyor.'} end
    local function fail(key) errors[key]='Geçersiz Config değeri.' end
    local limits=type(config.Limits)=='table' and config.Limits or {}
    local capacities={name={64,256,1},note={512,2048,0},category={48,192,1}}
    for key, capacity in pairs(capacities) do
        local limit=limits[key]
        if type(limit)~='table' or not integer(limit.minChars,capacity[3],capacity[1])
            or not integer(limit.maxChars,capacity[3],capacity[1]) or limit.minChars>limit.maxChars
            or not integer(limit.maxBytes,limit.maxChars,capacity[2]) then fail('Limits.'..key) end
    end
    for _, key in ipairs({'scale','x','y','z'}) do
        local limit=limits[key]
        if type(limit)~='table' or not finite(limit.min) or not finite(limit.max) or limit.min>limit.max
            or (key=='scale' and (limit.min<0.01 or limit.max>99.99)) then fail('Limits.'..key) end
    end
    for _, key in ipairs({'MaxBlips','RequestTimeout','PreviewDebounce','TeleportTimeout','ListPageSize','SpritePageSize',
        'QueueCapacity','MaxPendingPerPlayer','SnapshotBuffer','SnapshotBandwidth','StartupRetryInterval','StartupRetryCount'}) do
        if not integer(config[key],1,4294967295) then fail(key) end
    end
    if type(config.Command)~='string' or not config.Command:match('^[A-Za-z0-9_-]+$') then fail('Command') end
    if type(config.Debug)~='boolean' then fail('Debug') end
    local function permissionList(key,optional)
        local list=config[key]
        if optional and list==nil then return 0 end
        if type(list)~='table' then fail(key); return 0 end
        for index,permission in pairs(list) do
            if not integer(index,1,#list) or type(permission)~='string'
                or not permission:match('^[A-Za-z0-9_.-]+$')
                or permission=='user' or permission=='builtin.everyone' then fail(key) end
        end
        return #list
    end
    local roles=permissionList('Permissions',false)
    local aces=permissionList('AcePermissions',true)
    if roles+aces==0 then fail('Permissions'); fail('AcePermissions') end
    for _, entry in ipairs({{'ResultCache','ttl','capacity'}}) do
        local value=config[entry[1]]
        if type(value)~='table' then fail(entry[1]) else
            for index=2,#entry do if not integer(value[entry[index]],1,4294967295) then fail(entry[1]..'.'..entry[index]) end end
        end
    end
    for _, key in ipairs({'snapshot','reads','mutations','teleport'}) do
        local value=type(config.RateLimits)=='table' and config.RateLimits[key]
        if type(value)~='table' or not integer(value.capacity,1,4294967295) or not integer(value.window,1,4294967295) then fail('RateLimits.'..key) end
    end
    local notification=config.Notification
    if type(notification)~='table' or not ({nui=true,qbcore=true,custom=true})[notification.adapter]
        or (notification.adapter=='custom' and (type(notification.customEvent)~='string' or notification.customEvent=='')) then fail('Notification') end
    if not next(errors) then
        local draft={name='A',x=0,y=0,z=0}
        if type(config.Defaults)~='table' then fail('Defaults') else
            for key,value in pairs(config.Defaults) do draft[key]=value end
            -- Required fields are selected within configured bounds; they have no default coordinates.
            draft.name=string.rep('A',limits.name.minChars)
            for _, key in ipairs({'x','y','z'}) do draft[key]=math.max(limits[key].min,math.min(0,limits[key].max)) end
            local defaultSprite=config.Defaults.sprite
            local catalog={}; if integer(defaultSprite,0,65535) then catalog[defaultSprite]=true end
            local _, fields=V.validateDraft(draft,config,catalog)
            for key in pairs(fields) do fail('Defaults.'..key) end
        end
    end
    return next(errors)==nil,errors
end
local function dbNumber(value)
    if type(value)=='number' then return value end
    if type(value)=='string' and (value:match('^%-?%d+%.?%d*$') or value:match('^%-?%d*%.%d+$')) then return tonumber(value) end
    return nil
end
local function dbBoolean(value)
    -- oxmysql typecasts TINYINT(1) to Lua booleans on query results.
    if type(value)=='boolean' then return value end
    if value==0 or value=='0' then return false end
    if value==1 or value=='1' then return true end
    return nil
end
function V.fromRow(row,config,sprites)
    if type(row)~='table' then return nil,{row='Nesne bekleniyor.'} end
    local draft={}
    for _, key in ipairs(draftFields) do
        if key=='short_range' or key=='enabled' then draft[key]=dbBoolean(row[key])
        elseif key=='name' or key=='note' or key=='category' then draft[key]=row[key]
        else draft[key]=dbNumber(row[key]) end
    end
    local record,errors=V.validateDraft(draft,config,sprites)
    record=record or {}
    for _, key in ipairs({'id','version'}) do
        record[key]=dbNumber(row[key])
        if not integer(record[key],1,4294967295) then errors[key]='Pozitif SQL tam sayısı gerekli.' end
    end
    for _, key in ipairs({'created_by','updated_by'}) do
        record[key]=text(row[key],{minChars=1,maxChars=64,maxBytes=256},false,false,false)
        if not record[key] then errors[key]='Geçersiz aktör.' end
    end
    for _, key in ipairs({'created_at','updated_at'}) do
        local value=row[key]
        if type(value)~='string' or not value:match('^%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d$') then errors[key]='Geçersiz SQL zaman damgası.' else record[key]=value end
    end
    if next(errors) then return nil,errors end
    return record,errors
end
