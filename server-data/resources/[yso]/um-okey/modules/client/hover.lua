local hover = {}
local lastSelectedSlotId = 0
local outlineEntity = 0


local function getPiece(slotId)
    local piece = TablePoints[CurrentTable.tableIndex].boards[CurrentTable.boardIndex].pieces[slotId]
    return piece
end

function hover:doReset()
    SetEntityDrawOutline(outlineEntity, false)
    lastSelectedSlotId = 0
    outlineEntity = 0
end

function hover:doSelect(slotId)
    local entity = getPiece(slotId)

    if (not entity or entity == 0) and (not lastSelectedSlotId or lastSelectedSlotId == 0) then
        hover:doReset()
        return
    end

    if not slotId or slotId == 0 then
        hover:doReset()
        return
    end

    if lastSelectedSlotId and lastSelectedSlotId ~= 0 then
        if outlineEntity and outlineEntity ~= 0 then
            SetEntityDrawOutline(outlineEntity, false)
            outlineEntity = 0
        end

        lib.callback.await('um-okey:server:switchPieces', false, slotId, lastSelectedSlotId)
        lastSelectedSlotId = 0

        hover:doReset()
    else
        entity = getPiece(slotId)
        SetEntityDrawOutline(entity, true)
        SetEntityDrawOutlineColor(185, 0, 96, 0.39)
        SetEntityDrawOutlineShader(0)
        outlineEntity = entity
        lastSelectedSlotId = slotId
    end
end

return hover
