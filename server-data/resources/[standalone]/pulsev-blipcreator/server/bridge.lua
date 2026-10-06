PulseV = PulseV or {}
local Bridge = {}
PulseV.Bridge = Bridge

function Bridge.isCallable(value)
    if type(value)=='function' then return true end
    -- FiveM exports deserialize function references as tables with __call.
    local mt=type(value)=='table' and getmetatable(value)
    return type(mt)=='table' and type(mt.__call)=='function'
end

function Bridge.validLicense(value)
    return type(value)=='string' and #value==48 and value:match('^license:[0-9a-f]+$')~=nil
end

function Bridge.new(core,natives,config,db)
    local bridge={}
    local sessions,serial={},0
    local permissions,busy,permissionsReady={},{},false
    local function licenseFor(source)
        if not Bridge.isCallable(natives.GetPlayerIdentifierByType) then return nil end
        local ok,value=pcall(natives.GetPlayerIdentifierByType,source,'license')
        if ok and Bridge.validLicense(value) then return value end
    end
    local function identity(source)
        if source==0 then return nil,'console_source' end
        if type(source)~='number' or source%1~=0 or source<=0 or not natives.GetPlayerName(source) then return nil,'inactive_player' end
        local player=core.Functions.GetPlayer(source)
        local data=player and player.PlayerData
        if not data then return nil,'player_not_loaded' end
        if data.source~=source or type(data.citizenid)~='string' then return nil,'invalid_player_identity' end
        local length=utf8.len(data.citizenid)
        if not length or length<1 or length>64 or #data.citizenid>256 or data.citizenid:find('[%z\1-\31\127]') then return nil,'invalid_player_identity' end
        local license=licenseFor(source)
        if db and not license then return nil,'invalid_license' end
        return data.citizenid,nil,license
    end
    function bridge:ticket(source)
        local citizenid,_,license=identity(source)
        if not citizenid then sessions[source]=nil; return nil end
        local session=sessions[source]
        if not session or session.citizenid~=citizenid or session.license~=license then
            serial=serial+1; session={source=source,generation=serial,citizenid=citizenid,license=license}; sessions[source]=session
        end
        return {source=source,generation=session.generation,citizenid=session.citizenid,license=session.license}
    end
    function bridge:isCurrent(ticket)
        if type(ticket)~='table' then return false end
        local current=self:ticket(ticket.source)
        return current~=nil and current.generation==ticket.generation and current.citizenid==ticket.citizenid and current.license==ticket.license
    end
    function bridge:permissionStatus(source)
        local citizenid,reason,license=identity(source)
        local status={allowed=false,active=citizenid~=nil,reason=reason or 'permission_denied',qbcore={},ace={}}
        if not citizenid then return status end
        if license and permissions[license]==false then status.reason='persistent_permission_revoked'; return status end
        local failed=false
        local function check(provider,permission)
            if not Bridge.isCallable(provider) then failed=true; return 'unavailable' end
            local ok,result=pcall(provider,source,permission)
            if not ok then failed=true; return 'error' end
            return result==true
        end
        -- Individual strings also support older/custom QBCore permission providers.
        for _,permission in ipairs(config.Permissions or {}) do
            local result=check(core.Functions.HasPermission,permission)
            status.qbcore[permission]=result
            if result==true then status.allowed=true; status.reason='qbcore_permission' end
        end
        for _,permission in ipairs(config.AcePermissions or {}) do
            local result=check(natives.IsPlayerAceAllowed,permission)
            status.ace[permission]=result
            if result==true and not status.allowed then status.allowed=true; status.reason='ace_permission' end
        end
        if failed and not status.allowed then status.reason='permission_check_failed' end
        if license and permissions[license]==true then status.allowed=true; status.reason='license_permission' end
        return status
    end
    function bridge:loadPermissions()
        if not db then return end
        permissionsReady=false
        local fresh={}
        for _,row in ipairs(db:loadPermissions()) do
            if Bridge.validLicense(row.license) then
                if row.allowed==true or row.allowed==1 or row.allowed=='1' then fresh[row.license]=true
                elseif row.allowed==false or row.allowed==0 or row.allowed=='0' then fresh[row.license]=false
                else error('invalid permission row') end
            else error('invalid permission license') end
        end
        permissions=fresh; permissionsReady=true
    end
    function bridge:setPermission(license,allowed)
        if not db or not Bridge.validLicense(license) or type(allowed)~='boolean' then return false,'invalid_request' end
        if not permissionsReady then return false,'unavailable' end
        if busy[license] then return false,'unavailable' end
        busy[license]=true
        local ok,result=pcall(function() return db:setPermission(license,allowed) end)
        busy[license]=nil
        if not ok or type(result)~='number' then return false,'database_error' end
        permissions[license]=allowed
        return true
    end
    function bridge:rememberPermission(ticket)
        if not db then return true end
        if not self:isCurrent(ticket) or not self:isAllowed(ticket.source) then return false,'unauthorized' end
        if permissions[ticket.license]==true then return true end
        local ok,code=self:setPermission(ticket.license,true)
        if not ok then return false,code end
        if not self:isCurrent(ticket) or not self:isAllowed(ticket.source) then return false,'unauthorized' end
        return true
    end
    function bridge:isAllowed(source)
        return self:permissionStatus(source).allowed
    end
    function bridge:canTeleport(source)
        if not self:isAllowed(source) then return false,{code='unauthorized',message=PulseV.Locales.tr.unauthorized} end
        local ped=natives.GetPlayerPed(source)
        if not ped or ped==0 or natives.GetVehiclePedIsIn(ped,false)~=0 then
            return false,{code='teleport_failed',message='Teleport için yaya olmalısınız.'}
        end
        return true
    end
    function bridge:drop(source) sessions[source]=nil end
    return bridge
end
