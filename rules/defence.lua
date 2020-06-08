local _, ns = ...

local character = ns.character
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local traits = ns.resources.traits

local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local TRAITS = traits.TRAITS

local function calculateDefendValue(roll, defence, buff)
    return roll + rules.common.calculateDefenceStat(defence, buff)
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
    local dmg = 1 + defence

    if character.hasRacialTrait(RACIAL_TRAITS.MIGHT_OF_THE_MOUNTAIN) then
        dmg = dmg + 4
    end

    return dmg
end

local function shouldShowPreRollUI()
    return character.hasTrait(TRAITS.BULWARK)
end

rules.defence = {
    calculateDefendValue = calculateDefendValue,
    calculateDamageTaken = calculateDamageTaken,
    isCrit = isCrit,
    calculateRetaliationDamage = calculateRetaliationDamage,
    shouldShowPreRollUI = shouldShowPreRollUI,
}