local _, ns = ...

local turnState = ns.state.turn
local ui = ns.ui

local TURN_TYPES = ns.state.turn.TURN_TYPES

local state = turnState.state

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.turn.getOptions = function(options)
    return {
        type = "group",
        name = "Turn",
        inline = true,
        order = options.order,
        args = {
            toggleCombat = {
                type = "execute",
                name = function()
                    return state.inCombat.get() and "End combat" or "Start combat"
                end,
                width = "full",
                order = 0,
                func = function()
                    state.inCombat.set(not state.inCombat.get())
                end
            },
            combat = {
                type = "group",
                name = "Combat",
                inline = true,
                order = 1,
                hidden = function()
                    return not state.inCombat.get()
                end,
                args = {
                    turnLabel = {
                        type = "description",
                        name = function()
                            return "Turn " .. state.index.get()
                        end,
                        fontSize = "large",
                        order = 0,
                    },
                    turnType = {
                        type = "select",
                        name = "Turn type",
                        order = 1,
                        values = {
                            [TURN_TYPES.PLAYER.id] = TURN_TYPES.PLAYER.name,
                            [TURN_TYPES.ENEMY.id] = TURN_TYPES.ENEMY.name,
                        },
                        get = state.type.get,
                        set = function(info, value)
                            state.type.set(value)
                        end
                    },
                    nextTurn = {
                        type = "execute",
                        name = "Next turn",
                        order = 2,
                        func = function()
                            state.index.set(state.index.get() + 1)
                            state.type.set(abs(state.type.get() - 1)) -- switch type
                        end
                    }
                }
            },
        }
    }
end