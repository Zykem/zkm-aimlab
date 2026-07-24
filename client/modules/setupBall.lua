---@param ballObj number
---@param ballHeading number
---@return boolean Success
local function setupBall(ballObj, ballHeading)
    lib.waitFor(function()
        return DoesEntityExist(ballObj) or nil
    end)

    SetEntityHeading(ballObj, ballHeading)
    FreezeEntityPosition(ballObj, true)
    SetEntityAsMissionEntity(ballObj, true, true)
    SetEntityInvincible(ballObj, false)
    SetEntityProofs(ballObj, false, false, false, false, false, false, false, false)
    ClearEntityLastDamageEntity(ballObj)

    return true
end

return setupBall