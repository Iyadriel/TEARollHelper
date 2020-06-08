local _, ns = ...

local bus = ns.bus
local constants = ns.constants
local turnState = ns.state.turn

local EVENTS = bus.EVENTS
local TURN_TYPES = constants.TURN_TYPES

local state

turnState.initState = function()
    state = {
        index = 0,
        type = TURN_TYPES.OUT_OF_COMBAT.id,
        inCombat = false,
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

turnState.state = {
    index = {
        get = function ()
            return state.index
        end,
        set = function (index)
            local oldIndex = state.index
            state.index = index
            bus.fire(EVENTS.TURN_CHANGED, index)
            if index > oldIndex then
                bus.fire(EVENTS.TURN_INCREMENTED)
            end
        end,
        increment = function()
            turnState.state.index.set(turnState.state.index.get() + 1)
        end,
        reset = function()
            turnState.state.index.set(0)
        end
    },
    type = {
        get = function ()
            return state.type
        end,
        set = function (type)
            state.type = type
        end,
        switch = function()
            local currentType = turnState.state.type.get()
            if currentType == TURN_TYPES.PLAYER.id then
                turnState.state.type.set(TURN_TYPES.ENEMY.id)
            else
                turnState.state.type.set(TURN_TYPES.PLAYER.id)
            end
        end
    },
    inCombat = basicGetSet("inCombat", function(inCombat)
        if inCombat then
            turnState.state.index.set(1)
            turnState.state.type.set(TURN_TYPES.PLAYER.id)
            bus.fire(EVENTS.COMBAT_STARTED)
        else
            turnState.state.index.reset()
            turnState.state.type.set(TURN_TYPES.OUT_OF_COMBAT.id)
            bus.fire(EVENTS.COMBAT_OVER)
        end
    end),
}