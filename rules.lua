local _, ns = ...

local character = ns.character
local FEATS = ns.resources.feats.FEATS
local racialTraits = ns.resources.racialTraits

local RACIAL_TRAITS = racialTraits.RACIAL_TRAITS

local MAX_ROLL = 20
local CRIT_TYPES = {
    DAMAGE = 0,
    REAPER = 1
}

local BASE_STAMINA = 25

local BASE_STAT_POINTS = 12
local MAX_STAT_POINTS = 16
local NEGATIVE_POINTS_BUDGET = MAX_STAT_POINTS - BASE_STAT_POINTS
local STAT_MIN_VALUE = -4
local STAT_MAX_VALUE = 6
local STAT_POINT_COSTS = {
    [1] = 1,
    [2] = 2,
    [3] = 4,
    [4] = 6,
    [5] = 9,
    [6] = 12
}

local NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT = 2
local NUM_SPIRIT_PER_GREATER_HEAL_SLOT = 2

-- [[ Stat allocation ]]

local function getNegativePointsAssigned()
    local negativePointsAllocated = 0

    local offence = character.getPlayerOffence()
    local defence = character.getPlayerDefence()
    local spirit = character.getPlayerSpirit()
    local stamina = character.getPlayerStamina()

    if offence < 0 then
        negativePointsAllocated = negativePointsAllocated - offence
    end

    if defence < 0 then
        negativePointsAllocated = negativePointsAllocated - defence
    end

    if spirit < 0 then
        negativePointsAllocated = negativePointsAllocated - spirit
    end

    if stamina < 0 then
        negativePointsAllocated = negativePointsAllocated - stamina
    end

    return negativePointsAllocated
end

local function getNegativePointsUsed()
    return min(NEGATIVE_POINTS_BUDGET, getNegativePointsAssigned())
end

local function getAvailableNegativePoints()
    return NEGATIVE_POINTS_BUDGET - getNegativePointsUsed()
end

local function getAvailableStatPoints()
    local points = BASE_STAT_POINTS

    local offence = character.getPlayerOffence()
    local defence = character.getPlayerDefence()
    local spirit = character.getPlayerSpirit()
    local stamina = character.getPlayerStamina()

    if offence > 0 then
        points = points - STAT_POINT_COSTS[offence]
    end

    if defence > 0 then
        points = points - STAT_POINT_COSTS[defence]
    end

    if spirit > 0 then
        points = points - STAT_POINT_COSTS[spirit]
    end

    if stamina > 0 then
        points = points - STAT_POINT_COSTS[stamina]
    end

    points = points + getNegativePointsUsed()

    return points
end

local function isCrit(roll)
    local critReq = MAX_ROLL
    if character.hasFeat(FEATS.KEEN_SENSE) then
        critReq = critReq - 1
    end
    if character.hasRacialTrait(RACIAL_TRAITS.VICIOUSNESS) then
        critReq = critReq - 1
    end
    return roll >= critReq
end

local function getCritType()
    if character.hasFeat(FEATS.REAPER) then
        return CRIT_TYPES.REAPER
    end
    return CRIT_TYPES.DAMAGE
end

-- [[ Stat calculations ]]

local function calculateOffenceStat(offence, buff)
    return offence + buff
end

local function calculateSpiritStat(spirit, buff)
    return spirit + buff
end

-- [[ Offence ]]

local function getBaseDamage()
    return character.hasOffenceMastery() and 3 or 1
end

local function calculateAttackValue(roll, offence, buff)
    return roll + calculateOffenceStat(offence, buff)
end

local function calculateAttackDmg(threshold, attackValue)
    local overkill = attackValue - threshold
    if overkill >= 0 then
        return getBaseDamage() + floor(overkill / 2)
    end
    return 0
end

local function applyCritModifier(dmg)
    return dmg * 2
end

-- Feat: Adrenaline

local function canProcAdrenaline()
    return character.hasFeat(FEATS.ADRENALINE)
end

local function hasAdrenalineProc(threshold, attackValue)
    return attackValue >= threshold + 4
end

