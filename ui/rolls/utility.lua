local _, ns = ...

local actions = ns.actions
local rolls = ns.state.rolls
local turns = ns.turns
local ui = ns.ui

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.rolls.modules.utility.getOptions = function(options)
    return {
        type = "group",
        name = "Utility",
        inline = true,
        order = options.order,
        args = {
            useUtilityTrait = {
                type = "toggle",
                name = "Use utility trait",
                desc = "Enable if you have a utility trait that fits what you are rolling for.",
                order = 0,
                get = function()
                    return state.utility.useUtilityTrait
                end,
                set = function(info, value)
                    state.utility.useUtilityTrait = value
                end
            },
            utility = {
                type = "description",
                desc = "The result of your utility roll",
                fontSize = "medium",
                order = 1,
                name = function()
                    local roll = turns.getCurrentTurnValues().roll
                    return " |nYour total utility roll: " .. actions.getUtility(roll, state.utility.useUtilityTrait)
                end
            }
        }
    }
end