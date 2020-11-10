local _, ns = ...

local character = ns.character
local constants = ns.constants
local rules = ns.rules

local feats = ns.resources.feats
local traits = ns.resources.traits
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES

local MAX_NUM_UTILITY_TRAITS = 5 -- static constant to know how many UI elements to create for this

local function canUseUtilityTraits()
    return not character.hasWeakness(WEAKNESSES.BRUTE)
end

local function getNumAllowedUtilityTraits()
    local numTraits = 3

    if character.hasFeat(FEATS.PROFESSIONAL) then
        numTraits = numTraits + 2
    end

    return numTraits
end

-- also used to calculate artisan trait bonus
local function calculateBaseUtilityBonus()
    return character.hasFeat(FEATS.PROFESSIONAL) and 8 or 5
end

local function calculateUtilityBonus(utilityBonusBuff)
    return calculateBaseUtilityBonus() + utilityBonusBuff
end

local function calculateUtilityValue(roll, utilityTrait, utilityBonusBuff)
    local value = roll
    if utilityTrait then
        local bonus = calculateUtilityBonus(utilityBonusBuff)
        value = value + bonus
    end
    return value
end

local function shouldShowPreRollUI(turnTypeID)
    return character.hasTrait(TRAITS.ARTISAN) or rules.other.shouldShowPreRollUI() or (turnTypeID == TURN_TYPES.PLAYER.id and rules.playerTurn.shouldShowPreRollUI())
end

rules.utility = {
    MAX_NUM_UTILITY_TRAITS = MAX_NUM_UTILITY_TRAITS,

    canUseUtilityTraits = canUseUtilityTraits,
    getNumAllowedUtilityTraits = getNumAllowedUtilityTraits,
    calculateBaseUtilityBonus = calculateBaseUtilityBonus,
    calculateUtilityValue = calculateUtilityValue,
    shouldShowPreRollUI = shouldShowPreRollUI,
}