local Config = lib.require 'config'
local Db = lib.require 'server.modules.db'

Citizen.CreateThread(function()
    Db.ensureSchema()
end)

---@type table<integer, integer>
local lastSaveAt = {}

RegisterNetEvent('zykem_aimlab:server:saveSession', function(payload)
    local src = source
    if type(payload) ~= 'table' then return end

    local mode = payload.mode
    if type(mode) ~= 'string' or not Config.Aimlab.modeList[mode] then return error(("Invalid mode: %s"):format(tostring(mode))) end

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

lib.callback.register('aimlab:getStats', function(source)
    local identifier = GetPlayerIdentifierByType(source --[[@as string]], Config.Aimlab.session.identifierType)
    local lifetimeStats = Db.getLifetime(identifier or '')
    return {
        totalSessions  = lifetimeStats.total_sessions,
        totalHits      = lifetimeStats.total_hits,
        totalHeadshots = lifetimeStats.total_headshots,
        headshotRate   = lifetimeStats.headshot_rate,
    }
end)

AddEventHandler('playerDropped', function()
    lastSaveAt[source] = nil
end)