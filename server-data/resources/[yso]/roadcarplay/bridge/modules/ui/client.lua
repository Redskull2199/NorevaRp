-- Client UI Module

Bridge = Bridge or {}
Bridge.UI = {}

-- Helper: Ensure framework is ready
local function EnsureFrameworkReady()
    if Bridge.EnsureReady then
        Bridge.EnsureReady()
    elseif not Bridge.Ready then
        while not Bridge.Framework do
            Wait(100)
        end
    end
end

-- Show notification
function Bridge.UI.Notify(message, type, duration)
    EnsureFrameworkReady()
    type = type or 'info'
    duration = duration or 5000

    if Bridge.Framework == 'esx' then
        Bridge.FrameworkObject.ShowNotification(message, type, duration)
    elseif Bridge.Framework == 'qbcore' then
        Bridge.FrameworkObject.Functions.Notify(message, type, duration)
    elseif Bridge.Framework == 'qbox' then
        Bridge.FrameworkExport:Notify(message, type, duration)
    elseif Bridge.Framework == 'standalone' then
        -- Fallback for Standalone
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

-- Show advanced notification (with title and icon)
function Bridge.UI.AdvancedNotify(title, subject, message, icon, iconType, duration)
    EnsureFrameworkReady()
    duration = duration or 5000

    if Bridge.Framework == 'esx' then
        Bridge.FrameworkObject.ShowAdvancedNotification(title, subject, message, icon, iconType, duration)
    elseif Bridge.Framework == 'qbcore' then
        -- QBCore uses simple notifications
        local fullMessage = title .. ': ' .. message
        Bridge.FrameworkObject.Functions.Notify(fullMessage, iconType or 'primary', duration)
    elseif Bridge.Framework == 'qbox' then
        -- QBX also uses simpler notifications
        local fullMessage = title .. ': ' .. message
        Bridge.FrameworkExport:Notify(fullMessage, iconType or 'inform', duration)
    elseif Bridge.Framework == 'standalone' then
        SetNotificationTextEntry('STRING')
        AddTextComponentString(message)
        SetNotificationMessage(icon or 'CHAR_DEFAULT', icon or 'CHAR_DEFAULT', true, iconType or 1, title, subject)
        DrawNotification(false, true)
    end
end

