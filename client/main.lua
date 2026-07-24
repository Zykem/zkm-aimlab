local Config = lib.require 'config'
local Nui = lib.require 'client.modules.nui'
local Aimlab = lib.require 'client.modules.aimlab.controller'

local function closeMenu()
    if Nui.getSurface() == 'none' then return end
    Nui.setSurface('none')
end

local function openMenu()
    if Nui.getSurface() == 'menu' then return end
    Nui.setSurface('menu')
end

RegisterNUICallback('uiReady', function(_, cb)
    cb({})
end)

RegisterNUICallback('closeUi', function(_, cb)
    closeMenu()
    cb({})
end)

RegisterNUICallback('getStats', function(_, cb)
    cb(lib.callback.await('aimlab:getStats', false))
end)

RegisterNUICallback('getConfig', function(_, cb)
    cb(Config.UI)
end)

RegisterCommand(Config.openCommandName, function()
    openMenu()
end, false)

RegisterKeyMapping(
    Config.openCommandName,
    'Open the Aimlab menu',
    'keyboard',
    Config.openCommandKey
)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    Aimlab.abort()
    Nui.releaseFocus()
end)