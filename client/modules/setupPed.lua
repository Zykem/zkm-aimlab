---@param ped number
---@param pedHeading number
---@return boolean Success
local function setupPed(ped, pedHeading)
    lib.waitFor(function()
        return DoesEntityExist(ped) or nil
    end)

    if pedHeading then
        SetEntityHeading(ped, pedHeading)
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdoll(ped, false)
    SetPedSuffersCriticalHits(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityProofs(ped, false, true, true, true, true, true, true, true)

    return true
end

return setupPed