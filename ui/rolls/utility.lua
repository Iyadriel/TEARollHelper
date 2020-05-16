local _, ns = ...

local actions = ns.actions
local turns = ns.turns
local ui = ns.ui

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
                get = turns.utility.getUseUtilityTrait,
                set = function(info, value)
                    turns.utility.setUseUtilityTrait(value)
                end
            },
            utility = {
                type = "description",
                desc = "The result of your utility roll",
                fontSize = "medium",
                order = 1,
                name = function()
                    local roll = turns.getCurrentTurnValues().roll
                    local useUtilityTrait = turns.utility.getUseUtilityTrait()

                    return " |nYour total utility roll: " .. actions.getUtility(roll, useUtilityTrait)
                end
            }
        }
    }
end