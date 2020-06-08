local _, ns = ...

local actions = ns.actions
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local TURN_TYPES = constants.TURN_TYPES

local state = rolls.state

--[[ local options = {
    order: Number,
    turnTypeID: String,
} ]]
ui.modules.actions.modules.utility.getOptions = function(options)
    local shouldShowPlayerTurnOptions = options.turnTypeID == TURN_TYPES.PLAYER.id
    local sharedOptions

    if shouldShowPlayerTurnOptions then
        sharedOptions = ui.modules.actions.modules.playerTurn.getSharedOptions({
            order = 0,
            hidden = function()
                return not rules.utility.shouldShowPreRollUI()
            end,
        })
    end

    return {
        type = "group",
        name = ACTION_LABELS.utility,
        order = options.order,
        args = {
            preRoll = shouldShowPlayerTurnOptions and sharedOptions.preRoll or nil,
            roll = ui.modules.turn.modules.roll.getOptions({ order = 1, action = ACTIONS.utility }),
            utility = {
                order = 2,
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