local function calculateAdrenalineProcDmg(offence)
    return ceil(offence / 2)
end

local function applyAdrenalineProcModifier(dmg, offence)
    return dmg + calculateAdrenalineProcDmg(offence)
end

-- Feat: Blood Harvest

local function canUseBloodHarvest()
    return character.hasFeat(FEATS.BLOOD_HARVEST)
end

local function getMaxBloodHarvestSlots()
    local offence = character.getPlayerOffence()
    local numSlots = max(0, floor(offence / NUM_OFFENCE_PER_BLOOD_HARVEST_SLOT))

    return numSlots
end

local function calculateBloodHarvestBonus(numBloodHarvestSlots)
    return numBloodHarvestSlots * 3
end

-- Feat: Mercy from Pain

local function canProcMercyFromPain()
    return character.hasFeat(FEATS.MERCY_FROM_PAIN)
end

local function hasMercyFromPainProc(dmgDealt)
    return dmgDealt >= 5
end

local function calculateMercyFromPainBonusHealing(multipleEnemiesHit)
    return multipleEnemiesHit and 4 or 2
end

-- Racial Trait: Entropic Embrace

local function canProcEntropicEmbrace()
    return character.hasRacialTrait(RACIAL_TRAITS.ENTROPIC_EMBRACE)
end

local function hasEntropicEmbraceProc(roll, threshold)
    return roll == threshold
end

local function getEntropicEmbraceDmg()
    return 3
end

-- [[ Defence ]]

local function calculateDefenceStat(defence, buff, racialTrait)
    local stat = defence + buff
    if racialTraits.equals(racialTrait, RACIAL_TRAITS.QUICKNESS) then
        stat = stat + 2
    end
    return stat
end

local function calculateDefendValue(roll, defence, buff, racialTrait)
    return roll + calculateDefenceStat(defence, buff, racialTrait)
end

local function calculateDamageTaken(threshold, defendValue, dmgRisk)
    local safetyMargin = defendValue - threshold
    if safetyMargin >= 0 then
        return 0
    end
    return dmgRisk
end

local function calculateRetaliationDamage(defence)
    return 1 + defence
end

-- [[ Stamina ]]

local function calculateMaxHP(stamina)
    return BASE_STAMINA + (stamina * 2)
end

-- [[ Melee save ]]

local function calculateMeleeSaveValue(roll, defence, buff, racialTrait)
    local value = roll
    if not character.hasFeat(FEATS.COUNTER_FORCE) then
        value = value + calculateDefenceStat(defence, buff, racialTrait)
    end
    return value
end

local function canProcCounterForce()
    return character.hasFeat(FEATS.COUNTER_FORCE)
end

local function hasCounterForceProc(meleeSaveValue, threshold)
    return meleeSaveValue >= threshold
end

local function calculateCounterForceProcDmg(defence)
    return defence -- big maths
end

local function isSaveBigFail(defendValue, threshold)
    local failThreshold = character.hasFeat(FEATS.PHALANX) and 8 or 5
    return (defendValue + failThreshold) <= threshold
end

local function applyBigFailModifier(damageTaken)
    return damageTaken * 2
end

-- [[ Ranged save ]]

local function calculateRangedSaveValue(roll, spirit, buff)
    return roll + calculateSpiritStat(spirit, buff)
end

local function calculateDamageReduction(threshold, dmgRisk, saveValue, spirit)
    if saveValue >= threshold then
        return dmgRisk
    end
    local baseReduction = character.hasFeat(FEATS.WARDER) and 4 or 2
    return baseReduction + max(0, floor(spirit / 2))
end

-- [[ Healing ]]

local function calculateHealValue(roll, spirit, buff)
    return roll + calculateSpiritStat(spirit, buff)
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

-- [[ Buffing ]]

local function usesInspiringPresence()
    return character.hasFeat(FEATS.INSPIRING_PRESENCE)
end

local function calculateSpiritToAddToRoll(spirit)
    if usesInspiringPresence() then
        return ceil(spirit / 2)
    end
    return spirit
end

