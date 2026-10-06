local nui = {}

local function focusToggle(bool)
    SetNuiFocus(bool, bool)
end

function nui:toggle(stateString, noNuiFocus)
    local state = stateString == 'visible'
    if not noNuiFocus then focusToggle(state) end
    SendNUIMessage({ action = 'toggle', state = stateString })
    DebugOky('^3[NUI] toggleVisible - ' .. tostring(state))
end

function nui:sendMessage(data)
    SendNUIMessage(data)
    DebugOky('^3[NUI] sendMessage - ' .. data.action)
end

function nui:updateTurn(isMyTurn, currentTurn, boardIndex, mustThrow, playerName)
    self:sendMessage({
        action = 'updateTurnUI',
        isMyTurn = isMyTurn,
        currentTurn = currentTurn,
        boardIndex = boardIndex,
        mustThrow = mustThrow,
        playerName = playerName
    })
end

function nui:setInteractionsEnabled(enabled)
    self:sendMessage({
        action = 'disableInteractions',
        enabled = enabled
    })
end

function nui:showStartMenu(bool)
    if bool then focusToggle(bool) end
    self:sendMessage({
        action = 'showStartMenu',
        status = bool
    })
end

return nui
