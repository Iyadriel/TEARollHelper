local _, ns = ...

local constants = ns.constants
local turnState = ns.state.turn
local ui = ns.ui

local TURN_TYPES = constants.TURN_TYPES

local state = turnState.state

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.turn.getOptions = function(options)
    return {
        type = "group",
        name = function()
            if state.inCombat.get() then
                return ui.iconString("Interface\\Icons\\ability_warrior_challange", "small") .. "Turn " .. state.index.get()
            end
            return TURN_TYPES.OUT_OF_COMBAT.name
        end,
        inline = true,
        order = options.order,
        args = {
            turnType = {
                type = "select",
                name = function()
                    if state.inCombat.get() then
                        return ui.iconString("Interface\\Icons\\ability_warrior_challange", "small") .. "Turn " .. state.index.get()
                    end
                    return TURN_TYPES.OUT_OF_COMBAT.name
                end,
                width = 0.7,
                values = {
                    [TURN_TYPES.PLAYER.id] = TURN_TYPES.PLAYER.name .. " turn",
                    [TURN_TYPES.ENEMY.id] = TURN_TYPES.ENEMY.name .. " turn",
                    --[TURN_TYPES.OUT_OF_COMBAT.id] = "End combat",
                },
                sorting = {TURN_TYPES.PLAYER.id, TURN_TYPES.ENEMY.id},
                --sorting = {TURN_TYPES.PLAYER.id, TURN_TYPES.ENEMY.id, TURN_TYPES.OUT_OF_COMBAT.id},
                order = 0,
                hidden = function()
                    return not state.inCombat.get()
                end,
                get = state.type.get,
                set = function(info, value)
--[[                     if value == TURN_TYPES.OUT_OF_COMBAT.id then
                        state.inCombat.set(false)
                    else ]]
                        state.type.set(value)
                    --end
                end
            },
            nextTurn = {
                type = "execute",
                name = "Next turn",
                width = 1.6,
                order = 1,
                hidden = function()
                    return not state.inCombat.get()
                end,
                func = state.index.increment,
            },
            startCombat = {
                type = "execute",
                name = ui.iconString("Interface\\Icons\\ability_warrior_challange", "small") .. "Start combat",
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