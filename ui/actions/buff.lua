local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

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
            return not rules.buffing.canBuff()
        end,
        args = {
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 0,
                hidden = function()
                    return not rules.buffing.shouldShowPreRollUI()
                end,
                args = utils.merge(
                    ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 0 }),
                    ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 1 })
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

                            local msg

                            if buff.amountBuffed > 0 then
                                local amount = tostring(buff.amountBuffed)
                                if buff.isCrit then
                                    msg = COLOURS.CRITICAL .. "BIG BUFF!|r " .. COLOURS.BUFF .. "You can buff everyone in line of sight for " .. amount .. "."
                                else
                                    msg = COLOURS.BUFF .. "You can buff someone for " .. amount .. "."
                                end

                                if buff.usesInspiringPresence then
                                    msg = msg .. COLOURS.NOTE .. "|nYour buff is active in both the current player turn and the next enemy turn."
                                end
                            else
                                msg = COLOURS.NOTE .. "You can't buff anyone with this roll."
                            end

                            return msg
                        end
                    }
                }
            },
            postRoll = {
                order = 3,
                type = "group",
                name = "After rolling",
                inline = true,
                hidden = function()
                    return not rolls.state.buff.currentRoll.get() or not rules.buffing.shouldShowPostRollUI() or rolls.getBuff().amountBuffed <= 0
                end,
                args = {
                    useAscend = ui.helpers.traitButton(TRAITS.ASCEND, {
                        order = 0,
                        hidden = function()
                            return rolls.getBuff().amountBuffed <= 0
                        end,
                    }),
                }
            },
        }
    }
end