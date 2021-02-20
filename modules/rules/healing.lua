local _, ns = ...

local character = ns.character
local constants = ns.constants
local feats = ns.resources.feats
local racialTraits = ns.resources.racialTraits
local rules = ns.rules
local weaknesses = ns.resources.weaknesses

local CRIT_TYPES = constants.CRIT_TYPES
local FEATS = feats.FEATS
local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS
local TURN_TYPES = constants.TURN_TYPES
local WEAKNESSES = weaknesses.WEAKNESSES

local NUM_EXCESS_TO_RESTORE_GREATER_HEAL_SLOT = 3

local function canHealInCombat()
    return not character.hasFeat(FEATS.DIVINE_PURPOSE)
end

local function canHeal(outOfCombat)
    return not character.hasWeakness(WEAKNESSES.BRUTE) and (outOfCombat or canHealInCombat())
end

local function calculateHealValue(roll, spirit, buff)
    return roll + rules.common.calculateSpiritStat(spirit, buff)
end

local function calculateBaseAmountHealed(healValue)
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

local function applySpiritBonus(amountHealed)
    if character.hasSpiritProficiency() then
        return amountHealed + 2
    end
    return amountHealed
end

local function applyHealingDoneBuff(amountHealed, healingDoneBuff)
    return amountHealed + healingDoneBuff
end

local function isCrit(roll)
    local critReq = rules.rolls.getCritReq(roll)

    return roll >= critReq
end

local function applyCritModifier(amountHealed, critType)
    if critType == CRIT_TYPES.VALUE_MOD then
        amountHealed = amountHealed * 2
    end

    if character.hasRacialTrait(RACIAL_TRAITS.MIGHT_OF_THE_MOUNTAIN) then
        amountHealed = amountHealed + 2
    end

    return amountHealed
end

local function getNumSpiritPerGreaterHealSlot()
    return character.hasWeakness(WEAKNESSES.TEMPERED_BENEVOLENCE) and 3 or 2
end

local function getBaseGreaterHealSlots()
    local spirit = character.getPlayerSpirit()
    return max(0, floor(spirit / getNumSpiritPerGreaterHealSlot()))
end

local function getMaxGreaterHealSlots()
    if character.hasFeat(FEATS.PARAGON) then
        return 0
    end

    local numSlots = getBaseGreaterHealSlots()

    if character.hasSpiritProficiency() and not character.hasWeakness(WEAKNESSES.TEMPERED_BENEVOLENCE) then
        numSlots = numSlots + 1
    end

    if character.hasFeat(FEATS.MENDER) then
        numSlots = numSlots + 2
    end

    return numSlots
end

local function calculateGreaterHealBonus(numGreaterHealSlots)
    return numGreaterHealSlots * 3
end

local function canUseTargetKOBonus()
    return character.hasSpiritMastery()
end

local function getTargetKOBonus()
    return 2
end

local function canUseExcess()
    return not character.hasWeakness(WEAKNESSES.OVERFLOW)
end

local function getMaxExcess()
    return 6
end

local function canStillHeal(outOfCombat, remainingOutOfCombatHeals, numGreaterHealSlotsUsed)
    return not outOfCombat or remainingOutOfCombatHeals > 0 or numGreaterHealSlotsUsed > 0
end

local function applyOutOfCombatBaseAmountBonus(amountHealed)
    if character.hasFeat(FEATS.MEDIC) then
        amountHealed = amountHealed * 2
    end

    return amountHealed
end

local function getOutOfCombatBonus()
    if character.getPlayerSpirit() >= getNumSpiritPerGreaterHealSlot() then
        return 3
    end
    return 0
end

local function getMaxOutOfCombatHeals()
    return character.hasFeat(FEATS.MEDIC) and 5 or 3
end

-- Feat: Chaplain of Violence

local function canProcChaplainOfViolence()
    return character.hasFeat(FEATS.CHAPLAIN_OF_VIOLENCE)
end

local function hasChaplainOfViolenceProc(amountHealed)
    return amountHealed >= 3
end

local function calculateChaplainOfViolenceBonusDamage(numGreaterHealSlotsUsed)
    return numGreaterHealSlotsUsed > 0 and 4 or 2
end

-- Feat: Paragon

local function usesParagon()
    return character.hasFeat(FEATS.PARAGON)
end

local function calculateNumPlayersHealableWithParagon()
    local spirit = character.getPlayerSpirit()
    local playersHealable = 1 + floor(spirit / 3)

    return max(1, playersHealable)
end

-- Rolling

local function shouldShowPreRollUI(turnTypeID)
    return rules.other.shouldShowPreRollUI() or (turnTypeID == TURN_TYPES.PLAYER.id and rules.playerTurn.shouldShowPreRollUI())
end

rules.healing = {
    NUM_EXCESS_TO_RESTORE_GREATER_HEAL_SLOT = NUM_EXCESS_TO_RESTORE_GREATER_HEAL_SLOT,

    canHeal = canHeal,
    calculateHealValue = calculateHealValue,
    calculateBaseAmountHealed = calculateBaseAmountHealed,
    applySpiritBonus = applySpiritBonus,
    applyHealingDoneBuff = applyHealingDoneBuff,
    isCrit = isCrit,
    applyCritModifier = applyCritModifier,
    getMaxGreaterHealSlots = getMaxGreaterHealSlots,
    calculateGreaterHealBonus = calculateGreaterHealBonus,

    canUseTargetKOBonus = canUseTargetKOBonus,
    getTargetKOBonus = getTargetKOBonus,

    canUseExcess = canUseExcess,
    getMaxExcess = getMaxExcess,

    canStillHeal = canStillHeal,
    applyOutOfCombatBaseAmountBonus = applyOutOfCombatBaseAmountBonus,
    getOutOfCombatBonus = getOutOfCombatBonus,
    getMaxOutOfCombatHeals = getMaxOutOfCombatHeals,

    canProcChaplainOfViolence = canProcChaplainOfViolence,
    hasChaplainOfViolenceProc = hasChaplainOfViolenceProc,
    calculateChaplainOfViolenceBonusDamage = calculateChaplainOfViolenceBonusDamage,

    usesParagon = usesParagon,
    calculateNumPlayersHealableWithParagon = calculateNumPlayersHealableWithParagon,

    shouldShowPreRollUI = shouldShowPreRollUI,
}