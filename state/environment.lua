local _, ns = ...

local bus = ns.bus
local enemies = ns.resources.enemies
local environment = ns.state.environment
local zones = ns.resources.zones

local ENEMIES = enemies.ENEMIES
local EVENTS = bus.EVENTS
local ZONES = zones.ZONES

local state

environment.initState = function()
    state = {
        enemyId = ENEMIES.OTHER.id,
        zoneId = ZONES.OTHER.id,
    }
end

local function basicGetSet(key, callback)
    return {
        get = function ()
            return state[key]
        end,
        set = function (value)
            state[key] = value
            if callback then callback(value) end
        end
    }
end

environment.state = {
    enemyId = basicGetSet("enemyId", function(enemyId)
        bus.fire(EVENTS.ENEMY_CHANGED, enemyId)
    end),
    zoneId = basicGetSet("zoneId", function(zoneId)
        bus.fire(EVENTS.ZONE_CHANGED, zoneId)
    end),
}

local function resetEnvironment()
    environment.state.enemyId.set(ENEMIES.OTHER.id)
    environment.state.zoneId.set(ZONES.OTHER.id)
end

bus.addListener(EVENTS.FEAT_CHANGED, resetEnvironment)
bus.addListener(EVENTS.TRAITS_CHANGED, resetEnvironment)
bus.addListener(EVENTS.WEAKNESSES_CHANGED, resetEnvironment)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, resetEnvironment)