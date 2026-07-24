---@alias AimlabModeId
---| 'combat-roll'
---| 'combat-roll-v2'
---| 'beachball'
---| 'beachball-v2'
---| 'sprint'
---| 'sprint-crouch'
---| 'tracking'
---| 'tracking-v2'

---@alias HudPosition 'top-left'|'top-right'|'center-left'|'center-right'|'bottom-left'|'bottom-right'

---@alias NuiSurface 'none'|'menu'|'hud'

---@alias WeatherBackend 'cd_easytime'|'native'

---@alias InventoryResource 'ox_inventory'|'none'

---@class AimlabOpenMenuConfig
---@field enabled boolean register the command/keybind that opens the menu
---@field commandName string command name used for both the menu and the keybind
---@field key string default key the menu is bound to

---@class AimlabUIConfig
---@field hudPosition HudPosition corner/edge the in-session HUD anchors to
---@field primaryColor string hex accent used across the UI (buttons, key stats, HUD)

---@class AimlabTimeConfig
---@field hours integer 24h clock hour locked for the session
---@field mins? integer minute locked for the session (defaults to 0)

---@alias weather 
---| "EXTRASUNNY" 
---| "CLEAR" 
---| "CLOUDS" 
---| "OVERCAST" 
---| "SMOG" 
---| "FOGGY" 
---| "RAIN" 
---| "THUNDER" 
---| "CLEARING" 
---| "SNOW" 
---| "BLIZZARD" 
---| "SNOWLIGHT" 
---| "XMAS" 
---| "NEUTRAL" 
---| "HALLOWEEN"

---@class AimlabWeatherConfig
---@field enabled boolean force the weather/time below while a session runs, then restore on finish
---@field weather weather?
---@field time? AimlabTimeConfig

---@class AimlabSessionConfig
---@field identifierType string GetPlayerIdentifierByType key used to key stats (e.g. 'license')
---@field maxHits integer reject saved sessions above this many hits (anti-cheat clamp)
---@field saveCooldownMs integer minimum time between accepted saves per player

---@class AimlabModeListEntry
---@field label string display name shown in the menu

---@class AimlabBallsConfig
---@field model string prop model spawned as the target
---@field duration number seconds a ball stays before it counts as a miss
---@field randomizeOrder boolean pick positions at random instead of in sequence
---@field minZ number minimum random height offset added to a position
---@field maxZ number maximum random height offset added to a position
---@field driftHeight number vertical drift amplitude (beachball-v2)
---@field driftSpeed number vertical drift frequency (beachball-v2)
---@field driftWidth number lateral drift amplitude (beachball-v2)
---@field driftSideSpeed number lateral drift frequency (beachball-v2)
---@field positions vector4[] candidate spawn positions

---@class AimlabPedConfig
---@field peds vector4[] spawn positions for target peds

---@class AimlabSprintConfig
---@field peds vector4[][] routes, each a { spawn, destination } pair of vector4

---@class AimlabTrackingConfig
---@field model string prop model spawned as the target
---@field distance number metres the target sits in front of the player
---@field height number metres the target sits above the player
---@field moveWidth number horizontal sweep amplitude
---@field moveHeight number vertical sweep amplitude (tracking-v2)
---@field speed number sweep speed multiplier
---@field tolerance number screen-space radius counted as "on target"
---@field fillSeconds number seconds on target required to score a hit
---@field decayMultiplier number how quickly progress drains while off target

---@class AimlabModesConfig
---@field balls AimlabBallsConfig
---@field combatrollEasy AimlabPedConfig
---@field combatrollMedium AimlabPedConfig
---@field sprint AimlabSprintConfig
---@field tracking AimlabTrackingConfig

---@class AimlabWorldConfig
---@field startPosition vector4 where the player is teleported for most modes
---@field startSprintPosition vector4 where the player is teleported for sprint modes
---@field session AimlabSessionConfig
---@field modeList table<AimlabModeId, AimlabModeListEntry>
---@field modes AimlabModesConfig
---@field zones vector3[]

---@class AimlabConfig
---@field openCommandName string command name used for both the menu and the keybind
---@field openCommandKey string default key the menu is bound to
---@field ownWeapon boolean let players use their own weapons instead of the built-in one
---@field UI AimlabUIConfig
---@field Weather AimlabWeatherConfig
---@field Aimlab AimlabWorldConfig

---@class AimlabScore
---@field hits integer
---@field headshots integer
---@field misses integer
---@field streak integer
---@field bestStreak integer
---@field progress? number 0..1 fill meter for sustained-tracking modes

---@class AimlabHudPayload
---@field hits integer
---@field headshots integer
---@field headshotRate number 0..1
---@field accuracy number 0..1
---@field progress? number 0..1

---@class AimlabSessionResult
---@field mode AimlabModeId
---@field hits integer
---@field headshots integer
---@field headshotRate number 0..1
---@field bestStreak integer
---@field durationMs integer

---@class AimlabModeOptions
---@field drift? boolean beachball: apply vertical/lateral drift to the target
---@field wander? boolean tracking: use an organic wander path instead of a flat sweep

---@class AimlabModeBinding
---@field mode string key into the loaded modes table
---@field opts? AimlabModeOptions options forwarded to the mode when it starts

---@class AimlabSession
---@field hit fun(headshot?: boolean) register a successful hit
---@field miss fun() register a miss (breaks the streak)
---@field setProgress fun(value: number) update the 0..1 progress meter
---@field wasHeadshot fun(ped: number): boolean true if the ped's last damage hit the head

---@class AimlabMode
---@field startMode fun(session: AimlabSession, opts?: AimlabModeOptions)
---@field stopMode fun()

---@class AimlabLifetimeRow
---@field total_sessions integer
---@field total_hits integer
---@field total_headshots integer
---@field headshot_rate number 0..1

---@class AimlabLifetimeSummary
---@field totalSessions integer
---@field totalHits integer
---@field totalHeadshots integer
---@field headshotRate number 0..1 across all sessions

---@class AimlabNui
---@field setReady fun()
---@field setSurface fun(surface: NuiSurface)
---@field acquireFocus fun(withMouse: boolean)
---@field releaseFocus fun()
---@field getSurface fun(): NuiSurface
---@field hasMouseFocus fun(): boolean
---@field send fun(action: string, payload: any)

---@class AimlabWeapon
---@field enable fun()
---@field disable fun()

---@class AimlabWeather
---@field apply fun(opts: { time?: AimlabTimeConfig, weather?: string })
---@field restore fun()
---@field backend fun(): WeatherBackend

---@class AimlabController
---@field isActive fun(): boolean
---@field wasHeadshot fun(ped: number): boolean
---@field hit fun(headshot?: boolean)
---@field miss fun()
---@field setProgress fun(value: number)
---@field start fun(modeId: AimlabModeId): boolean
---@field stop fun()
---@field abort fun()

---@class AimlabDb
---@field ensureSchema fun()
---@field getLifetime fun(identifier: string): AimlabLifetimeRow
---@field recordSession fun(identifier: string, hits: integer, headshots: integer)

---@class AimlabStats
---@field summary fun(row: AimlabLifetimeRow): AimlabLifetimeSummary