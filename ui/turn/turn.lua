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
        name = function()
            if state.inCombat.get() then
                return "Turn " .. state.index.get()
            end
            return "Out of combat"
        end,
        inline = true,
        order = options.order,
        args = {
            turnType = {
                type = "select",
                name = "Turn type",
                values = {
                    [TURN_TYPES.PLAYER.id] = TURN_TYPES.PLAYER.name,
                    [TURN_TYPES.ENEMY.id] = TURN_TYPES.ENEMY.name,
                },
                width = "half",
                order = 0,
                hidden = function()
                    return not state.inCombat.get()
                end,
                get = state.type.get,
                set = function(info, value)
                    state.type.set(value)
                end
            },
            nextTurn = {
                type = "execute",
                name = "Next turn",
                --width = "full",
                --width = "half",
                order = 1,
                hidden = function()
                    return not state.inCombat.get()
                end,
                func = function()
                    state.index.set(state.index.get() + 1)
                    state.type.set(abs(state.type.get() - 1)) -- switch type
                end
            },
            startCombat = {
                type = "execute",
                name = "Start combat",
                width = "full",
                order = 2,
                hidden = function()
                    return state.inCombat.get()
                end,
                func = function()
                    state.inCombat.set(true)
                end
            },
            endCombat = {
                type = "execute",
                name = "End combat",
                width = 0.75,
                order = 2,
                hidden = function()
                    return not state.inCombat.get()
                end,
                func = function()
                    state.inCombat.set(false)
                end
            },
        }
    }
end