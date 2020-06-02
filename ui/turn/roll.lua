local _, ns = ...

local rollState = ns.state.rolls
local rules = ns.rules
local turns = ns.turns
local ui = ns.ui

local ROLL_MODES = turns.ROLL_MODES
local state = rollState.state

--[[ local options = {
    order: Number,
    action: String, -- attack, healing, buff, defend, meleeSave, rangedSave, utility
    includePrep: Boolean,
    hidden: Function,
} ]]
ui.modules.turn.modules.roll.getOptions = function(options)
    return {
        type = "group",
        name = "Roll",
        inline = true,
        order = options.order,
        hidden = options.hidden or false,
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
                get = state[options.action].rollMode.get,
                set = function(info, value)
                    state[options.action].rollMode.set(value)
                end
            },
            prep = {
                order = 1,
                type = "toggle",
                name = "Include prep",
                desc = "Activate if you prepared during the last player turn. Rolls twice and adds up the results before applying bonuses.",
                width = 0.55,
                hidden = not options.includePrep,
                get = function()
                    return state[options.action].prepMode.get()
                end,
                set = function(info, value)
                    turns.setAction(options.action)
                    state[options.action].prepMode.set(value)
                end,
            },
            performRoll = {
                order = 2,
                type = "execute",
                name = function()
                    return turns.isRolling() and "Rolling..." or "Roll"
                end,
                desc = "Do a /roll " .. rules.rolls.MAX_ROLL .. ".",
                width = options.includePrep and 0.85 or 1.4,
                disabled = function()
                    return turns.isRolling()
                end,
                func = function()
                    local rollMode = state[options.action].rollMode.get()
                    local prepMode = options.includePrep and state[options.action].prepMode.get() or false
                    turns.setAction(options.action)
                    turns.roll(rollMode, prepMode)
                end
            },
            roll = {
                order = 3,
                name = "Roll result",
                type = "range",
                desc = "The number you rolled",
                min = 1,
                max = rules.rolls.MAX_ROLL,
                step = 1,
                get = function()
                    return state[options.action].currentRoll.get()
                end,
                set = function(info, value)
                    turns.setAction(options.action)
                    turns.setCurrentRoll(value)
                end
            },
            prepRoll = {
                order = 4,
                name = "Prep roll result",
                type = "range",
                desc = "The number you rolled",
                min = 1,
                max = rules.rolls.MAX_ROLL,
                step = 1,
                hidden = not options.includePrep or function()
                    return not state[options.action].prepMode.get()
                end,
                get = function()
                    return state[options.action].currentPreppedRoll.get()
                end,
                set = function(info, value)
                    turns.setAction(options.action)
                    turns.setPreppedRoll(value)
                end
            },
        }
    }
end