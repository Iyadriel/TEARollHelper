local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

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
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions("rangedSave")

    local function shouldHideRoll()
        return not rolls.state.rangedSave.threshold.get()
    end

    return {
        name = ACTION_LABELS.rangedSave,
        type = "group",
        order = options.order,
        args = {
            defendThreshold = sharedOptions.defendThreshold,
            preRoll = ui.modules.turn.modules.roll.getPreRollOptions({
                order = 2,
                hidden = function()
                    return shouldHideRoll() or not rules.meleeSave.shouldShowPreRollUI()
                end,
                args = ui.modules.actions.modules.anyTurn.getSharedPreRollOptions({ order = 0 }),
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
                        order = 4,
                        type = "description",
                        fontSize = "medium",
                        name = function()
                            local save = rolls.getRangedSave()

                            if save.canFullyProtect then
                                return COLOURS.ROLES.TANK .. "You can fully protect your ally."
                            elseif save.damageReduction > 0 then
                                return "You can reduce the damage your ally takes by " .. save.damageReduction .. ".|n" .. COLOURS.NOTE .. "However, you cannot act during the next player turn."
                            else
                                return COLOURS.NOTE .. "You can't reduce the damage your ally takes with this roll."
                            end
                        end
                    },
                }
            },
        },
    }
end