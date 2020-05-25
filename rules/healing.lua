local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules

local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS

local NUM_SPIRIT_PER_GREATER_HEAL_SLOT = 2

local function calculateHealValue(roll, spirit, buff)
    return roll + rules.common.calculateSpiritStat(spirit, buff)
end

local function calculateAmountHealed(healValue)
    if healValue > 19 then
        return 5
    elseif healValue > 14 then
        return 4
    elseif healValue > 9 then
        return 3
    elseif healValue > 4 then
        return 2
    elseif healValue > 0 then
        return 1
    end

    return 0
end

local function applyCritModifier(amountHealed)
    if character.hasRacialTrait(RACIAL_TRAITS.MIGHT_OF_THE_MOUNTAIN) then
        amountHealed = amountHealed + 2
    end

    return amountHealed
end

local function getMaxGreaterHealSlots()
    if character.hasFeat(FEATS.PARAGON) then
        return 0
    end

    local spirit = character.getPlayerSpirit()
    local numSlots = max(0, floor(spirit / NUM_SPIRIT_PER_GREATER_HEAL_SLOT))

    if character.hasSpiritMastery() then
        numSlots = numSlots + 1
    end

    if character.hasFeat(FEATS.MENDER) then
        numSlots = numSlots + 1
    end

    return numSlots
end

local function calculateGreaterHealBonus(numGreaterHealSlots)
    return numGreaterHealSlots * 3
end

local function getMaxExcess()
    return 6
end

local function calculateBaseOutOfCombatBonus()
    if character.getPlayerSpirit() >= NUM_SPIRIT_PER_GREATER_HEAL_SLOT then
        return 3
    end
    return 0
end

local function applyOutOfCombatBonus(amountHealed)
    amountHealed = amountHealed + calculateBaseOutOfCombatBonus()

    if character.hasFeat(FEATS.MEDIC) then
        amountHealed = amountHealed * 2
    end

    return amountHealed
end

local function calculateNumHealsAllowedOutOfCombat()
    return character.hasFeat(FEATS.MEDIC) and 5 or 3
end

local function usesParagon()
    return character.hasFeat(FEATS.PARAGON)
end

local function calculateNumPlayersHealableWithParagon()
    local spirit = character.getPlayerSpirit()
    return 1 + floor(spirit / 3)
end

rules.healing = {
    calculateHealValue = calculateHealValue,
    calculateAmountHealed = calculateAmountHealed,
    applyCritModifier = applyCritModifier,
    getMaxGreaterHealSlots = getMaxGreaterHealSlots,
    calculateGreaterHealBonus = calculateGreaterHealBonus,
    getMaxExcess = getMaxExcess,
    applyOutOfCombatBonus = applyOutOfCombatBonus,
    calculateNumHealsAllowedOutOfCombat = calculateNumHealsAllowedOutOfCombat,
    usesParagon = usesParagon,
    calculateNumPlayersHealableWithParagon = calculateNumPlayersHealableWithParagon
}