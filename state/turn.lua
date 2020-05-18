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
        type = TURN_TYPES.PLAYER.id
    }
end

turnState.state = {
    index = {
        get = function ()
            return state.index
        end,
        set = function (index)
            state.index = index
        end
    },
    type = {
        get = function ()
            return state.type
        end,
        set = function (type)
            state.type = type
        end
    },
}

turnState.TURN_TYPES = TURN_TYPES