-- Show help notification (bottom left)
function Bridge.UI.ShowHelpNotification(message, duration)
    EnsureFrameworkReady()
    duration = duration or 5000

    if Bridge.Framework == 'esx' then
        Bridge.FrameworkObject.ShowHelpNotification(message)
    elseif Bridge.Framework == 'qbcore' then
        -- QBCore has no separate help notification, use DrawText
        AddTextEntry('qbHelpNotification', message)
        BeginTextCommandDisplayHelp('qbHelpNotification')
        EndTextCommandDisplayHelp(0, false, true, duration)
    elseif Bridge.Framework == 'qbox' then
        AddTextEntry('qbxHelpNotification', message)
        BeginTextCommandDisplayHelp('qbxHelpNotification')
        EndTextCommandDisplayHelp(0, false, true, duration)
    elseif Bridge.Framework == 'standalone' then
        BeginTextCommandDisplayHelp('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandDisplayHelp(0, false, true, duration)
    end
end

-- Show text UI
function Bridge.UI.ShowTextUI(message, type)
    EnsureFrameworkReady()
    type = type or 'info'

    if Bridge.Framework == 'esx' then
        Bridge.FrameworkObject.TextUI(message, type)
    elseif Bridge.Framework == 'qbcore' then
        exports['qb-core']:DrawText(message, type)
    elseif Bridge.Framework == 'qbox' then
        exports['qb-core']:DrawText(message, type)
    elseif Bridge.Framework == 'standalone' then
        -- Fallback: Use help notification
        Bridge.UI.ShowHelpNotification(message)
    end
end

-- Hide text UI
function Bridge.UI.HideTextUI()
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        Bridge.FrameworkObject.HideUI()
    elseif Bridge.Framework == 'qbcore' then
        exports['qb-core']:HideText()
    elseif Bridge.Framework == 'qbox' then
        exports['qb-core']:HideText()
    elseif Bridge.Framework == 'standalone' then
        -- Nothing to do
    end
end

-- Progressbar
function Bridge.UI.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    EnsureFrameworkReady()
    duration = duration or 5000
    useWhileDead = useWhileDead or false
    canCancel = canCancel or true
    disableControls = disableControls or {}

    if Bridge.Framework == 'esx' then
        -- ESX uses esx_progressbar
        local finished = false
        exports['esx_progressbar']:Progressbar(label, duration, {
            FreezePlayer = true,
            onFinish = function()
                finished = true
                if onFinish then onFinish() end
            end,
            onCancel = function()
                if onCancel then onCancel() end
            end
        })
        return finished
    elseif Bridge.Framework == 'qbcore' then
        -- QBCore uses qb-progressbar
        exports['progressbar']:Progress({
            name = name,
            duration = duration,
            label = label,
            useWhileDead = useWhileDead,
            canCancel = canCancel,
            controlDisables = disableControls,
            animation = animation,
            prop = prop,
            propTwo = propTwo,
        }, function(cancelled)
            if not cancelled and onFinish then
                onFinish()
            elseif cancelled and onCancel then
                onCancel()
            end
        end)
    elseif Bridge.Framework == 'qbox' then
        -- QBX might use ox_lib
        local success = pcall(function()
            if exports.ox_lib then
                if lib.progressBar({
                    duration = duration,
                    label = label,
                    useWhileDead = useWhileDead,
                    canCancel = canCancel,
                    disable = disableControls,
                    anim = animation,
                    prop = prop,
                }) then
                    if onFinish then onFinish() end
                else
                    if onCancel then onCancel() end
                end
            end
        end)
        if not success then
            -- Fallback to qb-progressbar
            exports['progressbar']:Progress({
                name = name,
                duration = duration,
                label = label,
                useWhileDead = useWhileDead,
                canCancel = canCancel,
                controlDisables = disableControls,
                animation = animation,
                prop = prop,
                propTwo = propTwo,
            }, function(cancelled)
                if not cancelled and onFinish then
                    onFinish()
                elseif cancelled and onCancel then
                    onCancel()
                end
            end)
        end
    elseif Bridge.Framework == 'standalone' then
        -- Simple timer
        Citizen.Wait(duration)
        if onFinish then onFinish() end
    end
end

-- Input Dialog
function Bridge.UI.Input(header, rows, options)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        -- ESX might use esx_menu_default
        return nil -- Simplified, would need adjustment
    elseif Bridge.Framework == 'qbcore' then
        -- QBCore uses qb-input
        local dialog = exports['qb-input']:ShowInput({
            header = header,
            submitText = options and options.submitText or 'Submit',
            inputs = rows
        })
        return dialog
    elseif Bridge.Framework == 'qbox' then
        -- QBX uses ox_lib input
        local success, result = pcall(function()
            return lib.inputDialog(header, rows)
        end)
        return success and result or nil
    elseif Bridge.Framework == 'standalone' then
        return nil
    end
end

-- Context Menu
function Bridge.UI.ContextMenu(id, title, options)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        -- ESX uses esx_menu_default or esx_context
        local elements = {}
        for _, option in ipairs(options) do
            table.insert(elements, {
                label = option.label,
                value = option.value
            })
        end
        -- Simplified - would need adjustment
    elseif Bridge.Framework == 'qbcore' then
        -- QBCore uses qb-menu
        exports['qb-menu']:openMenu(options)
    elseif Bridge.Framework == 'qbox' then
        -- QBX uses ox_lib context
        local success = pcall(function()
            lib.registerContext({
                id = id,
                title = title,
                options = options
            })
            lib.showContext(id)
        end)
    elseif Bridge.Framework == 'standalone' then
        -- Not implemented
    end
end

-- Open Context Menu (show a registered context or directly open with options)
-- position: 'left', 'right', 'center' (default: 'right')
-- elements: array of menu options
-- onSelect: function(menu, element) called when element is selected
-- onClose: function(menu) called when menu is closed
function Bridge.UI.OpenContext(position, elements, onSelect, onClose)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        -- ESX: Use ESX.OpenContext (esx_context)
        -- Elements format: { { title = "Option", icon = "fas fa-check", description = "desc" }, ... }
        Bridge.FrameworkObject.OpenContext(position or 'right', elements, onSelect, onClose)
    elseif Bridge.Framework == 'qbcore' then
        -- QBCore: qb-menu format
        -- Convert elements to qb-menu format if needed
        local qbElements = {}
        for _, el in ipairs(elements) do
            table.insert(qbElements, {
                header = el.title or el.header,
                txt = el.description or el.txt or '',
                icon = el.icon,
                disabled = el.disabled,
                params = el.params or {
                    event = el.event,
                    args = el.args
                }
            })
        end
        exports['qb-menu']:openMenu(qbElements)
    elseif Bridge.Framework == 'qbox' then
        -- QBX: ox_lib context
        pcall(function()
            local oxOptions = {}
            for _, el in ipairs(elements) do
                table.insert(oxOptions, {
                    title = el.title or el.header,
                    description = el.description or el.txt,
                    icon = el.icon,
                    disabled = el.disabled,
                    onSelect = el.onSelect or (onSelect and function()
                        onSelect(nil, el)
                    end)
                })
            end
            lib.registerContext({
                id = 'bridge_context',
                title = elements[1] and elements[1].menuTitle or 'Menu',
                options = oxOptions
            })
            lib.showContext('bridge_context')
        end)
    elseif Bridge.Framework == 'standalone' then
        print('[Bridge] Standalone: OpenContext not implemented')
    end
end

-- Close Context Menu
function Bridge.UI.CloseContext()
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        Bridge.FrameworkObject.CloseContext()
    elseif Bridge.Framework == 'qbcore' then
        pcall(function() exports['qb-menu']:closeMenu() end)
    elseif Bridge.Framework == 'qbox' then
        pcall(function() lib.hideContext() end)
    end
end

-- Skillbar/Skillcheck
function Bridge.UI.Skillbar(duration, difficulty, onSuccess, onFailure)
    EnsureFrameworkReady()

    if Bridge.Framework == 'esx' then
        -- Depends on the skillbar script used
        print('[Bridge] ESX: Skillbar requires external script')
        if onSuccess then onSuccess() end
    elseif Bridge.Framework == 'qbcore' then
        -- ps-ui oder qb-skillbar
        local success = pcall(function()
            exports['ps-ui']:Circle(function(success)
                if success then
                    if onSuccess then onSuccess() end
                else
                    if onFailure then onFailure() end
                end
            end, difficulty or 2, duration or 10)
        end)
        if not success and onSuccess then onSuccess() end
    elseif Bridge.Framework == 'qbox' then
        -- ox_lib skillcheck
        local success = pcall(function()
            local result = lib.skillCheck(difficulty or {'easy', 'easy'}, {'w', 'a', 's', 'd'})
            if result then
                if onSuccess then onSuccess() end
            else
                if onFailure then onFailure() end
            end
        end)
        if not success and onSuccess then onSuccess() end
    elseif Bridge.Framework == 'standalone' then
        if onSuccess then onSuccess() end
    end
end
