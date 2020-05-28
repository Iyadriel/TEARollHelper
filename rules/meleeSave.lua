local _, ns = ...

local character = ns.character
local feats = ns.resources.feats
local rules = ns.rules

local FEATS = feats.FEATS

local function calculateMeleeSaveValue(roll, defence, buff)
    local value = roll
    if not character.hasFeat(FEATS.COUNTER_FORCE) then
        value = value + rules.common.calculateDefenceStat(defence, buff)
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

rules.meleeSave = {
    calculateMeleeSaveValue = calculateMeleeSaveValue,
    canProcCounterForce = canProcCounterForce,
    hasCounterForceProc = hasCounterForceProc,
    calculateCounterForceProcDmg = calculateCounterForceProcDmg,
    isSaveBigFail = isSaveBigFail,
    applyBigFailModifier = applyBigFailModifier
}