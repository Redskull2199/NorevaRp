PulseV = PulseV or {}
local Database = {}
PulseV.Database = Database
local permissionSchema = [[CREATE TABLE IF NOT EXISTS pulsev_blip_permissions (
    license VARCHAR(48) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    allowed TINYINT(1) NOT NULL DEFAULT 1,
    updated_at DATETIME NOT NULL,
    PRIMARY KEY (license)
) ENGINE=InnoDB]]

local columns = 'name, note, sprite, color, scale, alpha, display, short_range, x, y, z, rotation, category, map_category, enabled'
-- DATETIME stores the service's UTC text without session timezone conversion.
-- Explicit formatting prevents oxmysql date/epoch coercion before validation.
local projection = 'id, '..columns..', version, created_by, updated_by, '
    .."DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') AS created_at, "
    .."DATE_FORMAT(updated_at, '%Y-%m-%d %H:%i:%s') AS updated_at"
local selectAll = 'SELECT '..projection..' FROM pulsev_blips ORDER BY id'
local selectOne = 'SELECT '..projection..' FROM pulsev_blips WHERE id = ?'
local insert = 'INSERT INTO pulsev_blips ('..columns..', version, created_by, updated_by, created_at, updated_at) '
    ..'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?)'
local update = 'UPDATE pulsev_blips SET name = ?, note = ?, sprite = ?, color = ?, scale = ?, alpha = ?, '
    ..'display = ?, short_range = ?, x = ?, y = ?, z = ?, rotation = ?, category = ?, map_category = ?, enabled = ?, '
    ..'updated_by = ?, updated_at = ?, version = version + 1 WHERE id = ? AND version = ?'
local toggle = 'UPDATE pulsev_blips SET enabled = ?, updated_by = ?, updated_at = ?, '
    ..'version = version + 1 WHERE id = ? AND version = ?'
local delete = 'DELETE FROM pulsev_blips WHERE id = ? AND version = ?'
local function draftParams(draft)
    return {draft.name,draft.note,draft.sprite,draft.color,draft.scale,draft.alpha,draft.display,
        draft.short_range and 1 or 0,draft.x,draft.y,draft.z,draft.rotation,draft.category,
        draft.map_category,draft.enabled and 1 or 0}
end
function Database.new(mysql, config, catalog)
    local db = {}
    local function normalize(row)
        local record, issues = PulseV.Validation.fromRow(row,config,catalog.spritesById)
        if record then return record end
        local fields = {}
        for key in pairs(issues) do fields[#fields+1]=key end
        table.sort(fields)
        local id=tonumber(row.id)
        local safeId=id and id%1==0 and id>0 and id<=4294967295 and tostring(id) or '?'
        print(('[pulsev-blipcreator] Invalid SQL row id=%s fields=%s'):format(safeId,table.concat(fields,',',1,math.min(#fields,8))))
    end
    function db:loadAll()
        -- No automatic migrations or retries: missing table/column errors reach startup.
        local rows = mysql.query.await(selectAll,{})
        local records = {}
        for _, row in ipairs(rows) do
            local record=normalize(row)
            if record then records[#records+1]=record end
        end
        return records
    end
    function db:loadPermissions()
        -- Only the new ACL table is bootstrapped; existing blips are never rewritten.
        mysql.query.await(permissionSchema,{})
        return mysql.query.await('SELECT license, allowed FROM pulsev_blip_permissions',{})
    end
    function db:setPermission(license,allowed)
        return mysql.update.await('INSERT INTO pulsev_blip_permissions (license, allowed, updated_at) VALUES (?, ?, ?) '
            ..'ON DUPLICATE KEY UPDATE allowed = VALUES(allowed), updated_at = VALUES(updated_at)',
            {license,allowed and 1 or 0,os.date('!%Y-%m-%d %H:%M:%S')})
    end
    function db:get(id)
        local rows=mysql.query.await(selectOne,{id})
        if rows[1] then return normalize(rows[1]) end
    end
    function db:insert(draft,actor,stampUtc)
        local params=draftParams(draft)
        params[16],params[17],params[18],params[19]=actor,actor,stampUtc,stampUtc
        return mysql.insert.await(insert,params)
    end
    function db:update(id,version,draft,actor,stampUtc)
        local params=draftParams(draft)
        params[16],params[17],params[18],params[19]=actor,stampUtc,id,version
        return mysql.update.await(update,params)
    end
    function db:setEnabled(id,version,enabled,actor,stampUtc)
        return mysql.update.await(toggle,{enabled and 1 or 0,actor,stampUtc,id,version})
    end
    function db:delete(id,version)
        return mysql.update.await(delete,{id,version})
    end
    return db
end
