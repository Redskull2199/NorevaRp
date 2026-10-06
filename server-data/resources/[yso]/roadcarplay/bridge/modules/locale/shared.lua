-- Shared Locale Module
-- Framework-agnostic locale system for RoadPhone

Bridge = Bridge or {}
Bridge.Locale = {}
Locales = Locales or {}

-- Translate function
function Bridge.Locale.Translate(key, ...)
    local args = {...}

    -- Use RoadPhone's locale system
    if Config and Config.Locale and Locales[Config.Locale] then
        local locale = Locales[Config.Locale]
        if locale[key] then
            if #args > 0 then
                return string.format(locale[key], table.unpack(args))
            else
                return locale[key]
            end
        end
    end

    -- Return key if no translation found
    return key
end

-- Shorthand alias for translation (works across all frameworks)
_U = Bridge.Locale.Translate
