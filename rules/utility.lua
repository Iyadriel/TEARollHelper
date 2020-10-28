local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES

local function canUseUtilityTraits()
    return not character.hasWeakness(WEAKNESSES.BRUTE)
end

local function calculateBaseUtilityBonus()
    return character.hasFeat(FEATS.PROFESSIONAL) and 8 or 5
end

local function calculateUtilityBonus(utilityBonusBuff)
    return calculateBaseUtilityBonus() + utilityBonusBuff
end

local function calculateUtilityValue(roll, useUtilityTrait, utilityBonusBuff)
    local value = roll
    if useUtilityTrait then
        local bonus = calculateUtilityBonus(utilityBonusBuff)
        value = value + bonus
    end
    return value
end

local function shouldShowPreRollUI(turnTypeID)
    return rules.other.shouldShowPreRollUI() or (turnTypeID == TURN_TYPES.PLAYER.id and rules.playerTurn.shouldShowPreRollUI())
end

rules.utility = {
    canUseUtilityTraits = canUseUtilityTraits,
    calculateBaseUtilityBonus = calculateBaseUtilityBonus,
    calculateUtilityValue = calculateUtilityValue,
    shouldShowPreRollUI = shouldShowPreRollUI,
}