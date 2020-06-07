local _, ns = ...

local bus = ns.bus
local enemies = ns.resources.enemies
local environment = ns.state.environment

local ENEMIES = enemies.ENEMIES
local EVENTS = bus.EVENTS

local state

environment.initState = function()
    state = {
        enemyId = ENEMIES.OTHER.id,
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
}

local function resetEnvironment()
    environment.state.enemyId.set(ENEMIES.OTHER.id)
end

bus.addListener(EVENTS.FEAT_CHANGED, resetEnvironment)
bus.addListener(EVENTS.TRAITS_CHANGED, resetEnvironment)
bus.addListener(EVENTS.WEAKNESSES_CHANGED, resetEnvironment)
bus.addListener(EVENTS.RACIAL_TRAIT_CHANGED, resetEnvironment)