local _, ns = ...

local bus = ns.bus
local turnState = ns.state.turn

local EVENTS = bus.EVENTS
local TURN_TYPES = {
    PLAYER = { id = 0, name = "Player" },
    ENEMY = { id = 1, name = "Enemy" }
}

local state

turnState.initState = function()
    state = {
        index = 0,
        type = TURN_TYPES.PLAYER.id,
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
            turnState.state.type.set(abs(turnState.state.type.get() - 1))
        end
    },
    inCombat = basicGetSet("inCombat", function(inCombat)
        if inCombat then
            turnState.state.index.set(1)
            bus.fire(EVENTS.COMBAT_STARTED)
        else
            turnState.state.index.reset()
            bus.fire(EVENTS.COMBAT_OVER)
        end
    end),
}

turnState.TURN_TYPES = TURN_TYPES