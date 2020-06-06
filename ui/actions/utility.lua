local _, ns = ...

local actions = ns.actions
local constants = ns.constants
local rolls = ns.state.rolls
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.utility.getOptions = function(options)
    return {
        type = "group",
        name = ACTION_LABELS.utility,
        order = options.order,
        args = {
            roll = ui.modules.turn.modules.roll.getOptions({ order = 0, action = ACTIONS.utility }),
            utility = {
                order = 1,
                type = "group",
                name = ACTION_LABELS.utility,
                inline = true,
                hidden = function()
                    return not state.utility.currentRoll.get()
                end,
                args = {
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
                            local roll = state.utility.currentRoll.get()
                            return " |nYour total utility roll: " .. actions.getUtility(roll, state.utility.useUtilityTrait)
                        end
                    }
                }
            },
        }
    }
end