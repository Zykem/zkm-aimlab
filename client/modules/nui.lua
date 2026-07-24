---@type AimlabNui
local Nui = {}

local currentSurface = 'none' ---@type NuiSurface
local mouseFocus     = false

---@param surface NuiSurface
function Nui.setSurface(surface)
    currentSurface = surface
    SendNUIMessage({ action = 'setSurface', data = { surface = surface } })

    if surface == 'menu' then
        Nui.acquireFocus(true)
    elseif surface == 'hud' then
        Nui.acquireFocus(false)
    else
        Nui.releaseFocus()
    end
end

---@param withMouse boolean
function Nui.acquireFocus(withMouse)
    mouseFocus = withMouse and true or false
    SetNuiFocus(true, mouseFocus)
    SetNuiFocusKeepInput(not mouseFocus)
end

function Nui.releaseFocus()
    mouseFocus = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end

---@return NuiSurface
function Nui.getSurface() return currentSurface end

---@return boolean
function Nui.hasMouseFocus() return mouseFocus end

---@param action string
---@param payload any
function Nui.send(action, payload)
    SendNUIMessage({ action = action, data = payload })
end

return Nui