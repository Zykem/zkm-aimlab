local ANIM_DICT <const> = 'move_strafe@roll'
local ANIM_NAMES <const> = {
    'combatroll_bwd_p1_135', 'combatroll_bwd_p1_-135', 'combatroll_bwd_p1_180', 'combatroll_bwd_p1_-45',
    'combatroll_bwd_p1_-90',
    'combatroll_fwd_p1_00', 'combatroll_fwd_p1_135', 'combatroll_fwd_p1_45', 'combatroll_fwd_p1_-45',
    'combatroll_fwd_p1_90',
}

---@param ped number
---@return number durationSeconds
local function playCombatRoll(ped)
    lib.requestAnimDict(ANIM_DICT)

    local animName = ANIM_NAMES[math.random(#ANIM_NAMES)]
    TaskPlayAnim(ped, ANIM_DICT, animName, 8.0, -8.0, -1, 0, 0, false, false, false)
    RemoveAnimDict(ANIM_DICT)

    return GetAnimDuration(ANIM_DICT, animName)
end

return playCombatRoll