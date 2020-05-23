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
        index = 1,
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
    index = basicGetSet("index"),
    type = basicGetSet("type"),
    inCombat = basicGetSet("inCombat", function(inCombat)
        if inCombat then
            bus.fire(EVENTS.COMBAT_STARTED)
        else
            bus.fire(EVENTS.COMBAT_OVER)
        end
    end),
}

turnState.TURN_TYPES = TURN_TYPES