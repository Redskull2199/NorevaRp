PulseV = PulseV or {}
PulseV.Preview = {}

function PulseV.Preview.new(deps)
    local config = deps.config or PulseV.Config
    local generation, state, token, fingerprint = 0, 'closed', 0, nil
    local preview = {}
    function preview:setSession(value, nextState)
        if generation ~= value or nextState == 'closed' then token = token + 1 end
        generation, state = value, nextState
        if state == 'closed' then self:clear() end
    end
    function preview:clear()
        token, fingerprint = token + 1, nil
        deps.blips:clear()
    end
    function preview:apply(draft, session)
        if session ~= generation or state ~= 'open' then return nil, {code='stale_session',message='Panel oturumu kapalı.'} end
        local valid, fields = PulseV.Validation.validateDraft(draft, config,
            (deps.catalog or PulseV.Catalog).spritesById)
        if not valid then return nil, {code='validation',message='Önizleme alanlarını kontrol edin.',fields=fields} end
        local nextFingerprint = PulseV.Protocol.fingerprint('preview', {draft=valid})
        if nextFingerprint == fingerprint then return true end
        token = token + 1
        local captured = token
        fingerprint = nextFingerprint
        deps.schedule(config.PreviewDebounce or 200, function()
            if token ~= captured or generation ~= session or state == 'closed' then return end
            valid.id, valid.enabled = 'preview', true
            deps.blips:upsert(valid)
        end)
        return true
    end
    return preview
end
