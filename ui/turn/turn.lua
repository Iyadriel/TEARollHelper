local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local character = ns.character
local rules = ns.rules
local turns = ns.turns
local turnState = ns.state.turn
local ui = ns.ui

local TURN_TYPES = ns.state.turn.TURN_TYPES

local ROLL_MODES = turns.ROLL_MODES
local state = turnState.state

-- Update config UI, in case it is also open
local function notifyChange()
    AceConfigRegistry:NotifyChange(ui.modules.config.name)
end

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
            outOfCombat = {
                type = "group",
                name = "Out of combat",
                inline = true,
                order = 0,
                hidden = function()
                    return state.inCombat.get()
                end,
                args = {
                    startCombat = {
                        type = "execute",
                        name = "Start combat",
                        func = function()
                            state.inCombat.set(true)
                        end
                    }
                }
            },
            combat = {
                type = "group",
                name = "Combat",
                inline = true,
                order = 0,
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
                    },
                    endCombat = {
                        type = "execute",
                        name = "End combat",
                        order = 3,
                        func = function()
                            state.inCombat.set(false)
                        end
                    }
                }
            },
            roll = {
                type = "group",
                name = "Roll",
                inline = true,
                order = 1,
                args = {
                    rollMode = {
                        name = "Roll mode",
                        type = "select",
                        order = 0,
                        values = {
                            [ROLL_MODES.DISADVANTAGE] = "Disadvantage",
                            [ROLL_MODES.NORMAL] = "Normal",
                            [ROLL_MODES.ADVANTAGE] = "Advantage"
                        },
                        get = turns.getRollMode,
                        set = function(info, value)
                            turns.setRollMode(value)
                        end
                    },
                    performRoll = {
                        name = function()
                            return turns.isRolling() and "Rolling..." or "Roll"
                        end,
                        type = "execute",
                        desc = "Do a /roll " .. rules.rolls.MAX_ROLL .. ".",
                        disabled = function()
                            return turns.isRolling()
                        end,
                        order = 1,
                        func = turns.roll
                    },
                    roll = {
                        name = "Roll result",
                        type = "range",
                        desc = "The number you rolled",
                        min = 1,
                        softMax = rules.rolls.MAX_ROLL,
                        max = rules.rolls.MAX_ROLL * 2, -- "support" prepping by letting people add rolls together
                        step = 1,
                        order = 2,
                        get = function()
                            return turns.getCurrentTurnValues().roll
                        end,
                        set = function(info, value)
                            turns.setCurrentRoll(value)
                        end
                    },
                    racialTrait = {
                        type = "toggle",
                        name = function()
                            return "Activate racial trait (" .. character.getPlayerRacialTrait().name .. ")"
                        end,
                        desc = function()
                            return character.getPlayerRacialTrait().desc
                        end,
                        width = "full",
                        order = 4,
                        hidden = function()
                            local trait = character.getPlayerRacialTrait()
                            return not (trait.supported and trait.manualActivation)
                        end,
                        get = function()
                            return state.racialTrait ~= nil
                        end,
                        set = function(info, value)
                            state.racialTrait = (value and character.getPlayerRacialTrait() or nil)
                            notifyChange() -- so we can disable/enable trait selection in character sheet
                        end
                    },
                }
            }
        }
    }
end