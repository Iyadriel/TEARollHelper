local _, ns = ...

local actions = ns.actions
local rolls = ns.state.rolls
local turns = ns.turns
local ui = ns.ui

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.utility.getOptions = function(options)
    return {
        type = "group",
        name = "Utility",
        order = options.order,
        args = {
            roll = ui.modules.turn.modules.roll.getOptions({ order = 0, action = "utility" }),
            useUtilityTrait = {
                order = 1 ,
                type = "toggle",
                name = "Use utility trait",
                desc = "Enable if you have a utility trait that fits what you are rolling for.",
                get = function()
                    return state.utility.useUtilityTrait
                end,
                set = function(info, value)
                    state.utility.useUtilityTrait = value
                end
            },
            utility = {
                order = 2,
                type = "description",
                desc = "The result of your utility roll",
                fontSize = "medium",
                name = function()
                    local roll = turns.getRollValues().roll
                    return " |nYour total utility roll: " .. actions.getUtility(roll, state.utility.useUtilityTrait)
                end
            }
        }
    }
end