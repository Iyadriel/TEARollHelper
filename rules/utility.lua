local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS

local function calculateUtilityValue(roll, useUtilityTrait)
    local value = roll
    if useUtilityTrait then
        local bonus = character.hasFeat(FEATS.PROFESSIONAL) and 8 or 5
        value = value + bonus
    end
    return value
end

rules.utility = {
    calculateUtilityValue = calculateUtilityValue
}