local function calculateBuffValue(roll, spirit, spiritBuff, offence, offenceBuff)
    local stat
    spirit = calculateSpiritStat(spirit, spiritBuff)
    spirit = calculateSpiritToAddToRoll(spirit)

    if character.hasFeat(FEATS.LEADER) then
        local offenceStat = calculateOffenceStat(offence, offenceBuff)
        stat = max(spirit, offenceStat)
    else
        stat = spirit
    end

    return roll + stat
end

local function calculateBuffAmount(buffValue)
    return ceil(buffValue / 2)
end

-- [[ Utility ]]

local function calculateUtilityValue(roll, useUtilityTrait)
    local value = roll
    if useUtilityTrait then
        local bonus = character.hasFeat(FEATS.PROFESSIONAL) and 8 or 5
        value = value + bonus
    end
    return value
end

-- [[ Export ]]

ns.rules.MAX_ROLL = MAX_ROLL
ns.rules.CRIT_TYPES = CRIT_TYPES

ns.rules.stats = {
    STAT_MIN_VALUE = STAT_MIN_VALUE,
    STAT_MAX_VALUE = STAT_MAX_VALUE,
    getNegativePointsAssigned = getNegativePointsAssigned,
    getNegativePointsUsed = getNegativePointsUsed,
    getAvailableNegativePoints = getAvailableNegativePoints,
    getAvailableStatPoints = getAvailableStatPoints,
}

ns.rules.isCrit = isCrit
ns.rules.getCritType = getCritType

ns.rules.offence = {
    calculateAttackValue = calculateAttackValue,
    calculateAttackDmg = calculateAttackDmg,
    applyCritModifier = applyCritModifier,

    canProcAdrenaline = canProcAdrenaline,
    hasAdrenalineProc = hasAdrenalineProc,
    applyAdrenalineProcModifier = applyAdrenalineProcModifier,

    canUseBloodHarvest = canUseBloodHarvest,
    getMaxBloodHarvestSlots = getMaxBloodHarvestSlots,
    calculateBloodHarvestBonus = calculateBloodHarvestBonus,

    canProcMercyFromPain = canProcMercyFromPain,
    hasMercyFromPainProc = hasMercyFromPainProc,
    calculateMercyFromPainBonusHealing = calculateMercyFromPainBonusHealing,

    canProcEntropicEmbrace = canProcEntropicEmbrace,
    hasEntropicEmbraceProc = hasEntropicEmbraceProc,
    getEntropicEmbraceDmg = getEntropicEmbraceDmg
}
ns.rules.defence = {
    calculateDefendValue = calculateDefendValue,
    calculateDamageTaken = calculateDamageTaken,
    calculateRetaliationDamage = calculateRetaliationDamage
}
ns.rules.stamina = {
    calculateMaxHP = calculateMaxHP
}
ns.rules.meleeSave = {
    calculateMeleeSaveValue = calculateMeleeSaveValue,
    canProcCounterForce = canProcCounterForce,
    hasCounterForceProc = hasCounterForceProc,
    calculateCounterForceProcDmg = calculateCounterForceProcDmg,
    isSaveBigFail = isSaveBigFail,
    applyBigFailModifier = applyBigFailModifier
}
ns.rules.rangedSave = {
    calculateRangedSaveValue = calculateRangedSaveValue,
    calculateDamageReduction = calculateDamageReduction,
}
ns.rules.healing = {
    calculateHealValue = calculateHealValue,
    calculateAmountHealed = calculateAmountHealed,
    getMaxGreaterHealSlots = getMaxGreaterHealSlots,
    calculateGreaterHealBonus = calculateGreaterHealBonus,
    applyOutOfCombatBonus = applyOutOfCombatBonus,
    calculateNumHealsAllowedOutOfCombat = calculateNumHealsAllowedOutOfCombat
}
ns.rules.buffing = {
    usesInspiringPresence = usesInspiringPresence,
    calculateBuffValue = calculateBuffValue,
    calculateBuffAmount = calculateBuffAmount
}
ns.rules.utility = {
    calculateUtilityValue = calculateUtilityValue
}