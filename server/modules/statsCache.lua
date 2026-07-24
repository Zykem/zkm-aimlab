local Stats = {}

Stats._cache = {}

local CACHE_TTL <const> = 10

---@param identifier number
---@return AimlabLifetimeRow?
function Stats.getStats(identifier)
    local PlayerCache = Stats._cache[identifier]

    if PlayerCache and (os.time() - PlayerCache.lastUpdate) > CACHE_TTL then
        return
    end

    return Stats._cache[identifier]
end

---@param identifier string
---@param stats AimlabLifetimeRow
function Stats.insertStats(identifier, stats)
    if not stats or not identifier then return end
    Stats._cache[identifier] = stats
    Stats._cache[identifier].lastUpdate = os.time()
end

return Stats