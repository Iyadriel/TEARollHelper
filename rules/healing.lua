local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS

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

local function getMaxGreaterHealSlots()
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

rules.healing = {
    calculateHealValue = calculateHealValue,
    calculateAmountHealed = calculateAmountHealed,
    getMaxGreaterHealSlots = getMaxGreaterHealSlots,
    calculateGreaterHealBonus = calculateGreaterHealBonus,
    applyOutOfCombatBonus = applyOutOfCombatBonus,
    calculateNumHealsAllowedOutOfCombat = calculateNumHealsAllowedOutOfCombat
}