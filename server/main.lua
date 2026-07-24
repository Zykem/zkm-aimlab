local Config = lib.require 'config'
local Db = lib.require 'server.modules.db'
local Stats = lib.require 'server.modules.statsCache'

Citizen.CreateThread(function()
    Db.ensureSchema()
end)

---@type table<integer, integer>
local lastSaveAt = {}

RegisterNetEvent("zkm-aimlab:enterredSession", function(mode)
    local src = source
    if not mode or not Config.Aimlab.modeList[mode] then return end

    SetPlayerRoutingBucket(src, src --[[@as integer]])
end)

RegisterNetEvent('zkm-aimlab:saveSession', function(payload)
    local src = source
    if type(payload) ~= 'table' then return end

    local mode = payload.mode
    if type(mode) ~= 'string' or not Config.Aimlab.modeList[mode] then return error(("Invalid mode: %s"):format(tostring(mode))) end

    -- setting player routing bucket to 0 here just in case something goes wrong and wrong data gets sent
    SetPlayerRoutingBucket(src, 0)

    local hits = math.floor(tonumber(payload.hits) or -1)
    local headshots = math.floor(tonumber(payload.headshots) or -1)
    if hits < 0 or headshots < 0 or headshots > hits or hits > Config.Aimlab.session.maxHits then
        return
    end

    local now = GetGameTimer()
    if lastSaveAt[src] and (now - lastSaveAt[src]) < Config.Aimlab.session.saveCooldownMs then
        return
    end
    lastSaveAt[src] = now

    local identifier = GetPlayerIdentifierByType(src --[[@as string]], Config.Aimlab.session.identifierType)
    if not identifier then return end

    Db.recordSession(identifier, hits, headshots)
end)

lib.callback.register('zkm-aimlab:getStats', function(source)
    local identifier = GetPlayerIdentifierByType(source --[[@as string]], Config.Aimlab.session.identifierType)
    local stats = Stats.getStats(identifier)

    if not stats then
        stats = Db.getLifetime(identifier or '')
        Stats.insertStats(identifier, stats)
    end
    
    return {
        totalSessions  = stats.total_sessions,
        totalHits      = stats.total_hits,
        totalHeadshots = stats.total_headshots,
        headshotRate   = stats.headshot_rate,
    }
end)

AddEventHandler('playerDropped', function()
    lastSaveAt[source] = nil
end)