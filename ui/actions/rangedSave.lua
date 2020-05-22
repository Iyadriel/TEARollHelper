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
        },
    }
end