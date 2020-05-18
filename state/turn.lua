local _, ns = ...

local turnState = ns.state.turn

local TURN_TYPES = {
    PLAYER = { id = 0, name = "Player" },
    ENEMY = { id = 1, name = "Enemy" }
}

local state

turnState.initState = function()
    state = {
        index = 1,
        type = TURN_TYPES.PLAYER.id,
        inCombat = true,
    }
end

local function basicGetSet(key)
    return {
        get = function ()
            return state[key]
        end,
        set = function (value)
            state[key] = value
        end
    }
end

turnState.state = {
    index = basicGetSet("index"),
    type = basicGetSet("type"),
    --inCombat = basicGetSet("inCombat"),
}

turnState.TURN_TYPES = TURN_TYPES