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
                    buff = {
                        type = "description",
                        desc = "How much you can buff for",
                        fontSize = "medium",
                        order = 0,
                        name = function()
                            local buff = rolls.getBuff()

                            return actions.toString(ACTIONS.buff, buff)
                        end
                    },
                    useAscend = ui.helpers.traitToggle(ACTIONS.buff, rolls.getBuff, TRAITS.ASCEND, {
                        order = 1,
                    }),
                    confirm = ui.helpers.confirmActionButton(ACTIONS.buff, rolls.getBuff, {
                       order = 2,
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