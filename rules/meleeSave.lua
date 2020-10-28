local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules
local traits = ns.resources.traits

local FEATS = feats.FEATS
local TRAITS = traits.TRAITS

local BIG_FAIL_TREHSHOLD = 5

local function calculateMeleeSaveValue(roll, damageType, defence, buff)
    local value = roll
    if not character.hasFeat(FEATS.COUNTER_FORCE) then
        value = value + rules.common.calculateDefenceStat(damageType, defence, buff)
    end
    return value
end

local function calculateDamagePrevented(dmgRisk)
    if character.hasDefenceMastery() then
        return dmgRisk
    end
    return 0
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
    return (defendValue + BIG_FAIL_TREHSHOLD) <= threshold
end

local function applyBigFailModifier(dmgRisk)
    return dmgRisk * 2
end

local function shouldShowPreRollUI()
    return rules.other.shouldShowPreRollUI()
end

local function shouldShowPostRollUI()
    return character.hasTrait(TRAITS.PRESENCE_OF_VIRTUE)
end

local function getRollModeModifier()
    local modifier = 0

    if character.hasFeat(FEATS.PHALANX) then
        modifier = modifier + 1
    end

    return modifier
end

rules.meleeSave = {
    calculateMeleeSaveValue = calculateMeleeSaveValue,
    calculateDamagePrevented = calculateDamagePrevented,

    canProcCounterForce = canProcCounterForce,
    hasCounterForceProc = hasCounterForceProc,
    calculateCounterForceProcDmg = calculateCounterForceProcDmg,

    isSaveBigFail = isSaveBigFail,
    applyBigFailModifier = applyBigFailModifier,

    shouldShowPreRollUI = shouldShowPreRollUI,
    shouldShowPostRollUI = shouldShowPostRollUI,

    getRollModeModifier = getRollModeModifier,
}