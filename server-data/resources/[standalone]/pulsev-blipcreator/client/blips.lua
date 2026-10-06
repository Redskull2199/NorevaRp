PulseV = PulseV or {}
PulseV.Blips = {}
local fields = {'id','name','sprite','color','scale','alpha','display','short_range',
    'x','y','z','rotation','map_category'}

local function finite(value)
    return type(value)=='number' and value==value and value~=math.huge and value~=-math.huge
end
local function integer(value,min,max)
    return finite(value) and value%1==0 and value>=min and value<=max
end
local function renderFieldError(record,options)
    if type(record)~='table' then return 'record' end
    if record.id~='preview' and not integer(record.id,1,4294967295) then return 'id' end
    if type(record.name)~='string' or not utf8.len(record.name) or #record.name==0 then return 'name' end
    local limits=options.config and options.config.Limits
    for _,key in ipairs({'x','y','z','scale'}) do
        local value=record[key]
        if not finite(value) then return key end
        local limit=limits and limits[key]
        if limit and (value<limit.min or value>limit.max) then return key end
    end
    if record.scale<=0 then return 'scale' end
    for key,range in pairs({sprite={0,65535},color={0,85},alpha={0,255},display={0,10},rotation={0,359},map_category={1,254}}) do
        if not integer(record[key],range[1],range[2]) then return key end
    end
    if options.sprites and not options.sprites[record.sprite] then return 'sprite' end
    if type(record.short_range)~='boolean' then return 'short_range' end
end

function PulseV.Blips.new(natives,options)
    options=options or {config=PulseV.Config}
    local entries, size = {}, 0
    local store = {}
    local doesExist=rawget(natives,'DoesBlipExist')
    local function exists(handle)
        return finite(handle) and handle%1==0 and handle~=0 and (not doesExist or doesExist(handle)==true)
    end
    local function report(code,record,field)
        if options.onError then options.onError(code,type(record)=='table' and record.id or nil,field) end
        return false
    end
    function store:remove(id)
        local entry = entries[id]
        if not entry then return true end
        if exists(entry.handle) then natives.RemoveBlip(entry.handle) end
        entries[id], size = nil, size - 1
        return true
    end
    function store:upsert(record)
        if type(record)=='table' and record.enabled==false then return self:remove(record.id) end
        local field=renderFieldError(record,options)
        if field then return report('invalid_map_record',record,field) end
        local entry = entries[record.id]
        if entry then
            local equal = true
            for _, field in ipairs(fields) do
                if entry.record[field] ~= record[field] then equal = false; break end
            end
            if equal and exists(entry.handle) then return true end
            self:remove(record.id)
        end
        -- Remove before replacing, including handles invalidated by spawn/map cleanup.
        local h=natives.AddBlipForCoord(record.x+0.0,record.y+0.0,record.z+0.0)
        if not exists(h) then return report('map_handle_failed',record,'handle') end
        entry={handle=h}
        natives.SetBlipCoords(h,record.x+0.0,record.y+0.0,record.z+0.0)
        natives.SetBlipSprite(h,record.sprite)
        natives.SetBlipColour(h,record.color)
        natives.SetBlipScale(h,record.scale+0.0)
        natives.SetBlipAlpha(h,record.alpha)
        natives.SetBlipDisplay(h,record.display)
        natives.SetBlipAsShortRange(h,record.short_range)
        natives.SetBlipRotation(h,record.rotation)
        natives.SetBlipCategory(h,record.map_category)
        natives.BeginTextCommandSetBlipName('STRING')
        local first = 1
        while first <= #record.name do
            local last = math.min(first+98,#record.name)
            -- The following byte must start a codepoint; back up past continuations.
            while last < #record.name do
                local byte = record.name:byte(last+1)
                if byte < 128 or byte >= 192 then break end
                last = last-1
            end
            natives.AddTextComponentSubstringPlayerName(record.name:sub(first,last))
            first = last+1
        end
        natives.EndTextCommandSetBlipName(h)
        entry.record = {}
        for _, field in ipairs(fields) do entry.record[field] = record[field] end
        entries[record.id],size=entry,size+1
        return true
    end
    function store:reconcile(records)
        if type(records)~='table' then return report('invalid_map_record',nil,'records') end
        -- A full authoritative snapshot rebuilds GTA state, not just the Lua cache.
        self:clear()
        local seen = {}
        for _, record in ipairs(records) do
            local id=type(record)=='table' and record.id
            if id and not seen[id] and self:upsert(record) then seen[id]=true end
        end
        return true
    end
    function store:clear()
        for id in pairs(entries) do self:remove(id) end
    end
    function store:count() return size end
    return store
end
