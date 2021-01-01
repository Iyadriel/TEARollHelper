local _, ns = ...

local actions = ns.actions
local character = ns.character
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local CRIT_TYPES = constants.CRIT_TYPES
local TRAITS = traits.TRAITS

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.buff.getOptions = function(options)
    return {
        name = ACTION_LABELS.buff,
        type = "group",
        order = options.order,
        hidden = function()
            return not character.canBuff()
        end,
        args = {
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 0,
                hidden = function()
                    return not rules.buffing.shouldShowPreRollUI()
                end,
                args = utils.merge(
                    ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 0 }),
                    ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1, action = ACTIONS.buff })
                )
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 1,
                action = ACTIONS.buff,
            }),
            buff = {
                order = 2,
                type = "group",
                name = ACTION_LABELS.buff,
                inline = true,
                hidden = function()
                    return not rolls.state.buff.currentRoll.get()
                end,
                args = {
                    critType = {
                        order = 0,
                        type = "select",
                        name = "Crit effect",
                        width = 0.8,
                        hidden = function()
                            return not rolls.getBuff().isCrit
                        end,
                        values = {
                            [CRIT_TYPES.VALUE_MOD] = "Double amount",
                            [CRIT_TYPES.MULTI_TARGET] = "Many buffs",
                        },
                        get = rolls.state.buff.critType.get,
                        set = function(info, value)
                            rolls.state.buff.critType.set(value)
                        end
                    },
                    critTypeMargin = {
                        order = 1,
                        type = "description",
                        name = " ",
                        hidden = function()
                            return not rolls.getBuff().isCrit
                        end,
                    },
                    buff = {
                        order = 2,
                        type = "description",
                        desc = "How much you can buff for",
                        fontSize = "medium",
                        name = function()
                            local buff = rolls.getBuff()

                            return actions.toString(ACTIONS.buff, buff)
                        end
                    },
                    useAscend = ui.helpers.traitToggle(ACTIONS.buff, TRAITS.ASCEND, {
                        order = 3,
                    }),
                    confirm = ui.helpers.confirmActionButton(ACTIONS.buff, rolls.getBuff, {
                       order = 4,
                       hidden = function()
                            local buff = rolls.getBuff()
                            local shouldShow = buff.amountBuffed > 0

                            return not shouldShow
                        end
                    }),
                }
            },
        }
    }
end