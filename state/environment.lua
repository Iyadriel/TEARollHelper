local _, ns = ...

local bus = ns.bus
local enemies = ns.resources.enemies
local environment = ns.state.environment
local models = ns.models
local zones = ns.resources.zones

local ENEMIES = enemies.ENEMIES
local EVENTS = bus.EVENTS
local ZONES = zones.ZONES

local Unit = models.Unit

local state

environment.initState = function()
    state = {
        enemyId = ENEMIES.OTHER.id,
        zoneId = ZONES.OTHER.id,
        distanceFromEnemy = nil, -- so that user has to manually set their range
        units = {},
    }
end

local function basicGetSet(key, callback)
    return {
        get = function ()
            return state[key]
        end,
        set = function (value)
            if state[key] ~= value then
                state[key] = value
                if callback then callback(value) end
            end
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
    distanceFromEnemy = basicGetSet("distanceFromEnemy", function(distanceFromEnemy)
        bus.fire(EVENTS.DISTANCE_FROM_ENEMY_CHANGED, distanceFromEnemy)
    end),
    units = {
        get = function(markerIndex)
            return state.units[markerIndex]
        end,
        add = function(markerIndex, name)
            if not state.units[markerIndex] then
                state.units[markerIndex] = Unit:New(markerIndex, name)
            end
        end,
        addOrUpdate = function(markerIndex, name)
            if not state.units[markerIndex] then
                environment.state.units.add(markerIndex, name)
            else
                state.units[markerIndex]:SetName(name)
            end
        end,
        remove = function(markerIndex)
            state.units[markerIndex] = nil
        end
    },
}

local function resetEnvironment()
    environment.state.enemyId.set(ENEMIES.OTHER.id)
    environment.state.zoneId.set(ZONES.OTHER.id)
    environment.state.distanceFromEnemy.set(nil)
end

bus.addListener(EVENTS.FEAT_CHANGED, resetEnvironment)
bus.addListener(EVENTS.TRAITS_CHANGED, resetEnvironment)
bus.addListener(EVENTS.WEAKNESSES_CHANGED, resetEnvironment)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, resetEnvironment)