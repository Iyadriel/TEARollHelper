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

local function isCrit(roll)
    local critReq = MAX_ROLL
    if character.hasFeat(FEATS.KEEN_SENSE) then
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

-- [[ Offence ]]

local function getBaseDamage()
    return character.hasOffenceMastery() and 3 or 1
end

local function calculateAttackValue(roll, offence, buff)
    return roll + offence + buff
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

local function calculateDefendValue(roll, defence, buff)
    return roll + defence + buff
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

-- [[ Melee save ]]

local function isSaveBigFail(defendValue, threshold)
    local failThreshold = character.hasFeat(FEATS.PHALANX) and 8 or 5
    return (defendValue + failThreshold) <= threshold
end

local function applyBigFailModifier(damageTaken)
    return damageTaken * 2
end

-- [[ Ranged save ]]

local function calculateRangedSaveValue(roll, spirit)
    return roll + spirit
end

local function calculateDamageReduction(threshold, dmgRisk, saveValue, spirit)
    if saveValue >= threshold then
        return dmgRisk
    end
    return 2 + max(0, floor(spirit / 2))
end

-- [[ Healing ]]

local function calculateHealValue(roll, spirit)
    return roll + spirit
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
    local numSlots = max(0, floor(spirit / 2))

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

-- [[ Buffing ]]

local function calculateBuffValue(roll, spirit)
    return roll + spirit
end

local function calculateBuffAmount(buffValue)
    return ceil(buffValue / 2)
end

-- [[ Export ]]

ns.rules.MAX_ROLL = MAX_ROLL
ns.rules.CRIT_TYPES = CRIT_TYPES

ns.rules.isCrit = isCrit
ns.rules.getCritType = getCritType
ns.rules.offence = {
    calculateAttackValue = calculateAttackValue,
    calculateAttackDmg = calculateAttackDmg,
    applyCritModifier = applyCritModifier,

    canProcAdrenaline = canProcAdrenaline,
    hasAdrenalineProc = hasAdrenalineProc,
    applyAdrenalineProcModifier = applyAdrenalineProcModifier,

    canProcEntropicEmbrace = canProcEntropicEmbrace,
    hasEntropicEmbraceProc = hasEntropicEmbraceProc,
    getEntropicEmbraceDmg = getEntropicEmbraceDmg
}
ns.rules.defence = {
    calculateDefendValue = calculateDefendValue,
    calculateDamageTaken = calculateDamageTaken,
    calculateRetaliationDamage = calculateRetaliationDamage
}
ns.rules.meleeSave = {
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
    calculateGreaterHealBonus = calculateGreaterHealBonus
}
ns.rules.buffing = {
    calculateBuffValue = calculateBuffValue,
    calculateBuffAmount = calculateBuffAmount
}