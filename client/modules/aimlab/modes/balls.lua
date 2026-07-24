local Config = lib.require 'config'
local Weapon = lib.require 'client.modules.aimlab.weapon'
local setupBall = lib.require 'client.modules.setupBall'

local Mode = {}

local started = false
local currentIndex = 1
local initialPosition = nil ---@type vector3?
local currentBall = nil ---@type number?

---@param session AimlabSession
---@param opts AimlabModeOptions
local function spawnNextBall(session, opts)
    local cfg = Config.Aimlab.modes.balls
    local ballPositions = cfg.positions

    local pos
    if cfg.randomizeOrder then
        pos = ballPositions[math.random(#ballPositions)]
    else
        if currentIndex > #ballPositions then currentIndex = 1 end
        pos = ballPositions[currentIndex]
        currentIndex += 1
    end

    local zOffset = 0.0
    if cfg.minZ and cfg.maxZ then
        zOffset = cfg.minZ + math.random() * (cfg.maxZ - cfg.minZ)
    end

    local baseZ = pos.z + zOffset

    local model = joaat(cfg.model)
    lib.requestModel(model)

    local ball = CreateObject(model, pos.x, pos.y, baseZ, false, false, false)
    setupBall(ball, pos.w)
    SetModelAsNoLongerNeeded(model)

    currentBall = ball

    local startPos = Config.Aimlab.startPosition
    local dirX, dirY = 0.0, 0.0
    local dx, dy = pos.x - startPos.x, pos.y - startPos.y
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0.0 then
        dirX = -dy / len
        dirY = dx / len
    end

    CreateThread(function()
        local duration = cfg.duration or 3.0
        local startTime = GetGameTimer()
        local deadline = startTime + math.floor(duration * 1000)
        local hit = false

        while started and GetGameTimer() < deadline do
            if DoesEntityExist(ball) and HasEntityBeenDamagedByEntity(ball, cache.ped, true) then
                hit = true
                break
            end

            if opts.drift and DoesEntityExist(ball) then
                local t = (GetGameTimer() - startTime) / 1000.0
                local z = baseZ + math.sin(t * (cfg.driftSpeed or 1.6) * math.pi * 2) * (cfg.driftHeight or 0.6)

                local x, y = pos.x, pos.y
                local width = cfg.driftWidth or 0.0
                if width ~= 0.0 then
                    local side = math.sin(t * (cfg.driftSideSpeed or 0.4) * math.pi * 2) * width
                    x = pos.x + dirX * side
                    y = pos.y + dirY * side
                end

                SetEntityCoordsNoOffset(ball, x, y, z, false, false, false)
            end

            Wait(0)
        end

        if hit then
            session.hit(false)
        else
            session.miss()
        end

        if DoesEntityExist(ball) then DeleteEntity(ball) end
        if currentBall == ball then currentBall = nil end

        if not started then return end
        spawnNextBall(session, opts)
    end)
end

---@param session AimlabSession
---@param opts? AimlabModeOptions
function Mode.startMode(session, opts)
    opts = opts or {}
    Weapon.enable()

    started = true
    currentIndex = 1

    local ped = cache.ped
    initialPosition = GetEntityCoords(ped)
    local startPosition = Config.Aimlab.startPosition
    SetEntityCoords(ped, startPosition.x, startPosition.y, startPosition.z, true, false, false, false)
    SetEntityHeading(ped, startPosition.w)
    Wait(3100)
    spawnNextBall(session, opts)
end

function Mode.stopMode()
    Weapon.disable()

    started = false

    if initialPosition then
        SetEntityCoords(cache.ped, initialPosition.x, initialPosition.y, initialPosition.z, true, false, false, false)
    end

    if currentBall and DoesEntityExist(currentBall) then DeleteEntity(currentBall) end
    currentBall = nil
    currentIndex = 1
end

return Mode