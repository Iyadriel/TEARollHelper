local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local WEAKNESSES = weaknesses.WEAKNESSES

local function canUseUtilityTraits()
    return not character.hasWeakness(WEAKNESSES.BRUTE)
end

local function calculateUtilityValue(roll, useUtilityTrait)
    local value = roll
    if useUtilityTrait then
        local bonus = character.hasFeat(FEATS.PROFESSIONAL) and 8 or 5
        value = value + bonus
    end
    return value
end

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.FOCUS) or rules.other.shouldShowPreRollUI()
end

rules.utility = {
    canUseUtilityTraits = canUseUtilityTraits,
    calculateUtilityValue = calculateUtilityValue,
    shouldShowPreRollUI = shouldShowPreRollUI,
}