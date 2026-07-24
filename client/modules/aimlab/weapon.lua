local Config = lib.require 'config'

---@return InventoryResource
local function resolveInventory()
    if GetResourceState('ox_inventory') == 'started' then
        return 'ox_inventory'
    end
    return 'none'
end

local WEAPON <const> = `WEAPON_PISTOL_MK2`
local INVENTORY <const> = resolveInventory()

---@type AimlabWeapon
local Weapon = {}

function Weapon.enable()
    if Config.ownWeapon then return end
    local ped = cache.ped

    if INVENTORY == 'ox_inventory' then
        exports.ox_inventory:weaponWheel(true)
    end

    GiveWeaponToPed(ped, WEAPON, 250, false, true)
    SetCurrentPedWeapon(ped, WEAPON, true)
    SetPedInfiniteAmmoClip(ped, true)
end

function Weapon.disable()
    if Config.ownWeapon then return end
    local ped = cache.ped

    SetPedInfiniteAmmoClip(ped, false)
    RemoveWeaponFromPed(ped, WEAPON)
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

    if INVENTORY == 'ox_inventory' then
        exports.ox_inventory:weaponWheel(false)
    end
end

return Weapon