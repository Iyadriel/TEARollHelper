local _, ns = ...

local actions = ns.actions
local character = ns.character
local constants = ns.constants
local rolls = ns.state.rolls
local rules = ns.rules
local ui = ns.ui

local ACTIONS = constants.ACTIONS
local ACTION_LABELS = constants.ACTION_LABELS

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.rangedSave.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("rangedSave", {
        thresholdLabel = "The defence threshold for the ally you're saving. If you do not meet this threshold, you can still reduce the damage they take."
    })

    local function shouldHideRoll()
        return not rolls.state.rangedSave.threshold.get()
    end

    return {
        name = ACTION_LABELS.rangedSave,
        type = "group",
        order = options.order,
        hidden = function()
            return not character.canSave()
        end,
        args = {
            defenceType = sharedOptions.defenceType,
            defendThreshold = sharedOptions.defendThreshold,
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 2,
                hidden = function()
                    return shouldHideRoll() or not rules.meleeSave.shouldShowPreRollUI()
                end,
                args = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 0, action = ACTIONS.rangedSave }),
            }),
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 3,
                action = ACTIONS.rangedSave,
                hidden = shouldHideRoll,
            }),
            rangedSave = {
                order = 4,
                type = "group",
                name = ACTION_LABELS.rangedSave,
                inline = true,
                hidden = function()
                    return not rolls.state.rangedSave.currentRoll.get()
                end,
                args = {
                    saveResult = {
                        order = 0,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            return actions.toString(ACTIONS.rangedSave, rolls.getRangedSave())
                        end
                    },
                    confirm = ui.helpers.confirmActionButton(ACTIONS.rangedSave, rolls.getRangedSave, {
                        order = 1,
                    }),
                }
            },
        },
    }
end