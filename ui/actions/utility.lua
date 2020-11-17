local _, ns = ...

local actions = ns.actions
local character = ns.character
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui
local utils = ns.utils

local traits = ns.resources.traits
local utilityTypes = ns.resources.utilityTypes

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES

local state = rolls.state

local UTILITY_TYPE_OPTIONS = (function()
    local options = {}

    for i = 1, #utilityTypes.UTILITY_TYPE_KEYS do
        local key = utilityTypes.UTILITY_TYPE_KEYS[i]
        local utilityType = utilityTypes.UTILITY_TYPES[key]

        options[key] = utilityType.name
    end

    return options
end)()

--[[ local options = {
    order: Number,
    turnTypeID: String,
} ]]
ui.modules.actions.modules.utility.getOptions = function(options)
    local shouldShowPlayerTurnOptions = options.turnTypeID == TURN_TYPES.PLAYER.id
    local preRollArgs = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1, action = ACTIONS.utility })

    if shouldShowPlayerTurnOptions then
        preRollArgs = utils.merge(preRollArgs, ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 0 }))
    end

    return {
        type = "group",
        name = ACTION_LABELS.utility,
        order = options.order,
        args = {
            utilityType = {
                order = 0,
                name = "Utility type",
                type = "select",
                width = 1.25,
                desc = "The type of utility you're rolling for. This will apply any bonuses you have for that type to your roll.",
                hidden = function()
                    return not rules.utility.shouldShowUtilityTypeSelect()
                end,
                values = UTILITY_TYPE_OPTIONS,
                get = state.utility.utilityTypeID.get,
                set = function(info, value)
                    state.utility.utilityTypeID.set(value)
                end
            },
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 1,
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
            roll = ui.modules.turn.modules.roll.getOptions({ order = 2, action = ACTIONS.utility }),
            utility = {
                order = 3,
                type = "group",
                name = ACTION_LABELS.utility,
                inline = true,
                hidden = function()
                    return not state.utility.currentRoll.get()
                end,
                args = {
                    utilityTrait = {
                        order = 1 ,
                        type = "select",
                        name = "Utility trait",
                        desc = "Select an applicable utility trait to use, if any.",
                        values = function()
                            local utilityTraits = {
                                [0] = "None",
                            }

                            for slotIndex, trait in pairs(character.getDefinedUtilityTraits()) do
                               utilityTraits[slotIndex] = trait.name
                            end

                            return utilityTraits
                        end,
                        disabled = function()
                            return not rules.utility.canUseUtilityTraits()
                        end,
                        get = function()
                            return state.utility.utilityTraitSlot.get()
                        end,
                        set = function(info, value)
                            state.utility.utilityTraitSlot.set(value)
                        end
                    },
                    whitespace = {
                        order = 2,
                        type = "description",
                        name = " |n",
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