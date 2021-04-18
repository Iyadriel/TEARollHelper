local _, ns = ...

local character = ns.character
local constants = ns.constants
local rules = ns.rules

local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local traits = ns.resources.traits

local ACTIONS = constants.ACTIONS
local DEFENCE_TYPES = constants.DEFENCE_TYPES
local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local TRAITS = traits.TRAITS

local MAX_DAMAGE_PREVENTED = 15

local function calculateDefendValue(roll, damageType, defence, buff)
    return roll + rules.common.calculateDefenceStat(damageType, defence, buff)
end

local function canUseBraceSystem()
    return character.hasDefenceMastery()
end

local function getMaxBraceCharges()
    return character.hasFeat(FEATS.MASTER) and 5 or 3
end

local function calculateBraceDefenceBonus(numBraceCharges)
    return numBraceCharges * 2
end

local function calculateEffectiveIncomingDamage(defenceType, incomingDamage, damageTakenBuff)
    if character.hasFeat(FEATS.LIVING_BARRICADE) and defenceType == DEFENCE_TYPES.DAMAGE_REDUCTION then
        incomingDamage = incomingDamage - 5
    end
    return rules.effects.calculateEffectiveIncomingDamage(incomingDamage, damageTakenBuff, true)
end

local function calculateDamageTaken(defenceType, threshold, defendValue, effectiveIncomingDamage)
    if defenceType == DEFENCE_TYPES.THRESHOLD then
        local safetyMargin = defendValue - threshold
        if safetyMargin >= 0 then
            return 0
        end
        return effectiveIncomingDamage
    else
        return max(0, effectiveIncomingDamage - defendValue)
    end
end

local function calculateDamagePrevented(dmgRisk, damageTaken)
    if canUseBraceSystem() then
        return dmgRisk - damageTaken
    end
    return 0
end

local function isCrit(roll)
    local critReq = rules.rolls.getCritReq(ACTIONS.defend)

    return roll >= critReq
end

local function calculateRetaliationDamage(defence)
    local dmg = 1 + (defence * 2)

    if character.hasRacialTrait(RACIAL_TRAITS.MIGHT_OF_THE_MOUNTAIN) then
        dmg = dmg + 4
    end

    return dmg
end

-- Feat: Bulwark of Hope

local function hasBulwarkOfHopeProc(damageTaken)
    return damageTaken <= 0
end

-- Feat: Defensive Tactician

local function hasDefensiveTacticianProc(damageTaken)
    return damageTaken <= 0
end

local function shouldShowPreRollUI()
    return character.hasFeat(FEATS.LIVING_BARRICADE)
        or character.hasTrait(TRAITS.APEX_PROTECTOR)
        or character.hasTrait(TRAITS.ANQULANS_REDOUBT)
        or rules.other.shouldShowPreRollUI()
end

local function shouldShowDamageType()
    return character.hasFeat(FEATS.ETERNAL_SACRIFICE)
end

rules.defence = {
    MAX_DAMAGE_PREVENTED = MAX_DAMAGE_PREVENTED,

    calculateDefendValue = calculateDefendValue,
    canUseBraceSystem = canUseBraceSystem,
    getMaxBraceCharges = getMaxBraceCharges,
    calculateBraceDefenceBonus = calculateBraceDefenceBonus,
    calculateEffectiveIncomingDamage = calculateEffectiveIncomingDamage,
    calculateDamageTaken = calculateDamageTaken,
    calculateDamagePrevented = calculateDamagePrevented,
    isCrit = isCrit,
    calculateRetaliationDamage = calculateRetaliationDamage,

    hasBulwarkOfHopeProc = hasBulwarkOfHopeProc,
    hasDefensiveTacticianProc = hasDefensiveTacticianProc,

    shouldShowPreRollUI = shouldShowPreRollUI,
    shouldShowDamageType = shouldShowDamageType,
}
