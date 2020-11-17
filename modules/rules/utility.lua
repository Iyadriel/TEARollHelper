local _, ns = ...

local character = ns.character
local constants = ns.constants
local rules = ns.rules

local feats = ns.resources.feats
local traits = ns.resources.traits
local utilityTypes = ns.resources.utilityTypes
local weaknesses = ns.resources.weaknesses

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS
local TURN_TYPES = constants.TURN_TYPES
local UTILITY_TYPES = utilityTypes.UTILITY_TYPES
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

-- the bonus that the player has for utility rolls of a certain type
local function calculateUtilityTypeBonus(utilityTypeID)
    local racialTrait = character.getPlayerRacialTrait()
    if racialTrait.utilityBonus and racialTrait.utilityBonus[utilityTypeID] then
        return racialTrait.utilityBonus[utilityTypeID]
    end

    return 0
end

-- the bonus added to utility rolls when a utility trait is applicable
local function calculateUtilityTraitBonus(utilityBonusBuff)
    return calculateBaseUtilityBonus() + utilityBonusBuff
end

local function calculateUtilityValue(roll, utilityTypeID, utilityTrait, utilityBonusBuff)
    local value = roll

    if utilityTrait then
        value = value + calculateUtilityTraitBonus(utilityBonusBuff)
    end

    value = value + calculateUtilityTypeBonus(utilityTypeID)

    return value
end

-- Rolling

local function getRollModeModifier(utilityTypeID)
    local modifier = 0

    local racialTrait = character.getPlayerRacialTrait()
    if racialTrait.utilityAdvantage and racialTrait.utilityAdvantage[utilityTypeID] then
        modifier = modifier + 1
    end

    return modifier
end

local function shouldShowUtilityTypeSelect()
    local racialTrait = character.getPlayerRacialTrait()
    return racialTrait.utilityBonus or racialTrait.utilityAdvantage
end

local function shouldShowPreRollUI(turnTypeID)
    return character.hasTrait(TRAITS.ARTISAN) or (turnTypeID == TURN_TYPES.PLAYER.id and rules.playerTurn.shouldShowPreRollUI())
end

rules.utility = {
    MAX_NUM_UTILITY_TRAITS = MAX_NUM_UTILITY_TRAITS,

    canUseUtilityTraits = canUseUtilityTraits,
    getNumAllowedUtilityTraits = getNumAllowedUtilityTraits,
    calculateBaseUtilityBonus = calculateBaseUtilityBonus,
    calculateUtilityValue = calculateUtilityValue,

    getRollModeModifier = getRollModeModifier,
    shouldShowUtilityTypeSelect = shouldShowUtilityTypeSelect,
    shouldShowPreRollUI = shouldShowPreRollUI,
}