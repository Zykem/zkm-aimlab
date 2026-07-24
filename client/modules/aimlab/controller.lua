local Config = lib.require 'config'
local Nui = lib.require 'client.modules.nui'
local Weather = lib.require 'client.modules.weather'

local MODE_NAMES <const> = {
    "combatrollEasy", "combatrollMedium", "balls", "sprint", "sprintCrouch", "tracking"
}

---@type table<string, AimlabMode>
local modes = (function()
    local MODES = {}
    for i = 1, #MODE_NAMES do
        local name = MODE_NAMES[i]
        MODES[name] = lib.require(('client.modules.aimlab.modes.%s'):format(name))
    end
    return MODES
end)()

---@type table<AimlabModeId, AimlabModeBinding>
local modeBindings = {
    ['combat-roll']    = { mode = 'combatrollEasy' },
    ['combat-roll-v2'] = { mode = 'combatrollMedium' },
    ['beachball']      = { mode = 'balls', opts = { drift = false } },
    ['beachball-v2']   = { mode = 'balls', opts = { drift = true } },
    ['sprint']         = { mode = 'sprint' },
    ['sprint-crouch']  = { mode = 'sprintCrouch' },
    ['tracking']       = { mode = 'tracking', opts = { wander = false } },
    ['tracking-v2']    = { mode = 'tracking', opts = { wander = true } },
}

local HEAD_BONES <const> = {
    [31086] = true
}

---@type AimlabController
local Aimlab = {}

local active = nil ---@type AimlabModeId?
local startedAt = 0
---@type AimlabScore
local score = { hits = 0, headshots = 0, misses = 0, streak = 0, bestStreak = 0 }
local cancelKeybind = nil

---@return boolean
function Aimlab.isActive() return active ~= nil end

local function resetScore()
    score.hits, score.headshots, score.misses, score.streak, score.bestStreak = 0, 0, 0, 0, 0
    score.progress = nil
end

local function pushHud()
    local hits  = score.hits
    local shots = hits + score.misses
    Nui.send('setHud', {
        hits         = hits,
        headshots    = score.headshots,
        headshotRate = hits > 0 and (score.headshots / hits) or 0.0,
        accuracy     = shots > 0 and (hits / shots) or 0.0,
        progress     = score.progress,
    })
end

---@param ped number
---@return boolean
function Aimlab.wasHeadshot(ped)
    if not DoesEntityExist(ped) then return false end
    local hit, bone = GetPedLastDamageBone(ped)
    return hit and HEAD_BONES[bone] ~= nil
end

---@param headshot? boolean
function Aimlab.hit(headshot)
    if not active then return end
    score.hits += 1
    score.streak += 1
    if score.streak > score.bestStreak then score.bestStreak = score.streak end
    if headshot == true then score.headshots += 1 end
    pushHud()
end

function Aimlab.miss()
    if not active then return end
    score.misses += 1
    score.streak = 0
    pushHud()
end

---@param value number
function Aimlab.setProgress(value)
    if not active then return end
    score.progress = value
    pushHud()
end

---@type AimlabSession
local session = {
    hit         = function(headshot) Aimlab.hit(headshot) end,
    miss        = function() Aimlab.miss() end,
    setProgress = function(value) Aimlab.setProgress(value) end,
    wasHeadshot = function(ped) return Aimlab.wasHeadshot(ped) end,
}

local function ensureCancelKeybind()
    if cancelKeybind then
        cancelKeybind:disable(false)
        return
    end
    cancelKeybind = lib.addKeybind({
        name = 'aimlab_cancel',
        description = 'Stop the aimlab session',
        defaultKey = 'X',
        onPressed = function() Aimlab.stop() end,
    })
end

local function teardown()
    if not active then return end
    local binding = modeBindings[active]
    local mode = binding and modes[binding.mode]
    if mode then mode.stopMode() end
    if cancelKeybind then cancelKeybind:disable(true) end
    Weather.restore()
    active = nil
end

---@param modeId AimlabModeId
---@return boolean started
function Aimlab.start(modeId)
    if active then return false end

    local binding = modeBindings[modeId]
    if not binding then
        lib.notify({ type = 'error', description = ('Unknown aimlab mode: %s'):format(tostring(modeId)) })
        return false
    end

    local mode = modes[binding.mode]
    if not mode then
        lib.notify({ type = 'error', description = ('Mode "%s" is not loaded.'):format(binding.mode) })
        return false
    end

    active = modeId
    resetScore()
    startedAt = GetGameTimer()

    Nui.send('sessionStart', { mode = modeId })
    Nui.setSurface('hud')
    ensureCancelKeybind()
    pushHud()

    if Config.Weather and Config.Weather.enabled then
        Weather.apply({ time = Config.Weather.time, weather = Config.Weather.weather })
    end

    mode.startMode(session, binding.opts)
    TriggerServerEvent("zkm-aimlab:enterredSession", binding.mode)
    return true
end

function Aimlab.stop()
    if not active then return end

    ---@type AimlabSessionResult
    local result = {
        mode         = active,
        hits         = score.hits,
        headshots    = score.headshots,
        headshotRate = score.hits > 0 and (score.headshots / score.hits) or 0.0,
        bestStreak   = score.bestStreak,
        durationMs   = GetGameTimer() - startedAt,
    }

    TriggerServerEvent('zkm-aimlab:saveSession', {
        mode      = result.mode,
        hits      = result.hits,
        headshots = result.headshots,
    })

    Nui.send('sessionEnd', result)
    teardown()
    Nui.setSurface('menu')
end

function Aimlab.abort()
    teardown()
end

RegisterNUICallback('startSession', function(data, cb)
    cb({ joined = Aimlab.start(data and data.mode) })
end)

return Aimlab