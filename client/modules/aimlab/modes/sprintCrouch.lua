local Config = lib.require 'config'
local Weapon = lib.require 'client.modules.aimlab.weapon'
local setupPed = lib.require 'client.modules.setupPed'

local Mode = {}

local started = false
local currentIndex = 1
local initialPosition = nil ---@type vector3?

---@param ped number
local function crouchPed(ped)
    lib.requestAnimSet('move_ped_crouched')
    SetPedMovementClipset(ped, 'move_ped_crouched', 0.20)
    Wait(150)
    ResetPedMovementClipset(ped, 0.2)
    RemoveAnimSet('move_ped_crouched')
end

---@param session AimlabSession
local function createSprintingPed(session)
    local sprintingPaths = Config.Aimlab.modes.sprint.peds

    currentIndex += 1
    if currentIndex > #sprintingPaths then currentIndex = 1 end

    local currentPath = sprintingPaths[currentIndex]
    local startingPos, destination = currentPath[1], currentPath[2]

    lib.requestModel(`mp_m_freemode_01`)
    local ped = CreatePed(4, `mp_m_freemode_01`, startingPos.x, startingPos.y, startingPos.z - 0.95, startingPos.w, false, true)
    setupPed(ped)
    
    TaskGoStraightToCoord(ped, destination.x, destination.y, destination.z, 10.0, -1, destination.w, 3.0)

    CreateThread(function()
        while started and #(GetEntityCoords(ped) - destination.xyz) > 2.0 and not IsEntityDead(ped) do
            if math.random() > 0.3 then
                crouchPed(ped)
            end
            Wait(1000)
        end

        if IsEntityDead(ped) then
            session.hit(session.wasHeadshot(ped))
        else
            session.miss()
        end

        DeletePed(ped)
    end)
end

---@param session AimlabSession
function Mode.startMode(session)
    Weapon.enable()

    currentIndex = 1
    started = true

    local ped = cache.ped
    initialPosition = GetEntityCoords(ped)
    local startPosition = Config.Aimlab.startSprintPosition
    SetEntityCoords(ped, startPosition.x, startPosition.y, startPosition.z, true, false, false, false)
    SetEntityHeading(ped, startPosition.w)
    Wait(100)

    CreateThread(function()
        while started do
            local playerPed = cache.ped
            if #(GetEntityCoords(playerPed) - startPosition.xyz) > 10.0 then
                SetEntityCoords(playerPed, startPosition.x, startPosition.y, startPosition.z, true, false, false, false)
                SetEntityHeading(playerPed, startPosition.w)
            end
            createSprintingPed(session)
            Wait(1300)
        end
    end)
end

function Mode.stopMode()
    Weapon.disable()

    started = false
    if initialPosition then
        SetEntityCoords(cache.ped, initialPosition.x, initialPosition.y, initialPosition.z, true, false, false, false)
    end
end

return Mode