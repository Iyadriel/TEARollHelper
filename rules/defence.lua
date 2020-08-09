local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local traits = ns.resources.traits

local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local TRAITS = traits.TRAITS

local MAX_DAMAGE_PREVENTED = 50

local function calculateDefendValue(roll, damageType, defence, buff)
    return roll + rules.common.calculateDefenceStat(damageType, defence, buff)
end

local function calculateDamageTaken(threshold, defendValue, dmgRisk)
    local safetyMargin = defendValue - threshold
    if safetyMargin >= 0 then
        return 0
    end
    return dmgRisk
end

local function isCrit(roll)
    local critReq = rules.rolls.getCritReq(roll)

    return roll >= critReq
end

local function calculateRetaliationDamage(defence)
    local dmg = 1 + (defence * 2)

    if character.hasRacialTrait(RACIAL_TRAITS.MIGHT_OF_THE_MOUNTAIN) then
        dmg = dmg + 4
    end

    return dmg
end

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.BULWARK) or rules.other.shouldShowPreRollUI()
end

local function shouldShowDamageType()
    return character.hasFeat(FEATS.ETERNAL_SACRIFICE)
end

rules.defence = {
    MAX_DAMAGE_PREVENTED = MAX_DAMAGE_PREVENTED,

    calculateDefendValue = calculateDefendValue,
    calculateDamageTaken = calculateDamageTaken,
    isCrit = isCrit,
    calculateRetaliationDamage = calculateRetaliationDamage,

    shouldShowPreRollUI = shouldShowPreRollUI,
    shouldShowDamageType = shouldShowDamageType,
}