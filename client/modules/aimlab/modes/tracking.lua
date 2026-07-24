local Config = lib.require 'config'
local Weapon = lib.require 'client.modules.aimlab.weapon'

local Mode = {}

local started = false
local initialPosition = nil ---@type vector3?
local target = nil ---@type number?

---@param heading number degrees
---@return number forwardX, number forwardY
local function headingToForward(heading)
    local radians = math.rad(heading)
    return -math.sin(radians), math.cos(radians)
end

---@param session AimlabSession
---@param opts? AimlabModeOptions
function Mode.startMode(session, opts)
    local wander = opts and opts.wander
    Weapon.enable()

    started = true
    local ped = cache.ped
    initialPosition = GetEntityCoords(ped)

    local startPos = Config.Aimlab.startPosition
    SetEntityCoords(ped, startPos.x, startPos.y, startPos.z, true, false, false, false)
    SetEntityHeading(ped, startPos.w)
    Wait(100)

    local cfg = Config.Aimlab.modes.tracking

    local forwardX, forwardY = headingToForward(startPos.w)
    local rightX, rightY = forwardY, -forwardX
    local coordX = startPos.x + forwardX * cfg.distance
    local coordY = startPos.y + forwardY * cfg.distance
    local coordZ = startPos.z + cfg.height

    local model = joaat(cfg.model)
    lib.requestModel(model)
    target = CreateObject(model, coordX, coordY, coordZ, false, false, false)
    SetEntityCollision(target, false, false)
    FreezeEntityPosition(target, true)
    SetEntityInvincible(target, true)
    SetEntityAsMissionEntity(target, true, true)
    SetModelAsNoLongerNeeded(model)

    local progress = 0.0
    local fillRate = 1.0 / cfg.fillSeconds
    local startTime = GetGameTimer()
    local lastFrameTime = startTime
    local lastHud = 0
    local outlineOn = false

    Citizen.CreateThread(function()
        while started do
            local now = GetGameTimer()
            local deltaTime = (now - lastFrameTime) / 1000.0
            lastFrameTime = now
            local elapsedTime = (now - startTime) / 1000.0
            local speed = cfg.speed

            local sideOffset, verticalOffset
            if wander then
                sideOffset = (math.sin(elapsedTime * 0.9 * speed) + 0.5 * 
                            math.sin(elapsedTime * 1.7 * speed + 1.3)) / 1.5 * cfg.moveWidth
                verticalOffset = (math.sin(elapsedTime * 1.3 * speed + 0.7) + 0.5 * 
                                math.sin(elapsedTime * 2.1 * speed)) / 1.5 * cfg.moveHeight
            else
                sideOffset = math.sin(elapsedTime * speed) * cfg.moveWidth
                verticalOffset = 0.0
            end
            local targetX = coordX + rightX * sideOffset
            local targetY = coordY + rightY * sideOffset
            local targetZ = coordZ + verticalOffset

            if DoesEntityExist(target) then
                SetEntityCoordsNoOffset(target, targetX, targetY, targetZ, false, false, false)
            end

            local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(targetX, targetY, targetZ)
            local onTarget = false
            if onScreen then
                local screenDeltaX = (screenX - 0.5) * GetAspectRatio(false)
                local screenDeltaY = screenY - 0.5
                onTarget = math.sqrt(screenDeltaX * screenDeltaX + screenDeltaY * screenDeltaY) <= cfg.tolerance
            end

            if onTarget then
                progress = math.min(1.0, progress + fillRate * deltaTime)

                if not outlineOn then
                    SetEntityDrawOutline(target, true)
                    SetEntityDrawOutlineColor(0, 255, 0, 255)
                    outlineOn = true
                end
            else
                if outlineOn then
                    SetEntityDrawOutline(target, false)
                    outlineOn = false
                end
                progress = math.max(0.0, progress - fillRate * cfg.decayMultiplier * deltaTime)
            end

            if progress >= 1.0 then
                session.hit(false)
                progress = 0.0
                session.setProgress(0.0)
                lastHud = now
            elseif now - lastHud >= 100 then
                lastHud = now
                session.setProgress(progress)
            end

            Citizen.Wait(0)
        end
    end)
end

function Mode.stopMode()
    Weapon.disable()

    started = false

    if target and DoesEntityExist(target) then DeleteEntity(target) end
    target = nil

    if initialPosition then
        SetEntityCoords(cache.ped, initialPosition.x, initialPosition.y, initialPosition.z, true, false, false, false)
    end
end

return Mode