local bridgeTarget = {}

function bridgeTarget.addTarget(entity, index)
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:addLocalEntity(entity, {
            label = locale('reset_table'),
            icon = 'fas fa-table',
            distance = 1.5,
            onSelect = function()
                lib.callback.await('um-okey:server:resetTableTarget', false, index)
            end,
        })
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetEntity(entity, {
            options = {
                {
                    label = locale('reset_table'),
                    icon = 'fas fa-table',
                    action = function()
                        lib.callback.await('um-okey:server:resetTableTarget', false, index)
                    end,
                },
            },
        })
    else
        warn('No target resource found to add the entity.')
    end
end

function bridgeTarget.removeTarget(entity)
    if GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeLocalEntity(entity)
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:RemoveTargetEntity(entity, locale('reset_table'))
    else
        warn('No target resource found to remove the entity.')
    end
end

return bridgeTarget
