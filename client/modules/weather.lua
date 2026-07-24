---@type AimlabWeather
local Weather = {}

local HAS_CD_EASYTIME <const> = GetResourceState('cd_easytime') == 'started'

local applied      = false
local freezeActive = false
local frozenHours  = nil ---@type integer?
local frozenMins   = nil ---@type integer?

---@param time? AimlabTimeConfig
---@param weather? string
local function applyNative(time, weather)
    if time and time.hours then
        frozenHours = time.hours
        frozenMins  = time.mins or 0
        NetworkOverrideClockTime(frozenHours, frozenMins, 0)
        if not freezeActive then
            freezeActive = true
            CreateThread(function()
                while freezeActive do
                    NetworkOverrideClockTime(frozenHours or 12, frozenMins or 0, 0)
                    Wait(0)
                end
            end)
        end
    end

    if weather then
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(weather)
        SetWeatherTypeNowPersist(weather)
        SetWeatherTypeNow(weather)
        if weather == 'RAIN' or weather == 'THUNDER' then
            SetRainLevel(1.0)
        end
    end
end

local function restoreNative()
    freezeActive = false
    frozenHours, frozenMins = nil, nil
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetRainLevel(-1.0)
end

---@param time? AimlabTimeConfig
---@param weather? string
local function applyCdEasytime(time, weather)
    local payload = {}
    if weather then
        payload.weather        = weather
        payload.instantweather = true
    end
    if time and time.hours then
        payload.hours       = time.hours
        payload.mins        = time.mins or 0
        payload.instanttime = true
        payload.freeze      = true
    end
    TriggerEvent('cd_easytime:ForceUpdate', payload)
end

local function restoreCdEasytime()
    TriggerEvent('cd_easytime:ForceUpdate', { freeze = false })
    Wait(50)
    TriggerServerEvent('cd_easytime:SyncMe_basics', { weather = true, time = true })
end

---@param opts { time?: AimlabTimeConfig, weather?: string }
function Weather.apply(opts)
    if applied then Weather.restore() end
    opts = opts or {}
    if not opts.time and not opts.weather then return end

    applied = true
    if HAS_CD_EASYTIME then
        applyCdEasytime(opts.time, opts.weather)
    else
        applyNative(opts.time, opts.weather)
    end
end

function Weather.restore()
    if not applied then return end
    applied = false
    if HAS_CD_EASYTIME then
        restoreCdEasytime()
    else
        restoreNative()
    end
end

---@return WeatherBackend
function Weather.backend()
    return HAS_CD_EASYTIME and 'cd_easytime' or 'native'
end

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if applied then Weather.restore() end
end)

return Weather