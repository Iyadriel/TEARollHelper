local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS

local BIG_FAIL_THRESHOLD = 5

local function calculateMeleeSaveValue(roll, damageType, defence, buff)
    local defenceStat = rules.common.calculateDefenceStat(damageType, defence, buff)

    if character.hasFeat(FEATS.COUNTER_FORCE) then
        defenceStat = ceil(defenceStat / 2)
    end

    return roll + defenceStat
end

local function calculateDamagePrevented(dmgRisk)
    if rules.defence.canUseBraceSystem() then
        return dmgRisk
    end
    return 0
end

local function hasCounterForceProc(meleeSaveValue, threshold)
    return meleeSaveValue >= threshold
end

local function calculateCounterForceProcDmg(defence)
    return defence * 2
end

local function applyExtraMeleeSaveDamageTakenReductions(damageTaken)
    if character.hasDefenceProficiency() then
        if character.hasFeat(FEATS.MASTER) then
            return ceil(damageTaken / 3)
        end

        return ceil(damageTaken / 2)
    end

    return damageTaken
end

local function isSaveBigFail(defendValue, threshold)
    return (defendValue + BIG_FAIL_THRESHOLD) <= threshold
end

local function applyBigFailModifier(dmgRisk)
    return dmgRisk * 2
end

local function shouldShowPreRollUI()
    return rules.other.shouldShowPreRollUI()
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

    hasCounterForceProc = hasCounterForceProc,
    calculateCounterForceProcDmg = calculateCounterForceProcDmg,

    applyExtraMeleeSaveDamageTakenReductions = applyExtraMeleeSaveDamageTakenReductions,
    isSaveBigFail = isSaveBigFail,
    applyBigFailModifier = applyBigFailModifier,

    shouldShowPreRollUI = shouldShowPreRollUI,

    getRollModeModifier = getRollModeModifier,
}
