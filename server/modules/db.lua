---@type AimlabDb
local Db = {}

local SQL_FILE_PATH <const> = "sql/schema.sql"

function Db.ensureSchema()
    local sql = LoadResourceFile(cache.resource, SQL_FILE_PATH)
    if not sql or sql == '' then
        error(('missing or empty SQL file: %s'):format(SQL_FILE_PATH))
        return
    end
    for statement in sql:gmatch('([^;]+)') do
        local trimmed = statement:gsub('^%s+', ''):gsub('%s+$', '')
        if trimmed ~= '' then
            MySQL.query.await(trimmed)
        end
    end
end

---@param identifier string
---@return AimlabLifetimeRow
function Db.getLifetime(identifier)
    local row = MySQL.single.await(
        'SELECT total_sessions, total_hits, total_headshots, headshot_rate FROM zykem_aimlab_stats WHERE identifier = ?',
        { identifier }
    )

    return {
        total_sessions  = row and tonumber(row.total_sessions) or 0,
        total_hits      = row and tonumber(row.total_hits) or 0,
        total_headshots = row and tonumber(row.total_headshots) or 0,
        headshot_rate   = row and tonumber(row.headshot_rate) or 0.0,
    }
end

local RECORD_SESSION_SQL <const> = [[
    INSERT INTO zykem_aimlab_stats
        (identifier, total_sessions, total_hits, total_headshots, headshot_rate)
    VALUES (?, 1, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
        total_sessions  = total_sessions + 1,
        total_hits      = total_hits + VALUES(total_hits),
        total_headshots = total_headshots + VALUES(total_headshots),
        headshot_rate   = COALESCE(total_headshots / NULLIF(total_hits, 0), 0)
]]

---@param identifier string
---@param hits integer
---@param headshots integer
function Db.recordSession(identifier, hits, headshots)
    if not identifier or identifier == '' then return end

    local rate = hits > 0 and (headshots / hits) or 0.0
    MySQL.update.await(RECORD_SESSION_SQL, { identifier, hits, headshots, rate })
end

return Db