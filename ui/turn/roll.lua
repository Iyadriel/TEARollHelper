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
                order = 0,
                name = "Roll mode",
                type = "select",
                width = 0.65,
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
            prep = {
                order = 1,
                type = "toggle",
                name = "Include prep",
                desc = "Activate if you prepared during the last player turn. Rolls twice and adds up the results before applying bonuses.",
                width = 0.55,
                disabled = true, -- hotfix for new prep system
                get = function()
                    return turns.getRollValues().prepMode
                end,
                set = function(info, value)
                    turns.getRollValues().prepMode = value
                end,
            },
            roll = {
                order = 2,
                name = "Roll result",
                type = "range",
                desc = "The number you rolled",
                min = 1,
                max = rules.rolls.MAX_ROLL,
                step = 1,
                width = 1.1,
                disabled = function()
                    -- messing with roll result manually when it is the result of a prep will break crit detection
                    -- eventually we should get rid of manually changing the roll result
                    return turns.getRollValues().preppedRoll ~= nil
                end,
                get = function()
                    return turns.getRollValues().roll
                end,
                set = function(info, value)
                    turns.setCurrentRoll(value)
                    turns.updateIsCrit()
                end
            },
            performRoll = {
                order = 3,
                name = function()
                    return turns.isRolling() and "Rolling..." or "Roll"
                end,
                type = "execute",
                desc = "Do a /roll " .. rules.rolls.MAX_ROLL .. ".",
                disabled = function()
                    return turns.isRolling()
                end,
                width = "full",
                func = turns.roll
            },
        }
    }
end