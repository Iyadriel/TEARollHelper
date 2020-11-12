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
        list = function()
            return state.units
        end,
        get = function(unitIndex)
            return state.units[unitIndex]
        end,
        count = function()
            local count = 0
            for unitIndex, unit in pairs(state.units) do
                count = count + 1
            end
            return count
        end,
        add = function(unitIndex, name, isLocal)
            local unit = state.units[unitIndex]
            if not unit then
                unit = Unit:New(unitIndex, name)
                state.units[unitIndex] = unit
                bus.fire(EVENTS.UNIT_ADDED, isLocal, unit)
            end
        end,
        update = function(unitIndex, name, isLocal)
            local unit = state.units[unitIndex]
            if unit then
                unit:SetName(name)
                bus.fire(EVENTS.UNIT_UPDATED, isLocal, unit)
            end
        end,
        remove = function(unitIndex, isLocal)
            state.units[unitIndex] = nil
            bus.fire(EVENTS.UNIT_REMOVED, isLocal, unitIndex)
        end,
        replaceList = function(units, isLocal)
            state.units = {}

            for unitIndex, unit in pairs(units) do
                state.units[unitIndex] = Unit:New(unitIndex, unit.name)
            end

            bus.fire(EVENTS.UNITS_REPLACED, isLocal)
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