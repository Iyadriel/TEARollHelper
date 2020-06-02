local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local character = ns.character
local feats = ns.resources.feats
local rolls = ns.state.rolls
local ui = ns.ui

local FEATS = feats.FEATS

--[[ local options = {
    order: Number
} ]]
ui.modules.actions.modules.rangedSave.getOptions = function(options)
    local sharedOptions = ui.modules.actions.modules.defend.getSharedOptions()

    return {
        name = "Ranged save",
        type = "group",
        order = options.order,
        args = {
            defendThreshold = sharedOptions.defendThreshold,
            roll = ui.modules.turn.modules.roll.getOptions({
                order = 2,
                action = "rangedSave",
                hidden = function()
                    return not (rolls.state.defend.threshold.get() and rolls.state.defend.damageRisk.get())
                end,
            }),
            rangedSave = {
                order = 3,
                type = "group",
                name = "Ranged save",
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
                            local hasWarder = character.hasFeat(FEATS.WARDER)
                            local dmgReductionColour = hasWarder and COLOURS.FEATS.GENERIC or COLOURS.DEFAULT

                            if save.thresholdMet then
                                return COLOURS.SAVE .. "You can fully protect your ally."
                            elseif save.damageReduction > 0 then
                                return dmgReductionColour .. "You can reduce the damage your ally takes by " .. save.damageReduction .. ".|n" .. COLOURS.NOTE .. "However, you cannot act during the next player turn."
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