local _, ns = ...

local actions = ns.actions
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui
local utils = ns.utils

local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES

local state = rolls.state

--[[ local options = {
    order: Number,
    turnTypeID: String,
} ]]
ui.modules.actions.modules.utility.getOptions = function(options)
    local shouldShowPlayerTurnOptions = options.turnTypeID == TURN_TYPES.PLAYER.id
    local preRollArgs = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1 })

    if shouldShowPlayerTurnOptions then
        preRollArgs = utils.merge(preRollArgs, ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 0 }))
    end

    return {
        type = "group",
        name = ACTION_LABELS.utility,
        order = options.order,
        args = {
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 0,
                hidden = function()
                    return not rules.utility.shouldShowPreRollUI(options.turnTypeID)
                end,
                args = utils.merge(preRollArgs, {
                    useArtisan = ui.helpers.traitButton(TRAITS.ARTISAN, {
                        order = 2,
                        checkBuff = true,
                    }),
                    artisanActive = ui.helpers.traitActiveText(TRAITS.ARTISAN, 2),
                }),
            }),
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
                        hidden = function()
                            return not rules.utility.canUseUtilityTraits()
                        end,
                        get = function()
                            return state.utility.useUtilityTrait.get()
                        end,
                        set = function(info, value)
                            state.utility.useUtilityTrait.set(value)
                        end
                    },
                    whitespace = {
                        order = 2,
                        type = "description",
                        name = " |n",
                        hidden = function()
                            return not rules.utility.canUseUtilityTraits()
                        end,
                    },
                    utility = {
                        order = 3,
                        type = "description",
                        desc = "The result of your utility roll",
                        fontSize = "medium",
                        name = function()
                            return actions.toString(ACTIONS.utility, rolls.getUtility())
                        end
                    },
                    confirm = ui.helpers.confirmActionButton(ACTIONS.utility, rolls.getUtility, {
                        order = 4,
                    }),
                }
            },
        }
    }
end