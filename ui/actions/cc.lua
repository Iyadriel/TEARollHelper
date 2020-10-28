local _, ns = ...

local actions = ns.actions
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local traits = ns.resources.traits
local ui = ns.ui
local utils = ns.utils

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS
local TRAITS = traits.TRAITS

local state = rolls.state

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.cc.getOptions = function(options)
    local preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
        order = 0,
        hidden = function()
            return not rules.cc.shouldShowPreRollUI()
        end,
        args = utils.merge(
            ui.modules.actions.modules.playerTurn.getSharedPreRollOptions({ order = 1 }),
            ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 2 }),
            {
                useCalamityGambit = ui.helpers.traitButton(TRAITS.CALAMITY_GAMBIT, {
                    order = 0,
                    checkBuff = true,
                }),
                calamityGambitActive = ui.helpers.traitActiveText(TRAITS.CALAMITY_GAMBIT, 0),
            }
        ),
    })

    return {
        name = ACTION_LABELS.cc,
        type = "group",
        desc = "Crowd control",
        order = options.order,
        args = {
            preRoll = preRoll,
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 1,
                action = ACTIONS.cc,
            }),
            cc = {
                order = 2,
                type = "group",
                name = ACTION_LABELS.cc,
                inline = true,
                hidden = function()
                    return not state.cc.currentRoll.get()
                end,
                args = {
                    result = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            return actions.toString(ACTIONS.cc, rolls.getCC())
                        end
                    },
                    confirm = ui.helpers.confirmActionButton(ACTIONS.cc, rolls.getCC, {
                        order = 1,
                     }),
                }
            }
        }
    }
end