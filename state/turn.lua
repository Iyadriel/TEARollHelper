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

local function setTurn(index, turnTypeID)
    local oldIndex = turnState.state.index.get()
    local oldType = turnState.state.type.get()

    bus.fire(EVENTS.TURN_FINISHED, oldIndex, oldType)

    turnState.state.index.set(index)
    turnState.state.type.set(turnTypeID)

    bus.fire(EVENTS.TURN_STARTED, index, turnTypeID)
end

turnState.state = {
    index = {
        get = function ()
            return state.index
        end,
        set = function (index)
            state.index = index
        end,
        increment = function()
            local oldIndex = turnState.state.index.get()
            local oldType = turnState.state.type.get()
            local newType

            if oldType == TURN_TYPES.PLAYER.id then
                newType = TURN_TYPES.ENEMY.id
            else -- if changing from OUT_OF_COMBAT or ENEMY, set to PLAYER
                newType = TURN_TYPES.PLAYER.id
            end

            setTurn(oldIndex + 1, newType)
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
    },
    inCombat = basicGetSet("inCombat", function(inCombat)
        if inCombat then
            setTurn(1, TURN_TYPES.PLAYER.id)
            bus.fire(EVENTS.COMBAT_STARTED)
        else
            setTurn(0, TURN_TYPES.OUT_OF_COMBAT.id)
            bus.fire(EVENTS.COMBAT_OVER)
        end
    end),
}