local _, ns = ...

local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local ROLL_MODES = turns.ROLL_MODES

--[[ local options = {
    order: Number
} ]]
ui.modules.turn.modules.roll.getOptions = function(options)
    return {
        type = "group",
        name = "Roll",
        inline = true,
        order = options.order,
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
        }
    }
end