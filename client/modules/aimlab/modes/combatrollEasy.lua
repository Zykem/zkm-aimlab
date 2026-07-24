local Config = lib.require 'config'
local Weapon = lib.require 'client.modules.aimlab.weapon'
local playCombatRoll = lib.require 'client.modules.aimlab.combatroll'
local setupPed = lib.require 'client.modules.setupPed'

local Mode = {}

local started = false
local currentIndex = 1
local initialPosition = nil ---@type vector3?

---@param session AimlabSession
local function spawnNextPed(session)
    local pedPositions = Config.Aimlab.modes.combatrollEasy.peds

    if currentIndex > #pedPositions then currentIndex = 1 end

    local pos = pedPositions[currentIndex]
    currentIndex += 1

    lib.requestModel(`mp_m_freemode_01`)

    local ped = CreatePed(4, `mp_m_freemode_01`, pos.x, pos.y, pos.z - 0.95, pos.w, false, true)
    setupPed(ped, pos.w)

    Wait(600)
    local duration = playCombatRoll(ped)

    CreateThread(function()
        Wait(math.floor(duration * 1000))

        if DoesEntityExist(ped) then
            if IsEntityDead(ped) then
                session.hit(session.wasHeadshot(ped))
            else
                session.miss()
            end
            DeleteEntity(ped)
        end

        if not started then return end
        spawnNextPed(session)
    end)
end

---@param session AimlabSession
function Mode.startMode(session)
    Weapon.enable()

    started = true
    currentIndex = 1

    local ped = cache.ped
    initialPosition = GetEntityCoords(ped)
    local startPosition = Config.Aimlab.startPosition
    SetEntityCoords(ped, startPosition.x, startPosition.y, startPosition.z, true, false, false, false)
    SetEntityHeading(ped, startPosition.w)
    Wait(3100)
    spawnNextPed(session)
end

function Mode.stopMode()
    Weapon.disable()

    if initialPosition then
        SetEntityCoords(cache.ped, initialPosition.x, initialPosition.y, initialPosition.z, true, false, false, false)
    end

    started = false
    currentIndex = 1
end

return Mode