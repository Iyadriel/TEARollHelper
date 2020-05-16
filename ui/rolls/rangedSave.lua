local _, ns = ...

local COLOURS = TEARollHelper.COLOURS

local actions = ns.actions
local character = ns.character
local feats = ns.resources.feats
local turns = ns.turns
local ui = ns.ui

local FEATS = feats.FEATS

--[[ local options = {
    order: Number
} ]]
ui.modules.rolls.modules.rangedSave.getOptions = function(options)
    return {
        name = "Ranged save",
        type = "group",
        inline = true,
        order = options.order,
        args = {
            saveResult = {
                type = "description",
                fontSize = "medium",
                name = function()
                    local spirit = character.getPlayerSpirit()
                    local values = turns.getCurrentTurnValues()
                    local buff = turns.getCurrentBuffs().spirit
                    local save = actions.getRangedSave(values.roll, values.defendThreshold, values.damageRisk, spirit, buff)
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
        },
    }
end